extends Control
# Finite, presentation-only reward flourish. Buttons and saved rewards remain immediate.
var host
var elapsed := 0.0
var still := false
static func attach(h, box: VBoxContainer, finale: bool = false) -> Control:
 var banner := preload("res://scripts/MilestoneCelebration.gd").new()
 banner.host = h
 banner.still = h.model.state.settings.reduced_motion
 banner.custom_minimum_size = Vector2(0,86 if not finale else 106)
 banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
 banner.set_meta("milestone_celebration",true)
 box.add_child(banner)
 banner.set_process(not banner.still)
 return banner
func _process(delta: float) -> void:
 if not is_instance_valid(host) or not is_visible_in_tree():
  set_process(false); return
 if host.suspended or host.services.fullscreen_ad: return
 if host.model.state.settings.reduced_motion: still = true; set_process(false); queue_redraw(); return
 elapsed = minf(2.4,elapsed+minf(delta,0.1))
 queue_redraw()
 if elapsed >= 2.4: set_process(false)
func _draw() -> void:
 var center := size*Vector2(0.5,0.52)
 var progress := 1.0 if still else clampf(elapsed/2.4,0,1)
 var arrive := 1.0 if still else smoothstep(0,0.2,progress)
 draw_circle(center,31,Color(0.32,0.63,0.48,0.1))
 for side in [-1,1]:
  var stem := PackedVector2Array()
  for i in range(15):
   var angle := lerpf(0.22,2.45,i/14.0)
   stem.append(center+Vector2(side*sin(angle)*39,cos(angle)*31))
  draw_polyline(stem,Color(0.42,0.61,0.36,arrive),1.5,true)
  for i in range(6):
   var angle := 0.45+i*0.31
   var at := center+Vector2(side*sin(angle)*39,cos(angle)*31)
   var drift := Vector2(side*8,-6)*(1-arrive)
   var color := Color(0.55,0.69,0.39,arrive)
   draw_colored_polygon(PackedVector2Array([at+drift,at+Vector2(side*9,-7)+drift,at+Vector2(side*10,1)+drift]),color)
 preload("res://scripts/UIIcons.gd").draw(self,"ecology",center,40,Color(1,1,1,arrive))
 if not still and progress < 1:
  for i in range(16):
   var angle := i*TAU/16
   var p := center+Vector2(cos(angle),sin(angle)*0.55)*(18+progress*80)
   var alpha := sin(progress*PI)*(1-progress)
   draw_line(p,p+Vector2(cos(angle+0.7),sin(angle+0.7))*5,Color(0.78,0.65,0.3,alpha),2,true)
