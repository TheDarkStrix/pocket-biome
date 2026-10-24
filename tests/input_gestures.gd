extends SceneTree
const Controller = preload("res://scripts/InputController.gd")
var taps := 0
var inspections := 0
var pans := 0
var zooms := 0
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
 print("INPUT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
