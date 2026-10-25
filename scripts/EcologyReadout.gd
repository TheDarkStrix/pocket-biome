extends PanelContainer
# Read-only selected-tile telemetry; the model remains authoritative.
const Palette = preload("res://scripts/GameTheme.gd")
var bars := {}
var values := {}
func _ready() -> void:
 custom_minimum_size.x = 180
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_theme_stylebox_override("panel",Palette.panel(Palette.PAPER))
 var column := VBoxContainer.new()
 column.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(column)
 var title := Label.new()
 title.text = "LOCAL DNA"
 title.set_meta("base_font",12)
 title.add_theme_color_override("font_color",Palette.MUTED)
 title.mouse_filter = Control.MOUSE_FILTER_IGNORE
 column.add_child(title)
 for spec in [{"id":"moisture","icon":"rain","color":Color("8baac2")},{"id":"heat","icon":"heat","color":Color("c4b18e")}]:
  var row := HBoxContainer.new()
  row.mouse_filter = Control.MOUSE_FILTER_IGNORE
  column.add_child(row)
  var icon := TextureRect.new()
  icon.texture = preload("res://scripts/UIIcons.gd").texture(spec.icon)
  icon.custom_minimum_size = Vector2(24,24)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_child(icon)
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
  row.add_child(bar)
  var value := Label.new()
  value.text = "0"
  value.set_meta("base_font",17)
  value.custom_minimum_size.x = 36
  value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
  value.add_theme_color_override("font_color",Palette.INK)
  value.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_child(value)
  bars[spec.id] = bar; values[spec.id] = value
func display(tile: Dictionary) -> void:
 for attribute in bars:
  bars[attribute].value = tile.dna[attribute]
  values[attribute].text = str(int(tile.dna[attribute]))
  values[attribute].tooltip_text = attribute.capitalize()+" DNA · 0–100"
