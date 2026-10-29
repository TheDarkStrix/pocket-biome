extends RefCounted
var craft_quantity := 1
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
 var box: VBoxContainer = h.modal_content("Field Journal · %d / 20" % h.model.state.discoveries.size())
 var chapter: Dictionary = h.model.campaign.chapter_definition(h.model)
 h.label("CHAPTER %d · %s" % [h.model.state.chapter,chapter.name],17,box)
 h.label(h.model.campaign.chapter_progress(h.model).split("\n")[-1],15,box)
 h.label("Shape the land. Discover its secrets.",14,box)
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
 h.button("Back to Codex",func(): journal(h),box)
 close_button(h,box)

func workshop(h) -> void:
 var box: VBoxContainer = h.modal_content("Workshop")
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
 var less: Button = h.button("−",func(): craft_quantity = maxi(1,craft_quantity-1); workshop(h),quantity_row)
 less.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN; less.custom_minimum_size.x = h.touch_height()
 var quantity_label: Label = h.label("Batch · %d" % craft_quantity,17,quantity_row)
 quantity_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var more: Button = h.button("+",func(): craft_quantity = mini(3,craft_quantity+1); workshop(h),quantity_row)
 more.size_flags_horizontal = Control.SIZE_SHRINK_END; more.custom_minimum_size.x = h.touch_height()
 var tabs := ScrollContainer.new(); tabs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; tabs.custom_minimum_size.y = h.touch_height()+3; box.add_child(tabs)
 var categories := HBoxContainer.new(); tabs.add_child(categories)
 for category in ["All","Land","Structures","Materials"]:
  h.sheets.tab(h,category,workshop_filter == category,func(): workshop_filter = category; workshop(h),categories)
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
   h.model.craft(recipe.id,craft_quantity); h.persist(); h.refresh(); workshop(h),content)
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
 close_button(h,box)

func update_live(h) -> void:
 if not h.modal.visible: return
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
  workshop(h)
  h.modal_scroll.set_deferred("scroll_vertical",offset)
  return
 if is_instance_valid(workshop_stock):
  var stock: Dictionary = h.model.state.inventory
  workshop_stock.text = "Wood %d · Stone %d · Fiber %d\nClay %d · Iron %d · Brick %d · Dew %d" % [stock.wood,stock.stone,stock.fiber,stock.clay,stock.iron,stock.brick,stock.star_dew]
 for job in h.model.state.jobs:
  if workshop_jobs.has(job.id): workshop_jobs[job.id].text = "× %d · %ds" % [job.get("quantity",1),ceili(maxf(0,job.until-h.model.state.time))]

