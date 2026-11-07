extends RefCounted
var craft_quantity := 1
var build_family := "Structures"
var build_choice := "workbench"
var build_tray: Control
var pack_signature := ""
var queue_signature := ""
var queue_labels := {}
var edit_feedback := ""
var edit_signature := ""
var workshop_filter := "All"
var craft_catalog: GridContainer
var codex_filter := "All"
var focus_id := ""
var workshop_jobs := {}
var workshop_stock: Label
var workshop_signature := ""
var trade_signature := ""
const Thumbnail = preload("res://scripts/TileThumbnail.gd")
func close_button(h, box: VBoxContainer) -> void:
 h.button("Back" if h.launch_menu else "Back to island",func(): h.modal.hide(); h.refresh(); h.check_transition_ad(),box)
func journal(h) -> void:
 var box: VBoxContainer = h.modal_content("Discoveries · %d / 20" % h.model.state.discoveries.size())
 var chapter: Dictionary = h.model.campaign.chapter_definition(h.model)
 h.label("CHAPTER %d · %s" % [h.model.state.chapter,chapter.name],17,box)
 h.label(h.model.campaign.chapter_progress(h.model).split("\n")[-1],15,box)
 h.label(h.model.campaign.PURPOSE,15,box)
 if h.model.state.chapter_rewards.has(5): h.sheets.primary(h,"Celebrate your sanctuary",func(): h.finale_ui.show(h),box)
 h.label(h.model.campaign.next_goal(h.model).split("\n")[0],16,box)
 var tabs := ScrollContainer.new()
 tabs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 tabs.custom_minimum_size.y = h.touch_height()+6
 box.add_child(tabs)
 var row := HBoxContainer.new(); tabs.add_child(row)
 for family in ["All","Plants","Water","Stone","Sanctuaries"]:
  var tab: Button = h.sheets.tab(h,family,codex_filter == family,func(): codex_filter = family; journal(h),row)
  tab.custom_minimum_size.x = 120
 var grid := GridContainer.new(); grid.columns = 2
 grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",10)
 box.add_child(grid)
 for recipe in h.model.config.recipes+h.model.config.fusions:
  var fusion: bool = recipe.footprint == [2,2] or recipe.has("type")
  var family := "Sanctuaries" if fusion else ("Water" if recipe.types[0] == "water" else "Stone" if recipe.types[0] in ["stone","iron","vent"] else "Plants")
  if codex_filter != "All" and codex_filter != family: continue
  var panel := PanelContainer.new()
  panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  var style: StyleBoxFlat = preload("res://scripts/GameTheme.gd").sheet_panel(); style.border_color = h.rarity_color(recipe.rarity)
  panel.add_theme_stylebox_override("panel",style)
  grid.add_child(panel)
  var content := VBoxContainer.new(); panel.add_child(content)
  var icon = h.sheets.art(h,content,recipe.types[0],recipe.id,126)
  icon.silhouette = not h.model.state.discoveries.has(recipe.id)
  h.label(recipe.rarity.capitalize(),13,content)
  h.button(("✓ " if not icon.silhouette else "? ")+recipe.name,func(): detail(h,recipe.id),content)
 h.button("Back to Pack",func():pack(h),box)
 close_button(h,box)

func detail(h, id: String) -> void:
 var recipe: Dictionary = {}
 for candidate in h.model.config.recipes+h.model.config.fusions:
  if candidate.id == id: recipe = candidate
 if recipe.is_empty(): return
 focus_id = id
 var box: VBoxContainer = h.modal_content(recipe.name)
 h.modal_screen = "codex_detail"
 var unlocked: bool = h.model.state.discoveries.has(id)
 var clarity: int = 2 if unlocked else maxi(mini(2,int(h.model.state.harvests/5)),int(h.model.state.hints.get(id,0)))
 var art = h.sheets.art(h,box,recipe.types[0],id,190); art.silhouette = not unlocked
 h.label(recipe.rarity.capitalize()+" · "+("Discovered" if unlocked else "Uncharted"),18,box)
 h.label(recipe.lore if unlocked else recipe.mystery_hint,17,box)
 if clarity >= 1: h.label("Begins with "+", ".join(recipe.types)+(" · four matching cells in a square" if recipe.has("type") else ""),16,box)
 if clarity >= 2:
  if recipe.has("type"): h.label(recipe.hint,16,box)
  for attribute in recipe.min: h.label("%s ≥ %d" % [attribute.capitalize(),recipe.min[attribute]],16,box)
  for attribute in recipe.max: h.label("%s ≤ %d" % [attribute.capitalize(),recipe.max[attribute]],16,box)
  for structure in recipe.structures: h.label("Needs a "+structure.capitalize(),16,box)
  if recipe.pulse != "": h.label("Needs a recent "+recipe.pulse.capitalize()+" Pulse",16,box)
 else:
  h.label("Keep harvesting to study the exact conditions: %d / 10" % mini(h.model.state.harvests,10),16,box)
  var extra: Button = h.button("Optional test ad · reveal exact conditions",func(): h.services.request_reward("hint",{"discovery":id}),box)
  extra.disabled = not h.services.ad_ready or not h.services.reward_available()
 if recipe.has("resource"): h.label("Production · %d %s every %ds" % [recipe.yield_amount,recipe.resource.replace("_"," ").capitalize(),recipe.cooldown],16,box)
 h.sheets.caption(h,"FIRST DISCOVERY REWARDS",box)
 h.sheets.chips(h,box,{"coins":recipe.reward,"star_dew":1})
 h.sheets.caption(h,"Plus up to 100 Pulse energy.",box)
 h.button("Back to discoveries",func(): journal(h),box)
 close_button(h,box)

