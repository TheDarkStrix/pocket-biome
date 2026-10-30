extends RefCounted
# Native Godot controls, with presentation kept separate from gameplay authority.
const Palette = preload("res://scripts/GameTheme.gd")
const Icons = preload("res://scripts/UIIcons.gd")
const SurfaceKit = preload("res://scripts/MaterialUI.gd")
var resource_values := {}
var resource_names := {}
var land: Label
var chapter_caption: Label
var quest_progress: Label
var selected_art: Control
var selected_name: Label
var selected_status: Label
var harvest_meter: ProgressBar
var pulse_ring: Control
var pulse_amount: Label
var pulse_caption: Label
var inspect_action: Button
var build_action: Button
var selection_time := 0.0
var quest_slot: MarginContainer

func icon(id: String, extent: float, parent: Node) -> TextureRect:
 var result := TextureRect.new()
 result.texture = Icons.texture(id)
 result.custom_minimum_size = Vector2.ONE*extent
 result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 result.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(result)
 return result

func surface(parent: Node, color: Color = Palette.PAPER, radius: int = 18) -> PanelContainer:
 var panel := PanelContainer.new()
 panel.add_theme_stylebox_override("panel",Palette.floating(color,radius))
 parent.add_child(panel)
 return panel

func build(h, root: Control) -> void:
 h.hud = VBoxContainer.new()
 h.hud.add_theme_constant_override("separation",4)
 root.add_child(h.hud)
 var rail := PanelContainer.new(); rail.add_theme_stylebox_override("panel",SurfaceKit.frame(Color.WHITE,6)); h.hud.add_child(rail)
 var resources := HBoxContainer.new()
 resources.add_theme_constant_override("separation",0)
 rail.add_child(resources)
 h.chapter_dial = preload("res://scripts/ChapterDial.gd").new()
 resources.add_child(h.chapter_dial); h.chapter_dial.hide()
 for id in ["wood","stone","coins"]:
  var cell := preload("res://scripts/ResourceCell.gd").new(); cell.divider = id != "wood"; cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  cell.size_flags_stretch_ratio = 1; cell.custom_minimum_size.x = 0
  cell.add_theme_stylebox_override("panel",StyleBoxEmpty.new()); resources.add_child(cell)
  var inset := MarginContainer.new(); inset.add_theme_constant_override("margin_left",6); inset.add_theme_constant_override("margin_right",6); cell.add_child(inset)
  var group := HBoxContainer.new(); group.add_theme_constant_override("separation",4); inset.add_child(group)
  icon(id,56,group)
  var numbers := VBoxContainer.new(); numbers.add_theme_constant_override("separation",0); numbers.size_flags_horizontal = Control.SIZE_EXPAND_FILL; group.add_child(numbers)
  var name: Label = h.label(id.to_upper(),10,numbers); name.autowrap_mode = TextServer.AUTOWRAP_OFF; SurfaceKit.lettering(name)
  resource_names[id] = name
  if id == "coins":
   h.inventory = RichTextLabel.new(); h.inventory.fit_content = true; h.inventory.scroll_active = false
   h.inventory.autowrap_mode = TextServer.AUTOWRAP_OFF
   h.inventory.mouse_filter = Control.MOUSE_FILTER_IGNORE; h.inventory.size_flags_horizontal = Control.SIZE_EXPAND_FILL
   h.inventory.add_theme_color_override("default_color",SurfaceKit.CREAM); numbers.add_child(h.inventory)
  else:
   var amount: Label = h.label("0",18,numbers); SurfaceKit.lettering(amount)
   amount.autowrap_mode = TextServer.AUTOWRAP_OFF; resource_values[id] = amount
 land = h.label("",14,h.hud); land.hide()
 chapter_caption = h.label("",11,h.hud); chapter_caption.hide()
 quest_slot = MarginContainer.new(); h.hud.add_child(quest_slot)
 var quest_panel := PanelContainer.new(); quest_panel.add_theme_stylebox_override("panel",SurfaceKit.frame(Color.WHITE,6)); quest_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN; quest_slot.add_child(quest_panel)
 var quest_row := HBoxContainer.new(); quest_row.add_theme_constant_override("separation",4); quest_panel.add_child(quest_row)
 var quest_arrow: Button = h.button("",h.open_ideas,quest_row)
 quest_arrow.size_flags_horizontal = Control.SIZE_SHRINK_END
 quest_arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
 quest_arrow.custom_minimum_size.x = h.touch_height()
 h.button_icon(quest_arrow,"codex")
 quest_arrow.add_theme_stylebox_override("normal",Palette.quiet())
 quest_arrow.add_theme_constant_override("icon_max_width",42)
 quest_arrow.tooltip_text = "Chapter goal and things to try"
 var quest_body := VBoxContainer.new(); quest_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL; quest_body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
 quest_body.custom_minimum_size.y = h.touch_height(); quest_body.alignment = BoxContainer.ALIGNMENT_CENTER
 quest_body.mouse_filter = Control.MOUSE_FILTER_STOP
 quest_body.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
   quest_body.accept_event(); h.open_ideas())
 quest_row.add_child(quest_body)
 h.objective = h.label("",13,quest_body)
 SurfaceKit.lettering(h.objective)
 h.objective.max_lines_visible = 2
 h.objective.custom_minimum_size.y = 0
 h.objective.mouse_filter = Control.MOUSE_FILTER_STOP; h.objective.focus_mode = Control.FOCUS_ALL
 h.objective.tooltip_text = "Tap for useful next steps"
 h.objective.gui_input.connect(func(event: InputEvent):
  if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or event.is_action_pressed("ui_accept"):
   h.objective.accept_event(); h.open_ideas())
 quest_progress = h.label("",11,quest_body)
 SurfaceKit.lettering(quest_progress)
 quest_progress.mouse_filter = Control.MOUSE_FILTER_STOP
 quest_progress.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
   quest_progress.accept_event(); h.open_ideas())
 # A short-lived callout beside the touched tile, not a permanent selection dashboard.
 inspect_action = h.button("",func(): h.open_inspector(h.model.origin(h.selected)),root)
 inspect_action.custom_minimum_size = Vector2(208,h.touch_height())
 inspect_action.size = Vector2(208,maxf(62,h.touch_height()))
 inspect_action.tooltip_text = "Inspect the selected biome"
 inspect_action.add_theme_stylebox_override("normal",Palette.floating(Color("314d54"),24))
 var selection := HBoxContainer.new(); selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
 inspect_action.add_child(selection); selection.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 selection.offset_left = 10; selection.offset_right = -10; selection.offset_top = 6; selection.offset_bottom = -6
 selected_art = preload("res://scripts/TileThumbnail.gd").new(); selected_art.extent = 36; selected_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER; selection.add_child(selected_art)
 var description := VBoxContainer.new(); description.mouse_filter = Control.MOUSE_FILTER_IGNORE; description.size_flags_horizontal = Control.SIZE_EXPAND_FILL; selection.add_child(description)
 selected_name = h.label("",13,description)
 selected_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
 selected_name.autowrap_mode = TextServer.AUTOWRAP_OFF; selected_name.clip_text = true
 selected_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
 selected_status = h.label("",11,description); selected_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
 selected_status.autowrap_mode = TextServer.AUTOWRAP_OFF; selected_status.clip_text = true
 harvest_meter = meter(Palette.READY,description)
 h.info = h.label("",16,description); h.info.hide()
 inspect_action.hide()
 h.bottom = VBoxContainer.new(); h.bottom.add_theme_constant_override("separation",4); root.add_child(h.bottom)
 h.draft_button = h.button("Resume draft",func():
  if h.placement_blueprint != "":
   h.placement_blueprint = ""; h.model.message = "Placement canceled. Blueprint kept."; h.refresh()
  elif h.targeting != "": h.cancel_target()
  elif h.model.state.chapter == 3 and h.model.state.stats.fusions == 0: h.fusion_dialog()
  else: h.draft(),h.bottom)
 h.draft_button.custom_minimum_size.x = 240
 h.draft_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
 h.draft_button.add_theme_stylebox_override("normal",SurfaceKit.frame())
 h.button_icon(h.draft_button,"world")
 var navigation := HBoxContainer.new(); navigation.add_theme_constant_override("separation",4); h.bottom.add_child(navigation)
 for action in [{"name":"Pack","icon":"pack","run":func(): h.campaign_ui.pack(h)}, {"name":"Build","icon":"craft","run":func(): h.campaign_ui.workshop(h)}, {"name":"Pulse","icon":"rain","run":h.pulse_selector}]:
  var item: Button = h.button(action.name,action.run,navigation)
  item.set_meta("primary_dock",action.name == "Build")
  h.button_icon(item,action.icon,true)
  item.add_theme_stylebox_override("normal",Palette.quiet())
  item.add_theme_stylebox_override("hover",Palette.quiet())
  item.add_theme_stylebox_override("pressed",Palette.quiet())
  if action.name == "Build": build_action = item
  if action.name == "Pulse":
   h.pulse_button = item
   pulse_caption = item.get_meta("icon_caption")
   var old_icon: Control = item.get_meta("icon_image")
   old_icon.hide()
   pulse_ring = preload("res://scripts/AbilityMedallion.gd").new()
   old_icon.get_parent().symbol = ""
   old_icon.get_parent().add_child(pulse_ring)
   pulse_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
   pulse_ring.custom_minimum_size = Vector2.ONE*108*minf(1.25,h.logical_per_dp())
   pulse_amount = h.label("",12,item); pulse_amount.hide()
 h.pulse_bar = meter(Palette.ACCENT,h.bottom); h.pulse_bar.max_value = 200; h.pulse_bar.hide()
 h.hud.minimum_size_changed.connect(func(): h.call_deferred("apply_layout"))
 h.bottom.minimum_size_changed.connect(func(): h.call_deferred("apply_layout"))

