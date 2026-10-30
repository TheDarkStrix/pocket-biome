extends PanelContainer
var divider := false
func _draw() -> void:
 if divider:
  draw_line(Vector2(0,5),Vector2(0,size.y-5),Color("9f8c63"),1,true)
  draw_line(Vector2(1,5),Vector2(1,size.y-5),Color(0,0,0,0.45),1,true)