func workshop(h) -> void:
 var saved: Dictionary = h.build_saved_view.duplicate() if not h.build_saved_view.is_empty() else {"zoom":h.zoom_level,"pan":h.pan}
 var box: VBoxContainer = h.modal_content("Build")
 h.build_saved_view = saved
 h.modal_screen = "build"
 h.bottom.hide()
 box.get_child(0).hide()
 box.add_theme_constant_override("separation",0)
 build_tray = preload("res://scripts/BuildTray.gd").new()
 box.add_child(build_tray); build_tray.configure(h)
 # A light scrim keeps the real island visible above the lower workbench.
 h.modal_scrim.color = Color(0.035,0.055,0.05,0.14)
 h.call_deferred("apply_layout")

func pack(h) -> void:
 var box: VBoxContainer=h.modal_content("Your Pack");h.modal_screen="pack"
 h.sheets.caption(h,"Choose what you want to do. Materials are what you collect; finished items are ready to place on your island.",box)
 h.sheets.primary(h,"Continue my current goal",func():h.open_ideas(),box)
 var tools:=GridContainer.new();tools.columns=2;tools.add_theme_constant_override("h_separation",8);tools.add_theme_constant_override("v_separation",8);box.add_child(tools)
 for entry in [{"title":"Materials & trade","detail":"Your stock and ways to earn Coins","icon":"pack","route":"inventory","run":func():inventory(h)},{"title":"Discoveries","detail":"What you found and free clues","icon":"codex","route":"discoveries","run":func():journal(h)},{"title":"Crafting queue","detail":"Work in progress and ready items","icon":"craft","route":"queue","run":func():project_queue(h)},{"title":"Island tools","detail":"Care, arrange, explore and take photos","icon":"world","route":"world","run":func():world(h)}]:
  var action: Button=h.sheets.tool_card(h,entry.title,entry.detail,entry.icon,entry.run,tools);action.tooltip_text=entry.detail;action.set_meta("menu_route",entry.route)
 close_button(h,box)

func inventory(h) -> void:
 var box: VBoxContainer=h.modal_content("Materials & trade");h.modal_screen="inventory"
 h.sheets.caption(h,"Collect materials from ready trees and rocks. Use them to make things, or sell spare stock for Coins. Nothing is sold until you choose a trade.",box)
 var gather: Button = h.sheets.primary(h,"Gather ready resources · %d" % h.model.ready_harvests().size(),func(): h.gather_ready(),box)
 gather.disabled = h.model.state.harvests == 0 or h.model.ready_harvests().is_empty()
 gather.tooltip_text = "Collect ready nodes once; cooldowns and storage limits still apply."
 pack_signature = JSON.stringify([h.model.state.inventory,h.model.state.coins,h.model.state.blueprints,h.model.ready_harvests().size(),h.model.state.harvests])
 var stock := GridContainer.new(); stock.columns = 4; stock.add_theme_constant_override("h_separation",6); stock.add_theme_constant_override("v_separation",6); box.add_child(stock)
 for id in ["wood","stone","fiber","clay","iron","brick","star_dew","coins"]:
  var item: VBoxContainer = h.sheets.card(stock)
  h.sheets.icon(item,id,40)
  var amount: int = h.model.state.coins if id == "coins" else h.model.state.inventory[id]
  var count: Label = h.label(str(amount),16,item); count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  var name: Label = h.sheets.caption(h,"Dew" if id == "star_dew" else id.capitalize(),item); name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 h.button("Trade spare materials for Coins",func():trade(h),box)
 h.button("Back to Pack",func():pack(h),box)
 close_button(h,box)