func fit_header(h, _width: float, _conditions: Vector2) -> void:
 quest_slot.add_theme_constant_override("margin_right",ceili(h.touch_height())+12)
 quest_slot.custom_minimum_size.x = 0
 h.objective.custom_minimum_size.x = maxf(80,minf(240*minf(1.2,h.logical_per_dp()),_width-h.touch_height()*2-66))
 quest_slot.custom_minimum_size.y = 0

func display_goal(h, goal: String) -> void:
 var lines := goal.split("\n",true,1)
 h.objective.text = lines[0]
 quest_progress.visible = lines.size() > 1
 quest_progress.text = lines[1] if lines.size() > 1 else ""

func show_selection() -> void:
 selection_time = 5.0

func update_selection(h, delta: float = 0.0) -> void:
 selection_time = maxf(0,selection_time-delta)
 inspect_action.visible = selection_time > 0 and not h.launch_menu and not h.photo_mode and not h.modal.visible
 var area: Rect2 = h.world_rect()
 var anchor: Vector2 = h.entity_screen(h.model.origin(h.selected))+Vector2(20,-100)
 inspect_action.position = Vector2(clampf(anchor.x,area.position.x,area.end.x-inspect_action.size.x),clampf(anchor.y,area.position.y,area.end.y-inspect_action.size.y))