func world(h) -> void:
 var box: VBoxContainer = h.modal_content("Your Living World")
 h.label("%d land tiles · Next plot %d coins" % [h.model.state.tiles.size(),h.model.cost()],17,box)
 h.button("Find something to try",func(): h.open_ideas(),box)
 var actions := GridContainer.new(); actions.columns = 2
 box.add_child(actions)
 var selected: Dictionary = h.model.state.tiles[h.model.origin(h.selected)]
 h.sheets.action_card(h,"Inspect biome","Conditions & possibilities",selected.type,selected.evolution,func(): h.modal.hide(); h.open_inspector(h.model.origin(h.selected)),actions)
 h.sheets.action_card(h,"Center island","Return to your landscape","grass","",func(): h.modal.hide(); h.frame_world(),actions,true)
 h.sheets.action_card(h,"Fuse sanctuary","Four matching tiles","forest","grove",func(): h.fusion_dialog(),actions)
 h.sheets.action_card(h,"Photo mode","Frame, save & share","grass","",func(): h.modal.hide(); h.begin_photo(),actions,true)
 var turns := HBoxContainer.new(); box.add_child(turns)
 h.button("Rotate left",func(): h.modal.hide(); h.rotate_camera(-1),turns)
 h.button("Rotate right",func(): h.modal.hide(); h.rotate_camera(1),turns)
 h.label("Four isometric views · twist two fingers to turn; pinch to zoom.",14,box)
 var at: String = h.model.origin(h.selected)
 if at != "":
  var tile: Dictionary = h.model.state.tiles[at]
  if h.model.config.tiles[tile.type].category == "structure":
   var level: int = tile.get("level",1)
   if level < 3 and h.model.config.tiles[tile.type].get("upgradeable",true):
    h.button("Upgrade to level %d · %s" % [level+1,cost_text(h.model.config.upgrades[str(level)])],func():
     h.model.campaign.upgrade_structure(h.model,at)
     h.persist(); h.refresh(); world(h),box)
   if h.model.config.tiles[tile.type].get("interval",0) > 0 or h.model.config.effects.has(tile.type):
    h.button("Pause / resume selected automation",func():
     h.model.campaign.toggle_automation(h.model,at)
     h.persist(); h.refresh(); world(h),box)
  if at not in ["0,0","1,0","0,1"] and tile.size == 1 and (tile.type != "grass" or tile.evolution != ""):
   h.button("Restore selected tile to Meadow…",func():
    var confirm: VBoxContainer = h.modal_content("Restore this plot?")
    h.label("This removes the current biome. Structures return as level-one blueprints; their upgrades are lost. Discoveries stay in your journal. Starting harvest nodes are protected.",17,confirm)
    h.button("Confirm restoration",func():
     h.model.campaign.retire(h.model,at)
     h.modal.hide(); h.persist(); h.refresh(),confirm)
    close_button(h,confirm),box)
 h.button("World Pulse abilities",func(): h.pulse_selector(),box)
 var event: Dictionary = h.model.state.event
 if event.until > 0:
  h.label("Dusk Tide · %ds · %d/2 restored" % [ceili(event.until-h.model.state.time),event.cleared.size()],18,box)
 else:
  var event_button: Button = h.button("Begin optional Dusk Tide",func():
   h.model.campaign.start_event(h.model)
   h.persist(); h.refresh(); world(h),box)
  event_button.disabled = h.model.state.chapter < 3 or h.model.state.time < event.next_at or not h.model.state.settings.challenge_events
  h.label("Available after Chapter 3 and five active minutes. Ignoring it never destroys progress.",14,box)
 if h.model.state.chapter >= 2:
  h.button("Day / Dusk preview",func(): h.model.state.cosmetic = "dusk" if h.model.state.cosmetic == "day" else "day"; h.persist(); h.refresh(),box)
 close_button(h,box)
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
 h.button("How to play",func(): tutorial(h),box)
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
 for step in [{"tile":"oak","title":"Collect & expand","body":"Tap ready nodes for materials and Coins. Tap a cloud to compare three cards."},{"tile":"water","title":"Find living combinations","body":"Try Water beside Oak. Hold land or tap its callout to inspect conditions; Settings → Tile conditions explains them."},{"tile":"crystal","title":"Change your world","body":"Pulse previews a cross-shaped area. Tap its center again to confirm; canceling spends nothing."},{"tile":"forest","title":"Create a sanctuary","body":"Four matching cells form a 2×2 square. The fusion screen shows compatible groups. Crafted structures go on empty Grass."},{"tile":"windmill","title":"Choose your direction","body":"The Journal has free discovery clues. Tap your goal for ideas. Workshop trades spare materials and crafts automation."},{"tile":"grass","title":"Make it yours","body":"Drag to pan, pinch to zoom, twist for quarter turns. World offers rotation and photo controls. Core play is offline and saves automatically."}]:
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
 h.sheets.caption(h,"Tap the Oak to collect Wood and Coins. Then open a cloud beside it and choose Water.",box)
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
 h.label("Optional ads and purchases connect to Google when you choose to connect store services. Google handles payments. Connecting also enables occasional ads at chapter breaks. Ad privacy choices appear in Settings when Google's consent system requires them.",17,box)
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
 close_button(h,box)