func project_queue(h) -> void:
 var box: VBoxContainer=h.modal_content("Crafting queue");h.modal_screen="project_queue";queue_labels.clear()
 h.sheets.caption(h,"Making a building creates a finished item. When it is ready, place it on an empty grassy plot. Materials are paid once when making starts.",box)
 queue_signature=JSON.stringify([h.model.state.jobs,h.model.state.blueprints,h.model.state.pending,h.available_meadows()])
 if h.model.state.jobs.is_empty():h.label("Nothing is being made right now.",17,box)
 for job in h.model.state.jobs:
  var row:=HBoxContainer.new();box.add_child(row)
  var name: Label=h.label(str(job.recipe).capitalize(),17,row);name.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  queue_labels[job.id]=h.label("%ds left" % ceili(maxf(0,job.until-h.model.state.time)),15,row)
 var ready:=0
 for type in h.model.state.blueprints:
  var amount: int=h.model.state.blueprints[type]
  if amount<=0:continue
  ready+=amount
  var place: Button=h.sheets.primary(h,"Place "+str(type).capitalize()+" · %d ready" % amount,func():h.choose_idea({"action":"blueprint","target":type}),box)
  place.disabled=not h.model.state.pending.is_empty() or h.available_meadows().is_empty()
 if ready==0:h.sheets.caption(h,"Finished buildings and land will appear here when they are ready to place.",box)
 elif not h.model.state.pending.is_empty():
  h.sheets.caption(h,"Finish your saved land choice first. Your ready items are kept.",box)
  h.button("Review saved cards",func():h.draft(),box)
 elif h.available_meadows().is_empty():
  h.sheets.caption(h,"You need empty grass to place an item. Expand with Grass, or select an unprotected plot on the island and replace it with grass under Arrange island.",box)
  h.button("Find room on my island",func():world(h,"edit"),box)
 h.button("Make something in Build",func():workshop(h),box)
 h.button("Batch crafting & all recipes",func():workshop_details(h),box)
 h.button("Back to Pack",func():pack(h),box)
 close_button(h,box)

func workshop_details(h) -> void:
 var box: VBoxContainer = h.modal_content("Workbench & stock")
 h.modal_screen = "workshop"
 workshop_jobs.clear()
 workshop_signature = JSON.stringify([h.model.state.jobs,h.model.state.blueprints,h.model.state.inventory,h.model.state.coins])
 var stock := {}
 for resource in ["wood","stone","fiber","clay","iron","brick","star_dew"]: stock[resource] = h.model.state.inventory[resource]
 h.sheets.chips(h,box,stock)
 workshop_stock = h.label("",14,box); workshop_stock.hide()
 var trade_entry: Button = h.button("Trade spare materials for coins",func(): trade(h),box)
 h.button_icon(trade_entry,"coins")
 h.sheets.caption(h,"WORKBENCH · THREE PROJECT SLOTS",box)
 var projects := HBoxContainer.new(); projects.add_theme_constant_override("separation",8); box.add_child(projects)
 for index in range(3):
  var slot: VBoxContainer = h.sheets.card(projects)
  if index < h.model.state.jobs.size():
   var job: Dictionary = h.model.state.jobs[index]
   var recipe: Dictionary = {}
   for candidate in h.model.config.crafting:
    if candidate.id == job.recipe: recipe = candidate; break
   if recipe.has("tile"): h.sheets.art(h,slot,recipe.tile,"",62)
   else: h.sheets.icon(slot,recipe.get("resource","brick"),42)
   workshop_jobs[job.id] = h.label("× %d · %ds" % [job.get("quantity",1),ceili(maxf(0,job.until-h.model.state.time))],14,slot)
  else:
   var plus: Label = h.label("+",25,slot); plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
   h.sheets.caption(h,"Empty slot",slot)
 var quantity_row := HBoxContainer.new(); box.add_child(quantity_row)
 var less: Button = h.button("−",func(): craft_quantity = maxi(1,craft_quantity-1); workshop_details(h),quantity_row)
 less.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN; less.custom_minimum_size.x = h.touch_height()
 var quantity_label: Label = h.label("Batch · %d" % craft_quantity,17,quantity_row)
 quantity_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var more: Button = h.button("+",func(): craft_quantity = mini(3,craft_quantity+1); workshop_details(h),quantity_row)
 more.size_flags_horizontal = Control.SIZE_SHRINK_END; more.custom_minimum_size.x = h.touch_height()
 var tabs := ScrollContainer.new(); tabs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; tabs.custom_minimum_size.y = h.touch_height()+3; box.add_child(tabs)
 var categories := HBoxContainer.new(); tabs.add_child(categories)
 for category in ["All","Land","Structures","Materials"]:
  h.sheets.tab(h,category,workshop_filter == category,func(): workshop_filter = category; workshop_details(h),categories)
 craft_catalog = GridContainer.new(); craft_catalog.columns = 2
 craft_catalog.add_theme_constant_override("h_separation",10); craft_catalog.add_theme_constant_override("v_separation",10)
 box.add_child(craft_catalog)
 for recipe in h.model.config.crafting:
  var category: String = "Materials" if not recipe.has("tile") else "Structures" if h.model.config.tiles[recipe.tile].category == "structure" else "Land"
  if workshop_filter != "All" and workshop_filter != category: continue
  var content: VBoxContainer = h.sheets.card(craft_catalog)
  content.get_parent().set_meta("recipe_id",recipe.id)
  if recipe.has("tile"): h.sheets.art(h,content,recipe.tile,"",118)
  else: h.sheets.icon(content,recipe.get("resource","brick"),72)
  h.label(recipe.get("tile",recipe.id).capitalize(),18,content)
  var cost := {}
  for resource in recipe.cost: cost[resource] = recipe.cost[resource]*craft_quantity
  h.sheets.chips(h,content,cost,true)
  var missing := PackedStringArray()
  var prerequisite: bool = h.model.campaign.has_structure(h.model,recipe.requires)
  if not prerequisite: missing.append("Build "+recipe.requires.capitalize())
  for resource in cost:
   var owned: int = h.model.state.coins if resource == "coins" else h.model.state.inventory.get(resource,0)
   if owned < cost[resource]: missing.append("%d more %s" % [cost[resource]-owned,resource])
  if h.model.state.jobs.size() >= 3: missing.append("All project slots are busy")
  var seconds: int = ceili(h.model.campaign.crafting_seconds(h.model,recipe)*craft_quantity)
  var action: Button = h.sheets.primary(h,"Craft × %d · %ds" % [craft_quantity,seconds],func():
   h.model.craft(recipe.id,craft_quantity); h.persist(); h.refresh(); workshop_details(h),content)
  action.disabled = not missing.is_empty(); action.tooltip_text = ", ".join(missing)
  if not prerequisite: h.sheets.caption(h,"Needs "+recipe.requires.capitalize(),content)
  elif h.model.state.jobs.size() >= 3: h.sheets.caption(h,"All slots busy",content)
 h.label("Ready to place",19,box)
 var ready := false
 for type in h.model.state.blueprints:
  if h.model.state.blueprints[type] < 1: continue
  ready = true
  var content: VBoxContainer = h.sheets.card(box)
  h.sheets.art(h,content,type,"",100)
  h.sheets.primary(h,"Place %s × %d" % [type.capitalize(),h.model.state.blueprints[type]],func():
   h.placement_blueprint = type; h.model.message = "Tap an empty Grass tile to place "+type.capitalize()+". Tap Cancel placement to stop."
   h.modal.hide(); h.refresh(),content)
 if not ready: h.sheets.caption(h,"Finished blueprints appear here. Place them on empty Grass.",box)
 if h.model.campaign.has_structure(h.model,"furnace"):
  var reserves: Dictionary = h.model.config.tiles.furnace.get("automation_reserve",{})
  var held := PackedStringArray()
  for resource in reserves: held.append("%d %s" % [reserves[resource],resource.capitalize()])
  h.sheets.caption(h,"Automatic Furnace keeps "+", ".join(held)+" for construction. Manual crafting can use that stock.",box)
 h.button("Back to crafting queue",func():project_queue(h),box)
 close_button(h,box)

