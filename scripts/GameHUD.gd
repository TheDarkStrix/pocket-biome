extends RefCounted
# Native Godot controls, with presentation kept separate from gameplay authority.
const Palette = preload("res://scripts/GameTheme.gd")
const Icons = preload("res://scripts/UIIcons.gd")
var resource_values := {}
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
 h.hud.add_theme_constant_override("separation",10)
 root.add_child(h.hud)
 var ledger := HBoxContainer.new()
 ledger.add_theme_constant_override("separation",8)
 h.hud.add_child(ledger)
 h.chapter_dial = preload("res://scripts/ChapterDial.gd").new()
 ledger.add_child(h.chapter_dial)
 var coins := surface(ledger,Palette.PAPER,26)
 coins.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var coin_row := HBoxContainer.new(); coins.add_child(coin_row)
 icon("coins",30,coin_row)
 h.inventory = RichTextLabel.new()
 h.inventory.fit_content = true
 h.inventory.scroll_active = false
 h.inventory.autowrap_mode = TextServer.AUTOWRAP_OFF
 h.inventory.mouse_filter = Control.MOUSE_FILTER_IGNORE
 h.inventory.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 coin_row.add_child(h.inventory)
 var land_panel := surface(ledger,Palette.PAPER,26)
 var land_row := HBoxContainer.new(); land_panel.add_child(land_row)
 icon("world",20,land_row)
 land = h.label("4/36",15,land_row)
 land.autowrap_mode = TextServer.AUTOWRAP_OFF
 land.tooltip_text = "Occupied land · maximum 36 plots"
 var materials := HBoxContainer.new()
 materials.add_theme_constant_override("separation",8)
 h.hud.add_child(materials)
 for id in ["wood","stone","fiber"]:
  var group := HBoxContainer.new()
  group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  materials.add_child(group)
  icon(id,26,group)
  var amount: Label = h.label("0",16,group)
  amount.autowrap_mode = TextServer.AUTOWRAP_OFF
  resource_values[id] = amount
 quest_slot = MarginContainer.new()
 h.hud.add_child(quest_slot)
 var quest := surface(quest_slot)
 var quest_row := HBoxContainer.new(); quest_row.add_theme_constant_override("separation",8); quest.add_child(quest_row)
 var quest_body := VBoxContainer.new(); quest_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL; quest_row.add_child(quest_body)
 chapter_caption = h.label("YOUR NEXT DISCOVERY",11,quest_body)
 chapter_caption.add_theme_color_override("font_color",Palette.BUILD)
 h.objective = h.label("",16,quest_body)
 h.objective.max_lines_visible = -1
 h.objective.custom_minimum_size.y = h.touch_height()
 h.objective.mouse_filter = Control.MOUSE_FILTER_STOP
 h.objective.focus_mode = Control.FOCUS_ALL
 h.objective.tooltip_text = "Tap for useful next steps"
 h.objective.gui_input.connect(func(event: InputEvent):
  if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or event.is_action_pressed("ui_accept"):
   h.objective.accept_event(); h.open_ideas())
 quest_progress = h.label("",14,quest_body)
 quest_progress.add_theme_color_override("font_color",Palette.MUTED)
 quest_progress.mouse_filter = Control.MOUSE_FILTER_STOP
 quest_progress.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
   quest_progress.accept_event(); h.open_ideas())
 var quest_arrow: Button = h.button("›",h.open_ideas,quest_row)
 quest_arrow.size_flags_horizontal = Control.SIZE_SHRINK_END
 quest_arrow.custom_minimum_size.x = h.touch_height()
 quest_arrow.add_theme_stylebox_override("normal",Palette.quiet())
 quest_arrow.tooltip_text = "Explore next steps"
 h.bottom = VBoxContainer.new()
 h.bottom.add_theme_constant_override("separation",10)
 root.add_child(h.bottom)
 var context := HBoxContainer.new()
 context.add_theme_constant_override("separation",10)
 h.bottom.add_child(context)
 var selected_panel := surface(context)
 selected_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var selected_row := HBoxContainer.new(); selected_row.add_theme_constant_override("separation",10); selected_panel.add_child(selected_row)
 selected_art = preload("res://scripts/TileThumbnail.gd").new()
 selected_art.extent = 62
 selected_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
 selected_row.add_child(selected_art)
 var description := VBoxContainer.new()
 description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 description.size_flags_vertical = Control.SIZE_SHRINK_CENTER
 selected_row.add_child(description)
 var caption: Label = h.label("SELECTED BIOME",10,description)
 caption.add_theme_color_override("font_color",Palette.MUTED)
 selected_name = h.label("Oak",19,description)
 selected_name.autowrap_mode = TextServer.AUTOWRAP_OFF
 selected_name.clip_text = true
 selected_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
 selected_status = h.label("Ready to collect",13,description)
 selected_status.max_lines_visible = 2
 harvest_meter = meter(Palette.READY,description)
 # Keep the scene's public info handle and accessibility text, without duplicating visible copy.
 h.info = h.label("",16,description); h.info.hide()
 inspect_action = h.button("›",func(): h.open_inspector(h.model.origin(h.selected)),selected_row)
 inspect_action.tooltip_text = "Inspect the selected biome"
 inspect_action.size_flags_horizontal = Control.SIZE_SHRINK_END
 inspect_action.custom_minimum_size.x = h.touch_height()
 inspect_action.add_theme_stylebox_override("normal",Palette.quiet())
 h.pulse_button = h.button("",h.pulse_selector,context)
 h.pulse_button.tooltip_text = "World Pulse · preview Rain, Heat and Frost"
 h.pulse_button.size_flags_horizontal = Control.SIZE_SHRINK_END
 h.pulse_button.add_theme_stylebox_override("normal",Palette.floating(Color("342f43"),22))
 var ability := VBoxContainer.new()
 ability.mouse_filter = Control.MOUSE_FILTER_IGNORE
 h.pulse_button.add_child(ability)
 ability.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 ability.offset_top = 9; ability.offset_bottom = -9; ability.offset_left = 8; ability.offset_right = -8
 ability.alignment = BoxContainer.ALIGNMENT_CENTER
 ability.add_theme_constant_override("separation",2)
 pulse_ring = preload("res://scripts/AbilityMedallion.gd").new()
 ability.add_child(pulse_ring)
 pulse_caption = h.label("World Pulse",12,ability)
 pulse_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 pulse_amount = h.label("0/200",14,ability)
 pulse_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 for child in ability.get_children(): child.mouse_filter = Control.MOUSE_FILTER_IGNORE
 h.pulse_bar = meter(Palette.ACCENT,ability); h.pulse_bar.max_value = 200; h.pulse_bar.hide()
 h.draft_button = h.button("Resume draft",func():
  if h.placement_blueprint != "":
   h.placement_blueprint = ""; h.model.message = "Placement canceled. Blueprint kept."; h.refresh()
  elif h.targeting != "": h.cancel_target()
  elif h.model.state.chapter == 3 and h.model.state.stats.fusions == 0: h.fusion_dialog()
  else: h.draft(),h.bottom)
 h.draft_button.custom_minimum_size.x = 220
 h.button_icon(h.draft_button,"world")
 var dock := surface(h.bottom,Color("272c34"),24)
 var navigation := HBoxContainer.new()
 navigation.add_theme_constant_override("separation",6)
 dock.add_child(navigation)
 for action in [{"name":"Journal","icon":"codex","run":func(): h.campaign_ui.journal(h)}, {"name":"Build","icon":"craft","run":func(): h.campaign_ui.workshop(h)}, {"name":"World","icon":"world","run":func(): h.campaign_ui.world(h)}, {"name":"Menu","icon":"settings","run":func(): h.campaign_ui.settings(h)}]:
  var item: Button = h.button(action.name,action.run,navigation)
  item.set_meta("primary_dock",action.name == "Build")
  h.button_icon(item,action.icon,true)
  item.add_theme_stylebox_override("normal",Palette.quiet())
  if action.name == "Build": build_action = item
 # Optional actions can change height after text is shaped by their container.
 # Reserve the new bounds before camera framing or touch routing uses them.
 h.hud.minimum_size_changed.connect(func(): h.call_deferred("apply_layout"))
 h.bottom.minimum_size_changed.connect(func(): h.call_deferred("apply_layout"))

func fit_header(h, width: float, conditions: Vector2) -> void:
 # Currency/materials span the screen. Only the quest shares a row with conditions.
 # This prevents large-text amounts from competing with the right-hand module.
 h.chapter_dial.visible = width >= 420
 quest_slot.add_theme_constant_override("margin_right",ceili(conditions.x)+12)
 quest_slot.custom_minimum_size.y = conditions.y

func display_goal(h, goal: String) -> void:
 var lines := goal.split("\n",true,1)
 h.objective.text = lines[0]
 quest_progress.visible = lines.size() > 1
 quest_progress.text = lines[1] if lines.size() > 1 else ""

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
 var style := Palette.floating(Palette.PAPER_ALT)
 style.content_margin_top = 18
 style.content_margin_bottom = 48
 button.add_theme_stylebox_override("normal",style)
 button.custom_minimum_size.y = maxf(112,h.touch_height()+64)
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
 h.inventory.add_theme_font_size_override("normal_font_size",h.scaled_font(22))
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
 h.pulse_button.custom_minimum_size.y = maxf(106,104*h.model.state.text_scale)
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
