extends PanelContainer
# Details stay in the inspector/help instead of a permanent statistical HUD.
signal explanation_requested
const Palette = preload("res://scripts/GameTheme.gd")
var selected_conditions := {}
var settings_mode := false
func _ready() -> void:
 custom_minimum_size = Vector2(48,48)
 mouse_filter = Control.MOUSE_FILTER_STOP
 focus_mode = Control.FOCUS_ALL
 tooltip_text = "Settings" if settings_mode else "Tile conditions · tap to learn, hold land to inspect"
 var style := preload("res://scripts/MaterialUI.gd").frame()
 style.content_margin_left = 12; style.content_margin_right = 12
 style.content_margin_top = 12; style.content_margin_bottom = 12
 add_theme_stylebox_override("panel",style)
 var icon := TextureRect.new()
 icon.texture = preload("res://scripts/UIIcons.gd").texture("settings" if settings_mode else "ecology")
 icon.custom_minimum_size = Vector2(24,24)
 icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(icon)
func _gui_input(event: InputEvent) -> void:
 if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or event.is_action_pressed("ui_accept"):
  accept_event(); explanation_requested.emit()
func display(tile: Dictionary, _reduced: bool = false) -> void:
 selected_conditions = tile.dna.duplicate()
