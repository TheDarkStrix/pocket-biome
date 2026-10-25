extends RefCounted
const P = preload("res://scripts/GameTheme.gd")
const Icons = preload("res://scripts/UIIcons.gd")
const Stage = preload("res://scripts/DioramaPreview.gd")
func card(parent: Node, color: Color = P.SHEET_CARD) -> VBoxContainer:
 var panel := PanelContainer.new()
 panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 panel.mouse_filter = Control.MOUSE_FILTER_PASS
 var style := P.sheet_panel(color)
 style.content_margin_left = 12; style.content_margin_right = 12
 style.content_margin_top = 12; style.content_margin_bottom = 12
 panel.add_theme_stylebox_override("panel",style)
 parent.add_child(panel)
 var content := VBoxContainer.new(); content.mouse_filter = Control.MOUSE_FILTER_PASS; content.add_theme_constant_override("separation",8)
 panel.add_child(content)
 return content
func art(h, parent: Node, type: String, evolution: String = "", extent: float = 144, world: bool = false) -> Control:
 var stage = Stage.new()
 stage.tile_type = type; stage.evolution = evolution; stage.extent = extent
 stage.world = world; stage.host = h
 parent.add_child(stage)
 return stage
func icon(parent: Node, id: String, span: float = 28) -> TextureRect:
 var image := TextureRect.new()
 image.texture = Icons.texture(id)
 if Icons.LINE.has(id): image.modulate = P.SHEET_CTA
 image.custom_minimum_size = Vector2.ONE*span
 image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 image.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(image)
 return image
func chips(h, parent: Node, values: Dictionary, costs: bool = false) -> HFlowContainer:
 var row := HFlowContainer.new(); row.add_theme_constant_override("h_separation",8); row.add_theme_constant_override("v_separation",6); parent.add_child(row)
 for id in values:
  var group := HBoxContainer.new(); row.add_child(group)
  icon(group,id,26)
  var owned: int = h.model.state.coins if id == "coins" else h.model.state.inventory.get(id,0)
  var amount: Label = h.label("%d/%d" % [owned,values[id]] if costs else str(values[id]),14,group)
  amount.autowrap_mode = TextServer.AUTOWRAP_OFF
  amount.tooltip_text = id.capitalize()+(" · available / required" if costs else "")
  if costs and owned < values[id]: amount.add_theme_color_override("font_color",Color("a94f3c"))
 return row
func primary(h, text: String, run: Callable, parent: Node) -> Button:
 var action: Button = h.button(text,run,parent)
 action.add_theme_stylebox_override("normal",P.sheet_panel(P.SHEET_CTA))
 action.add_theme_color_override("font_color",Color("fffdf2"))
 action.add_theme_color_override("font_hover_color",Color("fffdf2"))
 action.add_theme_stylebox_override("hover",P.sheet_panel(Color("35675d")))
 return action
func caption(h, text: String, parent: Node) -> Label:
 var result: Label = h.label(text,12,parent)
 result.add_theme_color_override("font_color",P.SHEET_MUTED)
 return result
func action_card(h, title: String, detail: String, type: String, evolution: String, run: Callable, parent: Node, world: bool = false) -> Button:
 var action: Button = h.button(title,run,parent)
 action.tooltip_text = title
 action.custom_minimum_size = Vector2(200,232*h.model.state.text_scale)
 var normal := P.sheet_panel(P.SHEET_CARD)
 action.add_theme_stylebox_override("normal",normal)
 for state in ["font_color","font_hover_color","font_pressed_color","font_disabled_color"]: action.add_theme_color_override(state,Color(0,0,0,0))
 var content := VBoxContainer.new()
 content.mouse_filter = Control.MOUSE_FILTER_IGNORE
 action.add_child(content); content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 content.offset_left = 10; content.offset_right = -10; content.offset_top = 8; content.offset_bottom = -8
 content.add_theme_constant_override("separation",4)
 art(h,content,type,evolution,136,world)
 var name: Label = h.label(title,16,content)
 name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 name.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var sub: Label = caption(h,detail,content)
 sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
 content.minimum_size_changed.connect(func(): action.custom_minimum_size.y = maxf(232*h.model.state.text_scale,content.get_combined_minimum_size().y+16))
 return action