func meter(color: Color, parent: Node) -> ProgressBar:
 var bar := ProgressBar.new()
 bar.max_value = 100; bar.show_percentage = false
 bar.custom_minimum_size.y = 4
 bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var track := StyleBoxFlat.new(); track.bg_color = Color("434952"); track.set_corner_radius_all(2)
 var fill := track.duplicate(); fill.bg_color = color
 bar.add_theme_stylebox_override("background",track); bar.add_theme_stylebox_override("fill",fill)
 parent.add_child(bar)
 return bar

func hub_action(h, title: String, detail: String, symbol: String, action: Callable, parent: Node) -> Button:
 var button: Button = h.button(title,action,parent)
 h.button_icon(button,symbol)
 var style := Palette.quiet()
 style.content_margin_top = 10
 style.content_margin_bottom = 38
 button.add_theme_stylebox_override("normal",style)
 button.custom_minimum_size.y = maxf(80,h.touch_height()+40)
 var description: Label = h.label(detail,12,button)
 description.mouse_filter = Control.MOUSE_FILTER_IGNORE
 description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 description.max_lines_visible = 2
 description.add_theme_color_override("font_color",Palette.MUTED)
 description.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 description.offset_left = 10; description.offset_right = -10
 description.offset_top = -43; description.offset_bottom = -8
 return button

func display(h) -> void:
 var ink: Color = SurfaceKit.CREAM
 h.inventory.add_theme_color_override("default_color",ink)
 h.objective.add_theme_color_override("font_color",ink)
 quest_progress.add_theme_color_override("font_color",ink)
 for value in resource_values.values(): value.add_theme_color_override("font_color",ink)
 h.inventory.add_theme_font_size_override("normal_font_size",h.scaled_font(18))
 h.inventory.clear()
 h.inventory.add_text(h.compact_amount(h.model.state.coins))
 h.inventory.tooltip_text = "%d Coins" % h.model.state.coins
 land.text = "%d/36" % h.model.state.tiles.size()
 for id in resource_values:
  resource_values[id].text = h.compact_amount(h.model.state.inventory[id])
  resource_values[id].tooltip_text = "%s · %d" % [id.capitalize(),h.model.state.inventory[id]]
 chapter_caption.text = "CHAPTER %d" % h.model.state.chapter
 pulse_amount.text = "%d/200" % h.model.state.energy
 pulse_amount.add_theme_color_override("font_color",Palette.ACCENT if h.model.state.energy >= 100 else Palette.MUTED)
 pulse_ring.display(h.model.state.energy,h.model.state.settings.reduced_motion)

 var key: String = h.model.origin(h.selected)
 if key == "": return
 var tile: Dictionary = h.model.state.tiles[key]
 selected_art.tile_type = tile.type; selected_art.evolution = tile.evolution; selected_art.queue_redraw()
 selected_name.text = h.tile_title(tile)
 selected_name.tooltip_text = h.tile_title(tile)
 var production: Dictionary = h.model.production(tile)
 var remaining: int = ceili(maxf(0,tile.ready-h.model.state.time))
 selected_status.text = "Ready to collect" if remaining == 0 and production.resource != "" else "Ready in %ds" % remaining if production.resource != "" else "Inspect this biome"
 selected_status.add_theme_color_override("font_color",Palette.READY if remaining == 0 and production.resource != "" else Palette.MUTED)
 harvest_meter.visible = production.resource != ""
 if production.resource != "": harvest_meter.value = clampf(100*(1-maxf(0,tile.ready-h.model.state.time)/float(production.cooldown)),0,100)
