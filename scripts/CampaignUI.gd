extends RefCounted
var craft_quantity := 1
var codex_filter := "All"
var focus_id := ""
var workshop_jobs := {}
var workshop_stock: Label
var workshop_signature := ""
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
  var tab: Button = h.button(("✓ " if codex_filter == family else "")+family,func(): codex_filter = family; journal(h),row)
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
  var style: StyleBoxFlat = h.panel_style(Color("30373e")); style.border_color = h.rarity_color(recipe.rarity)
  panel.add_theme_stylebox_override("panel",style)
  grid.add_child(panel)
  var content := VBoxContainer.new(); panel.add_child(content)
  var icon = Thumbnail.new(); icon.tile_type = recipe.types[0]; icon.evolution = recipe.id; icon.extent = 112
  icon.silhouette = not h.model.state.discoveries.has(recipe.id)
  content.add_child(icon)
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
 var art = Thumbnail.new(); art.tile_type = recipe.types[0]; art.evolution = id; art.extent = 210; art.silhouette = not unlocked
 box.add_child(art)
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
 h.label("First discovery · %d Coins, 1 Star Dew, up to 100 Pulse energy" % recipe.reward,15,box)
 h.button("Back to Codex",func(): journal(h),box)
 close_button(h,box)

func workshop(h) -> void:
 var box: VBoxContainer = h.modal_content("Workshop")
 h.modal_screen = "workshop"
 workshop_jobs.clear()
 workshop_signature = JSON.stringify([h.model.state.jobs,h.model.state.blueprints,h.model.state.inventory,h.model.state.coins])
 workshop_stock = h.label("Wood %d · Stone %d · Fiber %d\nClay %d · Iron %d · Brick %d · Dew %d" % [h.model.state.inventory.wood,h.model.state.inventory.stone,h.model.state.inventory.fiber,h.model.state.inventory.clay,h.model.state.inventory.iron,h.model.state.inventory.brick,h.model.state.inventory.star_dew],17,box)
 var quantity_row := HBoxContainer.new()
 box.add_child(quantity_row)
 h.button("−",func(): craft_quantity = maxi(1,craft_quantity-1); workshop(h),quantity_row)
 var quantity_label: Label = h.label("Quantity · %d" % craft_quantity,18,quantity_row)
 quantity_label.custom_minimum_size.x = 150
 quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 h.button("+",func(): craft_quantity = mini(3,craft_quantity+1); workshop(h),quantity_row)
 h.label("Three project slots. Place crafted blueprints on an empty Grass tile. Every essential tile can be shaped here, even when your world is full.",15,box)
 for job in h.model.state.jobs:
  workshop_jobs[job.id] = h.label("In progress: %s · %ds" % [job.recipe,ceili(maxf(0,job.until-h.model.state.time))],16,box)
 for recipe in h.model.config.crafting:
  var panel := PanelContainer.new()
  panel.add_theme_stylebox_override("panel",h.panel_style(Color("30373e")))
  box.add_child(panel)
  var row := HBoxContainer.new()
  row.add_theme_constant_override("separation",10)
  panel.add_child(row)
  if recipe.has("tile"):
   var art = Thumbnail.new(); art.tile_type = recipe.tile; art.extent = 92
   art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
   row.add_child(art)
  else:
   var icon := TextureRect.new()
   icon.texture = preload("res://scripts/UIIcons.gd").texture(recipe.get("resource","brick"))
   icon.custom_minimum_size = Vector2(64,64)
   icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
   icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
   row.add_child(icon)
  var content := VBoxContainer.new()
  content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  row.add_child(content)
  h.label(recipe.name,18,content)
  var ingredients := HFlowContainer.new()
  ingredients.add_theme_constant_override("h_separation",10)
  content.add_child(ingredients)
  var missing := PackedStringArray()
  if not h.model.campaign.has_structure(h.model,recipe.requires): missing.append("Build "+recipe.requires.capitalize())
  for resource in recipe.cost:
   var owned: int = h.model.state.coins if resource == "coins" else h.model.state.inventory.get(resource,0)
   var required: int = recipe.cost[resource]*craft_quantity
   var chip := HBoxContainer.new()
   ingredients.add_child(chip)
   var material := TextureRect.new()
   material.texture = preload("res://scripts/UIIcons.gd").texture(resource)
   material.custom_minimum_size = Vector2(28,28)
   material.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
   material.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
   chip.add_child(material)
   var amount: Label = h.label("%d / %d" % [owned,required],16,chip)
   amount.autowrap_mode = TextServer.AUTOWRAP_OFF
   amount.tooltip_text = resource.capitalize()+" · available / required"
   if owned < required:
    amount.add_theme_color_override("font_color",Color("d9b4a1"))
    missing.append("%d more %s" % [required-owned,resource])
  if h.model.state.jobs.size() >= 3: missing.append("All project slots are busy")
  var seconds: int = ceili(h.model.campaign.crafting_seconds(h.model,recipe)*craft_quantity)
  var craft_button: Button = h.button("Craft × %d · %ds" % [craft_quantity,seconds],func():
   h.model.craft(recipe.id,craft_quantity)
   h.persist(); h.refresh(); workshop(h),content)
  craft_button.disabled = not missing.is_empty()
  if not missing.is_empty(): h.label("Needs · "+", ".join(missing),14,content)
 h.label("Ready blueprints",20,box)
 for type in h.model.state.blueprints:
  if h.model.state.blueprints[type] < 1: continue
  h.button("Place %s × %d" % [type.capitalize(),h.model.state.blueprints[type]],func():
   h.placement_blueprint = type
   h.model.message = "Tap an empty Grass tile to place "+type.capitalize()+". Tap Cancel placement to stop."
   h.modal.hide(); h.refresh(),box)
 h.label("Trade materials · 1 coin each",20,box)
 for resource in ["wood","stone","fiber","clay","iron","brick"]:
  var button: Button = h.button("Trade 5 "+resource,func():
   h.model.campaign.trade(h.model,resource,5)
   h.persist(); h.refresh(); workshop(h),box)
  button.disabled = h.model.state.inventory[resource] < 5
 close_button(h,box)
