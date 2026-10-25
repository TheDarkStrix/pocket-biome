extends Control
var enabled := false
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 custom_minimum_size = Vector2(40,24)
func _draw() -> void:
 var style := StyleBoxFlat.new()
 style.bg_color = Color("487f70") if enabled else Color("b8c5ba")
 style.set_corner_radius_all(12)
 draw_style_box(style,Rect2(0,0,40,24))
 draw_circle(Vector2(28 if enabled else 12,12),9,Color("fffdf2"))
