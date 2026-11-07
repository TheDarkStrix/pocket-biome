extends Control
var host
func _process(_delta: float) -> void:queue_redraw()
func _draw() -> void:
 if not is_instance_valid(host):return
 var rect: Rect2=host.guidance_ui.target(host)
 if not rect.has_area():return
 var dp: float=host.logical_per_dp()
 var still: bool=host.model.state.settings.reduced_motion
 var bounce: float=0.0 if still else sin(host.ambient_time*3)*3*dp
 var at:=Vector2(rect.get_center().x,rect.position.y-7*dp+bounce)
 var color:=Color("ffe2a0")
 if host.modal.visible or rect.size.x>30*dp:
  draw_rect(rect.grow(3*dp),color,false,2*dp)
  return
 draw_style_box(preload("res://scripts/GameTheme.gd").floating(Color(0.12,0.2,0.2,0.15),5),rect.grow(3*dp))
 draw_line(at-Vector2(0,24*dp),at,color,4*dp,true)
 draw_polyline(PackedVector2Array([at+Vector2(-7,-9)*dp,at,at+Vector2(7,-9)*dp]),color,3*dp,true)
 # A small pointing finger beside the arrow, drawn with the same accessible scale.
 var hand:=at+Vector2(11,-17)*dp
 draw_line(hand,hand+Vector2(0,-12)*dp,color,4*dp,true)
 draw_arc(hand+Vector2(4,1)*dp,6*dp,-PI*0.6,PI*0.8,16,color,3*dp,true)