func update_live(h) -> void:
 if not h.modal.visible or h.modal_screen != "workshop": return
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
  if workshop_jobs.has(job.id): workshop_jobs[job.id].text = "In progress: %s × %d · %ds" % [job.recipe,job.get("quantity",1),ceili(maxf(0,job.until-h.model.state.time))]

func world(h) -> void:
 var box: VBoxContainer = h.modal_content("Your Living World")
 h.label("%d land tiles · Next plot %d coins" % [h.model.state.tiles.size(),h.model.cost()],17,box)
 var actions := GridContainer.new(); actions.columns = 2
 box.add_child(actions)
 h.button("Inspect biome",func(): h.modal.hide(); h.open_inspector(h.model.origin(h.selected)),actions)
 h.button("Center island",func(): h.modal.hide(); h.frame_world(),actions)
 h.button("Fuse sanctuary",func(): h.fusion_dialog(),actions)
 h.button("Photo mode",func(): h.modal.hide(); h.begin_photo(),actions)
 for index in range(actions.get_child_count()):
  h.button_icon(actions.get_child(index),["codex","world","craft","settings"][index])
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
  h.button(names[id]+(" · On" if h.model.state.settings[id] else " · Off"),func():
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
 h.label("Core play is offline. Diagnostics are off by default. Store services require connectivity. No mandatory ads or purchases.",15,box)
 h.button("Store & optional rewards",func(): h.services_ui(),box)
 h.button("How to play",func(): tutorial(h),box)
 close_button(h,box)

func styled_slider(h, low: float, high: float, step: float, value: float, parent: Node) -> HSlider:
 var slider := HSlider.new()
 slider.min_value = low; slider.max_value = high; slider.step = step; slider.value = value
 slider.custom_minimum_size.y = h.touch_height()
 var track := StyleBoxFlat.new()
 track.bg_color = Color("424d58"); track.set_corner_radius_all(4)
 track.content_margin_top = 4; track.content_margin_bottom = 4
 var fill := track.duplicate(); fill.bg_color = Color("8ea995")
 slider.add_theme_stylebox_override("slider",track)
 slider.add_theme_stylebox_override("grabber_area",fill)
 slider.add_theme_stylebox_override("grabber_area_highlight",fill)
 slider.add_theme_icon_override("grabber",preload("res://assets/ui/slider_knob.svg"))
 slider.add_theme_icon_override("grabber_highlight",preload("res://assets/ui/slider_knob.svg"))
 parent.add_child(slider)
 return slider

func tutorial(h) -> void:
 var box: VBoxContainer = h.modal_content("A tiny world, yours to grow")
 for text in ["1 · Tap Oak, Stone and Fiber to collect materials and coins. Ready nodes can be collected again after their cooldown.","2 · Tap a cloud and choose one of three cards. Water beside Oak creates your first living transformation.","3 · Hold a tile to see its conditions, neighbors and transformation requirements. Tap Tile conditions at the top right for an explanation. Every discovery has a free hint in the Journal.","4 · Select a World Pulse, preview the highlighted area and tap its center to confirm. Canceling spends nothing.","5 · Four compatible cells in a square can fuse. Craft structures and place blueprints on empty meadows. Your first three resource nodes are always protected.","6 · Follow the chapter goals in the Journal. Play offline; progress saves automatically."]:
  h.label(text,17,box)
 close_button(h,box)

func welcome(h) -> void:
 var box: VBoxContainer = h.modal_content("Your first tiny world")
 h.label("Start with four floating plots. Tap the Oak to collect Wood and earn Coins.",20,box)
 h.label("Then tap a cloud beside the Oak and choose Water. Watch what living neighbors can create together.",18,box)
 h.label("Drag to look around, pinch to zoom, and hold any tile for its secrets. Your world saves automatically.",16,box)
 h.button("Let’s grow",func(): h.modal.hide(); h.refresh(),box)

func cost_text(cost: Dictionary) -> String:
 var parts := PackedStringArray()
 for resource in cost: parts.append("%d %s" % [cost[resource],resource.capitalize()])
 return " · ".join(parts)
