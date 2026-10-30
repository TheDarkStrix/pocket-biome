extends Control
# Presentation-only energy ring. It never generates energy or implies timed regeneration.
const Palette = preload("res://scripts/GameTheme.gd")
var energy := 0
var shown := 0.0
var response: Tween
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 custom_minimum_size = Vector2(46,46)
func display(value: int, reduced: bool) -> void:
 energy = value
 if response != null and response.is_valid(): response.kill()
 if reduced: shown = value
 elif not is_equal_approx(shown,value):
  response = create_tween()
  response.tween_method(func(v: float): shown = v; queue_redraw(),shown,float(value),0.35)
 queue_redraw()
func _draw() -> void:
 var side := minf(size.x,size.y)
 var center := size/2
 preload("res://scripts/ToolMedallion.gd").paint(self,"rain",Rect2(center-Vector2.ONE*side/2,Vector2.ONE*side))
 if shown > 0: draw_arc(center,side*0.445,-PI/2,-PI/2+TAU*clampf(shown/200,0,1),64,Palette.ACCENT,2,true)
