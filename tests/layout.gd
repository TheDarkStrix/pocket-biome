extends SceneTree
const Layout = preload("res://scripts/SafeLayout.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 for screen in [Vector2(1080,1920),Vector2(1080,2400),Vector2(720,1280),Vector2(1440,3120)]:
  var safe := Rect2(0,100,screen.x,screen.y-180)
  var rect = Layout.logical_safe_rect(Vector2(540,960),screen,safe)
  var regions = Layout.regions(rect)
  check(rect.position.y > 0 and rect.end.y < 960,"cutout and gesture inset")
  check(rect.encloses(regions.top) and rect.encloses(regions.bottom),"HUD inside safe area")
  check(regions.world.position.y > regions.top.end.y and regions.world.end.y < regions.bottom.position.y,"world excludes controls")
  check(rect.encloses(regions.modal),"scroll modal inside safe area")
 check(Layout.logical_safe_rect(Vector2(540,960),Vector2.ZERO,Rect2()) == Rect2(0,0,540,960),"headless safe fallback")
 print("LAYOUT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