func update_live(h) -> void:
 if not h.modal.visible: return
 if h.modal_screen == "build" and is_instance_valid(build_tray):
  build_tray.update_live(); return
 if h.modal_screen=="project_queue":
  var current:=JSON.stringify([h.model.state.jobs,h.model.state.blueprints,h.model.state.pending,h.available_meadows()])
  if current!=queue_signature:
   var offset: int=h.modal_scroll.scroll_vertical
   project_queue(h);h.modal_scroll.set_deferred("scroll_vertical",offset)
  else:
   for job in h.model.state.jobs:
    if queue_labels.has(job.id):queue_labels[job.id].text="%ds left" % ceili(maxf(0,job.until-h.model.state.time))
  return
 if h.modal_screen=="world_edit":
  if edit_signature!=edit_stamp(h) and h.all_touches.is_empty():
   var offset: int=h.modal_scroll.scroll_vertical
   world(h,"edit");h.modal_scroll.set_deferred("scroll_vertical",offset)
  return
 if h.modal_screen == "pack":return
 if h.modal_screen == "inventory":
  if pack_signature != JSON.stringify([h.model.state.inventory,h.model.state.coins,h.model.state.blueprints,h.model.ready_harvests().size(),h.model.state.harvests]):
   var offset: int = h.modal_scroll.scroll_vertical
   inventory(h); h.modal_scroll.set_deferred("scroll_vertical",offset)
  return
 if h.modal_screen == "trade":
  var current := JSON.stringify([h.model.state.inventory,h.model.state.coins])
  if current != trade_signature:
   var offset: int = h.modal_scroll.scroll_vertical
   trade(h); h.modal_scroll.set_deferred("scroll_vertical",offset)
  return
 if h.modal_screen != "workshop": return
 var signature: String = JSON.stringify([h.model.state.jobs,h.model.state.blueprints,h.model.state.inventory,h.model.state.coins])
 if signature != workshop_signature:
  var scroll: ScrollContainer = h.modal_scroll
  var offset: int = scroll.scroll_vertical
  workshop_details(h)
  h.modal_scroll.set_deferred("scroll_vertical",offset)
  return
 if is_instance_valid(workshop_stock):
  var stock: Dictionary = h.model.state.inventory
  workshop_stock.text = "Wood %d · Stone %d · Fiber %d\nClay %d · Iron %d · Brick %d · Dew %d" % [stock.wood,stock.stone,stock.fiber,stock.clay,stock.iron,stock.brick,stock.star_dew]
 for job in h.model.state.jobs:
  if workshop_jobs.has(job.id): workshop_jobs[job.id].text = "× %d · %ds" % [job.get("quantity",1),ceili(maxf(0,job.until-h.model.state.time))]

