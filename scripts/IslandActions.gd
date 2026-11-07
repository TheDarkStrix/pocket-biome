extends RefCounted
const Eco = preload("res://scripts/EcologyDirector.gd")
var strip: HBoxContainer
var move_button: Button
var overlay := "off"
func build(h) -> void:
 strip = HBoxContainer.new(); strip.add_theme_constant_override("separation",4); h.ui_root.add_child(strip)
 h.button("Inspect",func(): h.open_inspector(h.model.origin(h.selected)),strip)
 h.button("Tend",func(): tend(h),strip)
 move_button = h.button("Move",func(): h.layout_ui.begin(h,h.model.origin(h.selected)),strip)
 h.button("Goal",func(): show_goal(h),strip)
 for action in strip.get_children():
  action.set_meta("base_font",12); action.add_theme_font_size_override("font_size",h.scaled_font(12))
  action.custom_minimum_size.x = 0
 strip.hide()
func update(h) -> void:
 if not is_instance_valid(strip): return
 strip.visible = not h.corridor_ui.showing() and h.game_hud.selection_time > 0 and not h.launch_menu and not h.photo_mode and not h.modal.visible and h.targeting == "" and h.placement_blueprint == "" and h.layout_ui.source == ""
 strip.size = Vector2(h.layout.world.size.x-16,h.touch_height())
 strip.position = Vector2(h.layout.world.position.x+8,h.layout.world.end.y-strip.size.y-70)
 move_button.disabled = not preload("res://scripts/LayoutTools.gd").movable(h.model,h.model.origin(h.selected))
func show_goal(h) -> void:
 h.journey_ui.goal(h)
func observe(h) -> void:
 h.modal.hide(); h.frame_world(); h.model.message = "Watch the highlighted influences. Harvesting and machines keep their ordinary active-time schedules."
 h.notice_time = 5
 h.refresh()
func inspect_tools(h, at: String, box: VBoxContainer) -> void:
 h.label("Live climate",19,box)
 var reading: Label = h.label(Eco.outlook(h.model,at),14,box)
 h.inspection_view["outlook"] = reading
 if h.model.state.tiles[at].evolution != "": h.sheets.caption(h,"Recorded form · "+h.tile_title(h.model.state.tiles[at])+". Discoveries stay in Discoveries when conditions change. You can deliberately cultivate another qualifying form below.",box)
 h.button("Moisture overlay",func(): overlay = "moisture"; h.modal.hide(); h.refresh(),box)
 h.button("Heat overlay",func(): overlay = "heat"; h.modal.hide(); h.refresh(),box)
 h.button("Habitat links",func(): overlay = "habitats"; h.modal.hide(); h.refresh(),box)
 h.button("Hide overlays",func(): overlay = "off"; h.modal.hide(); h.refresh(),box)
 if h.model.state.tiles[at].get("cultivated",false): h.button("Resume natural discovery",func(): transact(h,at,""); h.open_inspector(at),box)
 for recipe in h.model.config.recipes:
  if not Eco.qualifies(h.model,h.model.state.tiles[at],recipe) or recipe.id == h.model.state.tiles[at].evolution: continue
  h.button("Cultivate "+recipe.name,func(): confirm_form(h,at,recipe),box)
func confirm_form(h, at: String, recipe: Dictionary) -> void:
 var box: VBoxContainer = h.modal_content("Cultivate "+recipe.name+"?")
 h.sheets.art(h,box,h.model.state.tiles[at].type,recipe.id,140)
 h.label("Keep this form while experimenting with its climate. Conditions, harvest cooldowns and land ownership stay intact. Existing discoveries and rewards are kept; this form will not automatically promote until you resume natural discovery.",16,box)
 h.sheets.primary(h,"Confirm cultivation",func(): transact(h,at,recipe.id); h.modal.hide(); h.refresh(),box)
 h.button("Keep current form",func(): h.open_inspector(at),box)
func transact(h, at: String, recipe_id: String) -> void:
 var before: Dictionary = h.model.state.duplicate(true)
 var changed: bool = Eco.release(h.model,at) if recipe_id == "" else Eco.cultivate(h.model,at,recipe_id)
 if changed and not h.store.save_state(h.model.state): h.model.state = before; h.model.message = "Save failed. Your previous form was kept."
 h.refresh()
