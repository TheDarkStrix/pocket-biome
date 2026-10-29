extends Button
var chosen := false
func _draw() -> void:
 if not chosen: return
 var b := Rect2(Vector2(3,3),size-Vector2(6,6))
 var points := PackedVector2Array([b.position+Vector2(7,0),Vector2(b.end.x-7,b.position.y),b.position+Vector2(b.size.x,7),b.end-Vector2(0,7),b.end-Vector2(7,0),Vector2(b.position.x+7,b.end.y),Vector2(b.position.x,b.end.y-7),b.position+Vector2(0,7),b.position+Vector2(7,0)])
 for band in range(3,0,-1): draw_polyline(points,Color(1,0.78,0.37,0.12),float(band*3),true)
 draw_polyline(points,Color("ffdf90"),1.5,true)