func world(h, section: String = "home") -> void:
 var titles: Dictionary={"home":"Island tools","care":"Plants & wildlife","edit":"Arrange your island","view":"Camera & photos","adventures":"Other islands & challenges","visitors":"Visitors & requests"}
 if not titles.has(section):section="home"
 if section!="edit":edit_feedback=""
 var box: VBoxContainer=h.modal_content(titles[section]);h.modal_screen="world_"+section
 if section=="home":
  h.sheets.caption(h,"Choose one kind of activity. Caring helps your island grow; arranging changes where things go.",box)
  h.sheets.primary(h,"Continue my current goal",func():h.open_ideas(),box)
  var tools:=GridContainer.new();tools.columns=2;tools.add_theme_constant_override("h_separation",8);tools.add_theme_constant_override("v_separation",8);box.add_child(tools)
  for entry in [{"title":"Plants & wildlife","detail":"Restore habitats and make a river","icon":"ecology","route":"care"},{"title":"Arrange island","detail":"Move, combine and decorate plots","icon":"craft","route":"edit"},{"title":"Camera & photos","detail":"Look around, save and share","icon":"world","route":"view"},{"title":"Other islands","detail":"Separate puzzles and challenges","icon":"codex","route":"adventures"}]:
   h.sheets.tool_card(h,entry.title,entry.detail,entry.icon,func():world(h,entry.route),tools).set_meta("menu_route",entry.route)
 elif section=="care":
  h.sheets.caption(h,"A habitat is a place where wildlife can live. Arrange suitable plants and Water, then review its restoration goal.",box)
  h.sheets.primary(h,"Restore a wildlife habitat",func():h.habitat_ui.show_projects(h),box)
  h.button("Make a river",func():h.corridor_ui.show(h),box)
  h.button("Care tools · water, shade & warmth",func():h.care_ui.show_tools(h),box)
  h.button("Visitors & requests",func():world(h,"visitors"),box)
 elif section=="visitors":
  h.sheets.caption(h,"Visitors respond to suitable habitats. Their requests are optional ideas for your island, with no timer or penalty for leaving them.",box)
  h.button("See visitors & field notes",func():h.sanctuary_life.show_notes(h),box)
  h.button("Review optional requests",func():h.visitor_requests.show_requests(h),box)
 elif section=="edit":
  var selected: String=h.model.origin(h.selected)
  if selected=="":h.selected="0,0";selected="0,0"
  h.label("Selected · "+h.tile_title(h.model.state.tiles[selected]),18,box)
  if edit_feedback!="":h.label(edit_feedback,16,box)
  edit_signature=edit_stamp(h)
  h.sheets.caption(h,"First tap the plot you want to change on the island. Move it when movement is unlocked, or combine four matching plots in a square into one larger sanctuary. Replacing a plot removes what is on it; always review the confirmation.",box)
  h.sheets.primary(h,"Inspect this plot",func():h.open_inspector(h.model.origin(h.selected)),box)
  var at: String = h.model.origin(h.selected)
  if at != "":
   var tile: Dictionary = h.model.state.tiles[at]
   if tile.size == 4:
    h.button("Dismantle sanctuary…",func(): h.layout_ui.dismantle_prompt(h,at),box)
   if h.model.config.tiles[tile.type].category != "structure" and h.model.state.get("habitat_projects",[]).has("living_workshop") and tile.size == 1 and at not in ["0,0","1,0","0,1"]:
    move_entry(h,at,"Move selected landscape…",box)
   if h.model.config.tiles[tile.type].category == "structure":
    move_entry(h,at,"Move selected structure…",box)
    var level: int = tile.get("level",1)
    if level < 3 and h.model.config.tiles[tile.type].get("upgradeable",true):
     var costs: Dictionary=h.model.config.upgrades[str(level)]
     var reasons:=PackedStringArray()
     for resource in costs:
      var owned: int=h.model.state.coins if resource=="coins" else h.model.state.inventory.get(resource,0)
      if owned<int(costs[resource]):reasons.append("Need %d more %s" % [int(costs[resource])-owned,str(resource).capitalize()])
     if not h.model.state.pending.is_empty() and h.model.state.coins-int(costs.get("coins",0))<h.model.state.pending.cost:reasons.append("Finish your saved land choice before using its Coins")
     var upgrade: Button=h.button("Upgrade to level %d · %s" % [level+1,cost_text(costs)],func():
      edit_action(h,func():return h.model.state.tiles.get(at,{}).get("level",1)==level and h.model.campaign.upgrade_structure(h.model,at)),box)
     upgrade.set_meta("world_action","upgrade");upgrade.disabled=not reasons.is_empty()
     if not reasons.is_empty():h.sheets.caption(h," · ".join(reasons),box)
    if h.model.config.tiles[tile.type].get("interval",0) > 0 or h.model.config.effects.has(tile.type):
     var enabled: bool=tile.get("enabled",true)
     h.button("Pause selected building" if enabled else "Resume selected building",func():
      edit_action(h,func():return h.model.state.tiles.get(at,{}).get("enabled",true)==enabled and h.model.campaign.toggle_automation(h.model,at)),box)
   if at not in ["0,0","1,0","0,1"] and tile.size == 1 and (tile.type != "grass" or tile.evolution != ""):
    var restore: Button=h.button("Restore selected tile to Meadow…",func():
     var confirm: VBoxContainer = h.modal_content("Restore this plot?")
     h.label("This removes the current biome. Structures return as level-one blueprints; their upgrades are lost. Discoveries stay in your journal. Starting harvest nodes are protected.",17,confirm)
     h.button("Confirm restoration",func():edit_action(h,func():return h.model.campaign.retire(h.model,at)),confirm)
     close_button(h,confirm),box)
    restore.disabled=not h.model.state.pending.is_empty() or h.model.state.event.targets.has(at)
    if restore.disabled:h.sheets.caption(h,"Finish the saved land choice or active weather challenge before replacing this plot.",box)
  h.button("Combine four matching plots",func():h.fusion_dialog(),box)
  h.button("Name & decorate my island",func():h.identity_ui.show(h),box)
 elif section=="view":
  h.sheets.caption(h,"Drag the island to look around, pinch to zoom, or rotate it a quarter-turn. Photo mode hides the menus before you save an image.",box)
  h.button("Center the island",func():h.modal.hide();h.frame_world(),box)
  h.button("Photo mode · save or share",func():h.modal.hide();h.begin_photo(),box)
  var turns:=HBoxContainer.new();box.add_child(turns)
  h.button("Rotate left",func():h.modal.hide();h.rotate_camera(-1),turns)
  h.button("Rotate right",func():h.modal.hide();h.rotate_camera(1),turns)
  if h.model.state.chapter>=2:h.button("Preview Day / Dusk",func():h.model.state.cosmetic="dusk" if h.model.state.cosmetic=="day" else "day";h.persist();h.refresh();world(h,"view"),box)
 elif section=="adventures":
  h.sheets.caption(h,"Expeditions are small puzzles on separate islands. Your home and its supplies stay safe. The optional Dusk Tide is a timed weather challenge at home.",box)
  h.sheets.primary(h,"Explore expedition islands",func():h.expedition_ui.overview(h),box)
  var event: Dictionary = h.model.state.event
  if event.until > 0:
   h.label("Dusk Tide · %ds · %d/2 restored" % [ceili(event.until-h.model.state.time),event.cleared.size()],18,box)
  else:
   var event_button: Button = h.button("Begin optional Dusk Tide",func():
    h.model.campaign.start_event(h.model)
    h.persist(); h.refresh(); world(h,"adventures"),box)
   event_button.disabled = h.model.state.chapter < 3 or h.model.state.time < event.next_at or not h.model.state.settings.challenge_events
   h.label("Available after Chapter 3 and five active minutes. Ignoring it never destroys progress.",14,box)
 if section!="home":h.button("Back to island tools",func():world(h),box)
 else:h.button("Back to Pack",func():pack(h),box)
 close_button(h,box)

