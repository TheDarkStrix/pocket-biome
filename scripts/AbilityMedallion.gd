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
 var center := size/2
 var radius := minf(size.x,size.y)/2-3
 draw_circle(center,radius,Color("413b54"))
 draw_arc(center,radius,-PI/2,TAU-PI/2,48,Color("6b627c"),2,true)
 if shown > 0: draw_arc(center,radius,-PI/2,-PI/2+TAU*clampf(shown/200,0,1),48,Palette.ACCENT,3,true)
 var color: Color = Palette.ACCENT if energy >= 100 else Palette.MUTED
 # Original three-wave emblem for the area-changing ability.
 for line in range(3):
  var points := PackedVector2Array()
  for step in range(17):
   var x := -10+20.0*step/16
   points.append(center+Vector2(x,(line-1)*6+sin(x/10*PI)*2))
  draw_polyline(points,color,1.8,true)
