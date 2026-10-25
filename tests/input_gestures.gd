extends SceneTree
const Controller = preload("res://scripts/InputController.gd")
var taps := 0
var inspections := 0
var pans := 0
var zooms := 0
var turns := []
var checks := 0
var failures := 0
var c = Controller.new()
var area := Rect2(0,200,540,480)
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func touch(id: int, pressed: bool, pos: Vector2, time: float, canceled: bool = false) -> void:
 var e := InputEventScreenTouch.new()
 e.index = id
 e.pressed = pressed
 e.position = pos
 e.canceled = canceled
 c.feed(e,area,time)
func drag(id: int, pos: Vector2) -> void:
 var e := InputEventScreenDrag.new()
 e.index = id
 e.position = pos
 c.feed(e,area,0.1)
func _init() -> void:
 c.tapped.connect(func(_p): taps += 1)
 c.inspected.connect(func(_p): inspections += 1)
 c.panned.connect(func(_p): pans += 1)
 c.zoomed.connect(func(_p): zooms += 1)
 c.rotated.connect(func(step): turns.append(step))
 touch(0,true,Vector2(250,400),0)
 touch(0,false,Vector2(250,400),0.1)
 check(taps == 1,"single tap")
 touch(0,true,Vector2(250,400),1)
 touch(0,false,Vector2(250,400),1.6)
 check(inspections == 1 and taps == 1,"long press inspects without harvesting")
 touch(0,true,Vector2(250,400),2)
 drag(0,Vector2(255,400))
 check(pans == 0,"jitter below threshold")
 drag(0,Vector2(280,400))
 touch(0,false,Vector2(280,400),2.1)
 check(pans == 1 and taps == 1,"drag suppresses tap")
 touch(0,true,Vector2(220,400),3)
 touch(1,true,Vector2(320,400),3.05)
 drag(1,Vector2(350,400))
 touch(1,false,Vector2(350,400),3.1)
 touch(0,false,Vector2(220,400),3.15)
 check(zooms == 1 and taps == 1,"pinch release never harvests")
 touch(0,true,Vector2(250,100),4)
 touch(0,false,Vector2(250,400),4.1)
 check(taps == 1,"UI-origin touch cannot become world tap")
 touch(0,true,Vector2(250,400),5)
 touch(0,false,Vector2(250,400),5.1,true)
 check(taps == 1,"OS cancellation cannot harvest")
 touch(0,true,Vector2(250,400),6)
 c.reset()
 touch(0,false,Vector2(250,400),6.1)
 check(taps == 1,"modal/focus reset drops pending gesture")
 touch(0,true,Vector2(250,400),7)
 touch(1,true,Vector2(350,400),7.05)
 for angle in [70,160,250,340]: drag(1,Vector2(250,400)+Vector2.from_angle(deg_to_rad(angle))*100)
 touch(1,false,Vector2(350,400),7.5); touch(0,false,Vector2(250,400),7.6)
 check(turns == [1,1,1,1],"full two-finger twist produces four stable quarter turns")
 check(taps == 1 and c.pointers.is_empty(),"rotation releases cannot harvest or leave gesture pointers")
 turns.clear()
 touch(0,true,Vector2(250,400),8); touch(1,true,Vector2(350,400),8.05)
 drag(1,Vector2(250,400)+Vector2.from_angle(deg_to_rad(20))*110)
 touch(1,false,Vector2(350,400),8.2); touch(0,false,Vector2(250,400),8.3)
 check(turns.is_empty(),"small pinch-angle jitter cannot rotate the camera")
 print("INPUT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