func edit_stamp(h) -> String:
 var at: String=h.model.origin(h.selected)
 var tile: Dictionary=h.model.state.tiles.get(at,{})
 return JSON.stringify([at,tile.get("id",0),tile.get("type",""),tile.get("evolution",""),tile.get("level",1),tile.get("enabled",true),h.model.state.inventory,h.model.state.coins,h.model.state.pending,h.available_meadows(),preload("res://scripts/LayoutTools.gd").movable(h.model,at),h.model.state.event.targets])
func move_entry(h, at: String, title: String, box: VBoxContainer) -> void:
 var move: Button=h.button(title,func():h.layout_ui.begin(h,at),box)
 move.set_meta("world_action","move")
 var reason: String="Finish your saved land choice before moving." if not h.model.state.pending.is_empty() else "Moving needs an empty grassy plot." if h.available_meadows().is_empty() else "Wait for active effects to finish before moving this plot." if not preload("res://scripts/LayoutTools.gd").movable(h.model,at) else ""
 move.disabled=reason!=""
 if move.disabled:h.sheets.caption(h,reason,box)
func edit_action(h, action: Callable) -> bool:
 var before: Dictionary=h.model.state.duplicate(true)
 if not action.call():
  h.model.state=before;edit_feedback="This plot or its available materials changed. Review the requirements and try again.";h.refresh();world(h,"edit");return false
 if not h.store.save_state(h.model.state):
  h.model.state=before;edit_feedback="Could not save. Your plot, materials and Coins were kept.";h.refresh();world(h,"edit");return false
 edit_feedback="Change saved.";h.services.observe_saved_progress();h.refresh();world(h,"edit");return true

