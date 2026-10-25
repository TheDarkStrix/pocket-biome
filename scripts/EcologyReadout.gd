extends PanelContainer
# Read-only selected-tile telemetry; the model remains authoritative.
signal explanation_requested
const Palette = preload("res://scripts/GameTheme.gd")
var bars := {}
var values := {}
var captions := {}
func _ready() -> void:
 custom_minimum_size.x = 180
 mouse_filter = Control.MOUSE_FILTER_STOP
 focus_mode = Control.FOCUS_ALL
 tooltip_text = "Tile conditions · tap for help"
 add_theme_stylebox_override("panel",Palette.floating(Palette.PAPER))
 var column := VBoxContainer.new()
 column.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(column)
 var title := Label.new()
 title.text = "TILE CONDITIONS"
 title.set_meta("base_font",12)
 title.add_theme_color_override("font_color",Palette.MUTED)
 title.mouse_filter = Control.MOUSE_FILTER_IGNORE
 column.add_child(title)
 for spec in [{"id":"moisture","icon":"rain","color":Color("8baac2")},{"id":"heat","icon":"heat","color":Color("c4b18e")}]:
  var row := HBoxContainer.new()
  row.mouse_filter = Control.MOUSE_FILTER_IGNORE
  var group := VBoxContainer.new()
  group.mouse_filter = Control.MOUSE_FILTER_IGNORE
  column.add_child(group)
  group.add_child(row)
  var icon := TextureRect.new()
  icon.texture = preload("res://scripts/UIIcons.gd").texture(spec.icon)
  icon.custom_minimum_size = Vector2(18,18)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_child(icon)
  var caption := Label.new()
  caption.text = spec.id.capitalize()
  caption.set_meta("base_font",12)
  caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_child(caption)
  captions[spec.id] = caption
  var bar := ProgressBar.new()
  bar.max_value = 100
  bar.show_percentage = false
  bar.custom_minimum_size = Vector2(64,5)
  bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
  bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
  var track := StyleBoxFlat.new(); track.bg_color = Color("424d58")
  var fill := track.duplicate(); fill.bg_color = spec.color
  bar.add_theme_stylebox_override("background",track)
  bar.add_theme_stylebox_override("fill",fill)
  group.add_child(bar)
  var value := Label.new()
  value.text = "0"
  value.set_meta("base_font",17)
  value.custom_minimum_size.x = 36
  value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
  value.add_theme_color_override("font_color",Palette.INK)
  value.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_child(value)
  bars[spec.id] = bar; values[spec.id] = value
 var help := Label.new()
 help.text = "Selected tile · tap to learn"
 help.set_meta("base_font",11)
 help.mouse_filter = Control.MOUSE_FILTER_IGNORE
 help.add_theme_color_override("font_color",Palette.MUTED)
 column.add_child(help)
func _gui_input(event: InputEvent) -> void:
 if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or event.is_action_pressed("ui_accept"):
  accept_event()
  explanation_requested.emit()
func display(tile: Dictionary, reduced: bool = false) -> void:
 for attribute in bars:
  var bar: ProgressBar = bars[attribute]
  var target: float = tile.dna[attribute]
  if bar.get_meta("target_value",-1.0) != target:
   var old = bar.get_meta("value_tween") if bar.has_meta("value_tween") else null
   if old is Tween and old.is_valid(): old.kill()
   bar.set_meta("target_value",target)
   if reduced: bar.value = target
   else:
    var tween := create_tween()
    bar.set_meta("value_tween",tween)
    tween.tween_property(bar,"value",target,0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  values[attribute].text = str(int(tile.dna[attribute]))
  values[attribute].tooltip_text = attribute.capitalize()+" · score out of 100"