func climate_settings(h) -> void:
 var box: VBoxContainer = h.modal_content("How your climate grows")
 h.label("Living climate approaches a local balance: Water, warmth and care shape stable conditions; removing a source lets conditions recover. Classic growth keeps the original accumulating rules. Switching preserves discoveries, land and production timers.",16,box)
 h.sheets.caption(h,"Current · "+("Living climate" if Eco.balanced(h.model) else "Classic growth"),box)
 h.sheets.primary(h,"Use "+("Classic growth" if Eco.balanced(h.model) else "Living climate"),func():
  var before: Dictionary = h.model.state.duplicate(true)
  h.model.state.ecology_rules = "classic" if Eco.balanced(h.model) else "balanced"
  if not h.store.save_state(h.model.state): h.model.state = before; h.model.message = "Save failed. Climate rules were kept."
  h.modal.hide(); h.refresh(),box)
 h.campaign_ui.close_button(h,box)
func draw(h) -> void:
 if overlay == "off" or h.photo_mode or h.launch_menu: return
 var projects = preload("res://scripts/HabitatProjects.gd")
 if overlay == "habitats":
  for id in projects.IDS.slice(0,4):
   var habitat := projects.inspect(h.model,id)
   for cell in habitat.cells:
    h.draw_plot_outline(h.entity_screen(cell),h.zoom_level,Color("a6d6a1"),2)
   if habitat.cells.size() > 1:
    for cell in habitat.cells.slice(1): h.draw_line(h.entity_screen(habitat.anchor),h.entity_screen(cell),Color("a6d6a1"),2,true)
  return
 for key in h.model.state.tiles:
  var tile: Dictionary = h.model.state.tiles[key]
  if tile.has("owner"): continue
  var at: Vector2 = h.entity_screen(key)
  var amount: int = tile.dna[overlay]
  var color := Color("81cce3") if overlay == "moisture" else Color("e6a46f")
  h.draw_circle(at,8*h.zoom_level,color.darkened(0.45))
  h.draw_arc(at,10*h.zoom_level,-PI/2,-PI/2+TAU*maxf(0.01,amount/100.0),18,color,3,true)
  h.draw_string(ThemeDB.fallback_font,at+Vector2(-14,-14),str(amount),HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)

func deploy_prompt(h, blueprint: String, at: String) -> void:
 var tile: Dictionary = h.model.state.tiles.get(at,{})
 if tile.is_empty() or tile.has("owner") or tile.get("type") != "grass" or tile.evolution != "" or tile.size != 1 or not tile.get("boosts",[]).is_empty() or not h.model.state.pending.is_empty() or h.model.state.event.targets.has(at):
  h.model.message = "Choose empty Meadow outside active effects. Your blueprint is kept."; h.refresh(); return
 var identity: int = tile.id
 var box: VBoxContainer = h.modal_content("Place "+blueprint.capitalize()+" here?")
 h.modal_screen = "deploy_confirm"
 h.sheets.art(h,box,blueprint,"",140)
 h.label(Eco.consequences(h.model,blueprint,at),16,box)
 h.sheets.caption(h,"Uses one finished blueprint. No additional materials or Coins are charged. Confirm only when the neighbors fit your plan.",box)
 h.sheets.primary(h,"Confirm blueprint placement",func():
  var before: Dictionary = h.model.state.duplicate(true)
  if h.model.state.tiles.get(at,{}).get("id",-1) != identity or not h.model.deploy(blueprint,at):
   h.model.message = "This plot changed. Choose another empty Meadow."; h.modal.hide(); h.refresh(); return
  if not h.store.save_state(h.model.state):
   h.model.state = before; h.model.message = "Save failed. Your blueprint and plot were kept."
   h.label(h.model.message,15,box); h.refresh(); return
  h.placement_blueprint = ""; h.services.event("structure_placed"); h.playtest.record("blueprint_placed",{"type":blueprint}); h.modal.hide(); h.refresh(),box)
 h.button("Choose another plot",func(): h.modal.hide(); h.refresh(),box)

func tend(h) -> void:
 var box: VBoxContainer = h.modal_content("Tend your living island")
 h.sheets.primary(h,"Living Corridors · route spring water",func(): h.corridor_ui.show(h),box)
 h.button("Care tools · channel, shade & warmth",func(): h.care_ui.show_tools(h),box)
 h.campaign_ui.close_button(h,box)