func settings(h) -> void:
 var box: VBoxContainer = h.modal_content("Settings & Accessibility")
 for id in ["sfx","music","vibration","reduced_motion","challenge_events","analytics"]:
  var names := {"sfx":"Sound effects","music":"Ambient music","vibration":"Vibration","reduced_motion":"Reduce motion","challenge_events":"Optional Dusk Tide","analytics":"Save app diagnostics (opt-in)"}
  var icon_id: String = {"sfx":"sound","music":"music","vibration":"motion","reduced_motion":"motion","challenge_events":"challenge","analytics":"shield"}[id]
  h.sheets.setting(h,names[id],h.model.state.settings[id],icon_id,func():
   h.model.state.settings[id] = not h.model.state.settings[id]
   h.apply_settings(); h.persist(); settings(h),box)
 for channel in ["music","sfx"]:
  var caption: Label = h.label(channel.capitalize()+" volume · %d%%" % roundi(h.model.state.audio_levels[channel]*100),16,box)
  var slider := styled_slider(h,0,1,0.05,h.model.state.audio_levels[channel],box)
  slider.value_changed.connect(func(value):
   h.model.state.audio_levels[channel] = value
   caption.text = channel.capitalize()+" volume · %d%%" % roundi(value*100)
   h.apply_settings(); h.persist())
 var caption: Label = h.label("Text size · %d%%" % roundi(h.model.state.text_scale*100),16,box)
 var size_slider := styled_slider(h,1,1.2,0.05,h.model.state.text_scale,box)
 size_slider.value_changed.connect(func(value):
  h.model.state.text_scale = value
  caption.text = "Text size · %d%%" % roundi(value*100)
  h.apply_settings(); h.persist())
 h.label("Core play is offline. Diagnostics are off by default. Store services require connectivity. You can play without connecting store services.",15,box)
 h.button("Store & optional rewards",func(): h.services_ui(),box)
 h.button("Privacy & data",func(): privacy(h),box)
 if h.services.privacy_options_available():
  h.button("Ad privacy choices",func(): h.services.show_privacy_options(),box)
 h.button("Tile conditions",h.conditions_help,box)
 h.button("Climate growth rules",func(): h.island_actions.climate_settings(h),box)
 h.button("Private playtest report",func(): h.playtest.show_report(h),box)
 h.button("How to play",func(): tutorial(h),box)
 h.button("About Pocket Biome",func(): about(h),box)
 h.button("New world…",h.new_world_dialog,box)
 close_button(h,box)

func styled_slider(h, low: float, high: float, step: float, value: float, parent: Node) -> HSlider:
 var slider := HSlider.new()
 slider.min_value = low; slider.max_value = high; slider.step = step; slider.value = value
 slider.custom_minimum_size.y = h.touch_height()
 var track := StyleBoxFlat.new()
 track.bg_color = Color("424d58"); track.set_corner_radius_all(4)
 track.content_margin_top = 4; track.content_margin_bottom = 4
 var fill := track.duplicate(); fill.bg_color = preload("res://scripts/GameTheme.gd").SHEET_CTA
 slider.add_theme_stylebox_override("slider",track)
 slider.add_theme_stylebox_override("grabber_area",fill)
 slider.add_theme_stylebox_override("grabber_area_highlight",fill)
 slider.add_theme_icon_override("grabber",preload("res://assets/ui/slider_knob.svg"))
 slider.add_theme_icon_override("grabber_highlight",preload("res://assets/ui/slider_knob.svg"))
 parent.add_child(slider)
 return slider

func tutorial(h) -> void:
 var box: VBoxContainer = h.modal_content("A tiny world, yours to grow")
 for step in [{"tile":"oak","title":"Collect & expand","body":"Tap ready nodes for materials and Coins. Tap a cloud to compare three cards."},{"tile":"water","title":"Find living combinations","body":"Try Water beside Oak. Hold land or tap its callout to inspect conditions; Settings → Tile conditions explains them."},{"tile":"crystal","title":"Change your world","body":"Pulse previews a cross-shaped area. Tap its center again to confirm; canceling spends nothing."},{"tile":"forest","title":"Create a sanctuary","body":"Four matching cells form a 2×2 square. The fusion screen shows compatible groups. Crafted structures go on empty Grass."},{"tile":"windmill","title":"Choose your direction","body":"Discoveries has free clues. Follow your goal, or use Build to make buildings and materials. Trade spare stock under Pack → Materials & trade."},{"tile":"grass","title":"Make it yours","body":"Drag to look around and pinch to zoom. Pack → Island tools → Camera & photos offers rotation and pictures. Core play is offline and saves automatically."}]:
  var content: VBoxContainer = h.sheets.card(box)
  var row := HBoxContainer.new(); content.add_child(row)
  var image = h.sheets.art(h,row,step.tile,"",84); image.custom_minimum_size.x = 90
  var body := VBoxContainer.new(); body.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(body)
  h.label(step.title,19,body); h.sheets.caption(h,step.body,body)
 close_button(h,box)