func setting(h, name: String, enabled: bool, icon_id: String, run: Callable, parent: Node) -> Button:
 var row: Button = h.button(name+(" · On" if enabled else " · Off"),run,parent)
 row.alignment = HORIZONTAL_ALIGNMENT_LEFT
 h.button_icon(row,icon_id)
 var style := P.sheet_panel(P.SHEET_CARD)
 style.content_margin_right = 60
 row.add_theme_stylebox_override("normal",style)
 var toggle := preload("res://scripts/ToggleMark.gd").new(); toggle.enabled = enabled
 row.add_child(toggle)
 toggle.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
 toggle.offset_left = -48; toggle.offset_right = -8; toggle.offset_top = -12; toggle.offset_bottom = 12
 return row
func energy(h, parent: Node) -> void:
 var strip := HBoxContainer.new(); strip.add_theme_constant_override("separation",12); parent.add_child(strip)
 var ring = preload("res://scripts/AbilityMedallion.gd").new()
 ring.custom_minimum_size = Vector2(58,58); strip.add_child(ring)
 ring.display(h.model.state.energy,h.model.state.settings.reduced_motion)
 var text := VBoxContainer.new(); text.size_flags_horizontal = Control.SIZE_EXPAND_FILL; strip.add_child(text)
 h.label("%d / 200 energy" % h.model.state.energy,21,text)
 caption(h,"Choose an ability, then preview its area on your island.",text)
func power(h, parent: Node, power_id: String, description: String) -> Button:
 var content := card(parent,{"rain":Color("e3efea"),"heat":Color("f4e6d6"),"frost":Color("e4edf0")}[power_id])
 var row := HBoxContainer.new(); content.add_child(row)
 var diagram = preload("res://scripts/PulseDiagram.gd").new(); diagram.power = power_id; diagram.reduced_motion = h.model.state.settings.reduced_motion; row.add_child(diagram)
 var body := VBoxContainer.new(); body.size_flags_horizontal = Control.SIZE_EXPAND_FILL; body.size_flags_vertical = Control.SIZE_SHRINK_CENTER; row.add_child(body)
 h.label(power_id.capitalize(),22,body)
 caption(h,description,body)
 var button: Button = primary(h,power_id.capitalize()+" · 100 energy",func(): h.modal.hide(); h.target(power_id),content)
 button.disabled = h.model.state.energy < 100 or (power_id == "frost" and h.model.state.chapter < 2)
 if power_id == "frost" and h.model.state.chapter < 2: caption(h,"Unlocks in Chapter 2",content)
 return button

func tab(h, text: String, selected: bool, run: Callable, parent: Node) -> Button:
 var action: Button = h.button(text,run,parent)
 var style := P.quiet()
 style.set_corner_radius_all(0)
 style.border_color = P.SHEET_CTA
 style.border_width_bottom = 3 if selected else 0
 action.add_theme_stylebox_override("normal",style)
 action.custom_minimum_size.x = maxf(96,action.get_theme_font("font").get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,h.scaled_font(17)).x+28)
 return action

func scroll_skin(scroll: ScrollContainer) -> void:
 var bar := scroll.get_v_scroll_bar()
 var track := StyleBoxFlat.new(); track.bg_color = Color(0,0,0,0)
 track.content_margin_left = 2; track.content_margin_right = 2
 var thumb := track.duplicate(); thumb.bg_color = Color(0.26,0.47,0.43,0.35); thumb.set_corner_radius_all(3)
 bar.add_theme_stylebox_override("scroll",track)
 for state in ["grabber","grabber_highlight","grabber_pressed"]: bar.add_theme_stylebox_override(state,thumb)
