extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(360,780),"dp":1.5},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size = display.size
   var h = preload("res://tests/fixtures/MobileMain.gd").new()
   h.display_dp = display.dp
   h.store.path = "user://mobile-layout-tests.json"
   root.add_child(h)
   h.model = preload("res://scripts/WorldModel.gd").new()
   h.model.state.text_scale = scale
   h.apply_settings(); h.refresh(); h.start_play(); h.modal.hide()
   await process_frame
   await process_frame
   h.apply_layout()
   await process_frame
   var context := "%s text=%s" % [display.size,scale]
   check(h.world_rect().size.y > 100,"usable world region at "+context)
   check(h.hud.get_global_rect().end.y <= h.world_rect().position.y+1,"header does not cover the world at "+context)
   var captions_fit := true
   for action in h.stacked_buttons:
    var caption: Label = action.get_meta("icon_caption")
    captions_fit = captions_fit and caption.get_line_count() <= 2 and caption.get_global_rect().end.y <= action.get_global_rect().end.y+1
    captions_fit = captions_fit and caption.get_minimum_size().x <= action.size.x
   check(captions_fit,"footer icons/captions fit without splitting words or clipping at "+context)
   check(h.bottom.get_global_rect().end.y <= h.get_viewport_rect().end.y,"footer remains inside portrait screen at "+context)
   h.queue_free()
   await process_frame
 print("MOBILE LAYOUT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
