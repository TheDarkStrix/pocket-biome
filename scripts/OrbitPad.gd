extends Control
# A touch-safe camera handle; dragging it cannot collect or spend anything.
var host: Node
var held := false
var moved := false
var painted_yaw:=INF
func _process(_delta:float) -> void:
 if is_instance_valid(host.orbit_world) and not is_equal_approx(painted_yaw,host.orbit_world.yaw):
  painted_yaw=host.orbit_world.yaw;queue_redraw()
func _notification(what:int) -> void:
 if what in [NOTIFICATION_FOCUS_EXIT,NOTIFICATION_APPLICATION_FOCUS_OUT]:held=false
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP;focus_mode=Control.FOCUS_ALL
 tooltip_text="Drag compass to orbit and tilt · two fingers also twist/zoom"
func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  held=event.pressed
  if held:moved=false
  elif not moved:host.model.message="Drag the compass to look around. Drag land to pan; pinch or twist two fingers.";host.refresh()
  accept_event()
 elif event is InputEventMouseMotion and held:
  if event.relative.length()>0.2:
   moved=true;host.orbit_world.orbit(-event.relative.x*0.012,event.relative.y*0.008);host.queue_redraw()
  accept_event()
 elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
  host.orbit_world.orbit(-0.15 if event.is_action_pressed("ui_left") else 0.15);accept_event()
 elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
  host.orbit_world.orbit(0,0.07 if event.is_action_pressed("ui_up") else -0.07);accept_event()
func _draw() -> void:
 var c:=size/2;var r:=minf(size.x,size.y)*0.45
 draw_circle(c,r,Color(0.1,0.17,0.18,0.7));draw_arc(c,r,0,TAU,48,Color("b7a67b"),1.5,true)
 var needle:=Vector2.from_angle(-host.orbit_world.yaw-PI/2)*r*0.68
 draw_line(c-needle*0.55,c+needle,Color("e6d5a7"),2,true)
 var wing:=needle.orthogonal().normalized()*r*0.17
 draw_colored_polygon(PackedVector2Array([c+needle,c+needle*0.38+wing,c+needle*0.38-wing]),Color("f2dfac"))
 for mark in range(4):
  var direction:=Vector2.from_angle(mark*PI/2);draw_line(c+direction*r*0.82,c+direction*r*0.96,Color("b7a67b"),1,true)