func welcome(h) -> void:
 var box: VBoxContainer = h.modal_content("Your first tiny world")
 h.sheets.art(h,box,"oak","",192)
 h.label("Every world begins with a seed",22,box)
 h.sheets.caption(h,"TUTORIAL · Six steps to your first wildlife habitat. Your island and everything you earn are yours to keep.",box)
 h.sheets.caption(h,"Follow the tutorial card and pointing hand. First, tap the tree for Wood. We will show you one action at a time; Help lets you leave the tutorial whenever you like.",box)
 var examples := HBoxContainer.new(); box.add_child(examples)
 for type in ["oak","water","forest"]:
  var group := VBoxContainer.new(); group.size_flags_horizontal = Control.SIZE_EXPAND_FILL; examples.add_child(group)
  h.sheets.art(h,group,type,"rainforest" if type == "forest" else "",84)
 h.sheets.caption(h,"Drag to look around; pinch to zoom. Your progress saves automatically.",box)
 h.sheets.primary(h,"Let’s grow",func(): h.modal.hide(); h.refresh(),box)

func cost_text(cost: Dictionary) -> String:
 var parts := PackedStringArray()
 for resource in cost: parts.append("%d %s" % [cost[resource],resource.capitalize()])
 return " · ".join(parts)

func privacy(h) -> void:
 var box: VBoxContainer = h.modal_content("Privacy & your data")
 h.label("Your island saves on this device. Core play needs no account or internet connection. Uninstalling may remove your world.",17,box)
 h.label("Diagnostics are off by default. If enabled, the game keeps a limited log of app events and errors. The game does not add payment details, purchase tokens or advertising identifiers to these logs.",17,box)
 h.label("Diagnostics stay on this device in this build." if h.services.telemetry.endpoint == "" else "When diagnostics are enabled, the game can send them securely to the developer's configured service.",17,box)
 h.label("After your first discovery, the game prepares Google ad services during a quiet moment. Where required, consent controls whether ads can be requested. Occasional ads can appear at chapter or expedition breaks; rewarded ads and purchases remain optional. Google handles payments. Ad privacy choices appear in Settings when Google's consent system requires them.",17,box)
 h.label("Sharing a photo opens Android's chooser. You decide whether and where to send it.",17,box)
 h.button("Delete local diagnostics",func():
  h.services.delete_diagnostics()
  h.label(h.services.status,15,box),box)
 close_button(h,box)

func trade(h) -> void:
 var box: VBoxContainer = h.modal_content("Trade materials")
 h.modal_screen = "trade"
 trade_signature = JSON.stringify([h.model.state.inventory,h.model.state.coins])
 h.sheets.chips(h,box,{"coins":h.model.state.coins})
 h.sheets.caption(h,"One material = one Coin. Keep what you need for your next build.",box)
 var grid := GridContainer.new(); grid.columns = 2
 grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",10); box.add_child(grid)
 for resource in ["wood","stone","fiber","clay","iron","brick"]:
  var content: VBoxContainer = h.sheets.card(grid)
  h.sheets.icon(content,resource,76)
  h.label(resource.capitalize(),18,content)
  h.sheets.caption(h,"%d available" % h.model.state.inventory[resource],content)
  var amounts := HBoxContainer.new(); content.add_child(amounts)
  for quantity in [5,20]:
   var action: Button = h.button("%d → %d" % [quantity,quantity],func():
    h.model.campaign.trade(h.model,resource,quantity); h.persist(); h.refresh(); trade(h),amounts)
   action.set_meta("trade_resource",resource); action.set_meta("trade_quantity",quantity)
   action.tooltip_text = "%d %s → %d Coins" % [quantity,resource,quantity]
   action.disabled = h.model.state.inventory[resource] < quantity
 h.button("Back to Workshop",func(): workshop(h),box)
 h.button("Back to materials",func():inventory(h),box)
 close_button(h,box)

func about(h) -> void:
 var box: VBoxContainer = h.modal_content("Pocket Biome · Tiny Expansion")
 h.label("An offline miniature-world discovery game. Version %s. Original synthesized sound and generated diorama artwork. No purchase is needed to finish." % ProjectSettings.get_setting("application/config/version","development"),17,box)
 close_button(h,box)
