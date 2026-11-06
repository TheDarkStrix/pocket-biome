extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const River = preload("res://scripts/LivingCorridors.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func fixture():
 var m = Model.new(); m.state.ecology_rules = "balanced"; m.state.habitat_projects = ["shaded_pond"]; m.state.discoveries = ["rainforest"]; m.state.settings.tutorial_seen = true
 for entry in [[Vector2i(2,1),"water"],[Vector2i(3,1),"grass"],[Vector2i(4,1),"forest"],[Vector2i(4,2),"fiber"],[Vector2i(5,2),"water"],[Vector2i(5,3),"grass"]]: m.add_tile(entry[0],entry[1])
 m.state.expansions = m.state.tiles.size()-4; River.choose_branch(m,"wetland"); River.set_source(m,"2,1")
 m.state.tiles["4,1"].dna.moisture = 75; m.state.tiles["4,2"].dna.moisture = 75; m.state.tiles["4,2"].dna.fertility = 80
 return m
func touch(h, at: Vector2, down: bool) -> void:
 var event := InputEventScreenTouch.new(); event.index = 0; event.position = at; event.pressed = down
 Input.parse_input_event(event); Input.flush_buffered_events()
func click(h, at: Vector2) -> void:
 touch(h,at,true); await process_frame; touch(h,at,false); await process_frame
func button(node: Node, title: String) -> Button:
 for action in node.find_children("*","Button",true,false):
  if action.text == title: return action
 return null
func _init() -> void: call_deferred("run")
func run() -> void:
 root.size = Vector2i(540,960)
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://corridor-controls.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = fixture(); h.services.model = h.model; h.refresh(); h.start_play(); h.modal.hide(); h.frame_world()
 h.corridor_ui.begin(h,"grove"); h.apply_layout(); h.frame_world()
 for frame in range(6): await process_frame
 var before: Dictionary = h.model.state.duplicate(true); var pan: Vector2 = h.pan
 var start: Vector2 = h.screen(Vector2(2,1)); var middle: Vector2 = h.screen(Vector2(3,1)); var end: Vector2 = h.screen(Vector2(4,1))
 touch(h,start,true); await process_frame
 for at in [middle,end]:
  var event := InputEventScreenDrag.new(); event.index = 0; event.position = at; event.relative = at-start
  Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
 touch(h,end,false); await process_frame
 check(h.corridor_ui.draft == ["2,1","3,1","4,1"],"real screen drag traces the route without panning")
 check(h.model.state == before and h.pan == pan,"a dragged preview never spends or mutates the model")
 h.corridor_ui.confirm_route(h)
 button(h.modal_box,"Save this route").pressed.emit()
 check(River.record(h.model).routes.has("grove"),"a preview reaches the actual save confirmation")
 h.corridor_ui.commit(h,func(): return River.allocate(h.model,"grove",1))
 check(River.record(h.model).routes.grove.water == 1,"flow allocation edit is saved")
 h.corridor_ui.undo(h)
 check(River.record(h.model).routes.grove.water == 2,"undo restores the confirmed starting flow without rewinding the world")
 h.corridor_ui.begin(h,"grove"); h.corridor_ui.append_cell(h,"3,1")
 h.corridor_ui.pointers[0] = Vector2.ONE; h.input_controller.begin(0,Vector2.ONE,0)
 h._notification(NOTIFICATION_APPLICATION_PAUSED)
 check(h.corridor_ui.pointers.is_empty() and h.input_controller.pointers.is_empty() and h.corridor_ui.active(),"backgrounding clears gesture pointers while preserving the uncommitted plan")
 h._notification(NOTIFICATION_APPLICATION_RESUMED); h.corridor_ui.cancel(h)
 h.corridor_ui.begin(h,"grove"); h.corridor_ui.append_cell(h,"3,1"); h.open_ideas(true)
 check(not h.corridor_ui.active() and River.record(h.model).routes.grove.path == ["2,1","3,1","4,1"],"opening another task discards only the uncommitted draft")
 h.model.state.coins = h.model.cost(); check(h.model.begin_draft("-1,0"),"saved land hand fixture is affordable"); h.model.state.chapter = 3; h.refresh(); h.modal.hide()
 h.draft_button.pressed.emit()
 check(h.modal_screen == "draft","chapter-three saved draft still resumes instead of opening the fusion shortcut")
 h.model.state.pending = {}; h.modal.hide(); h.model.state.chapter = 2
 var images := []
 for colour in [Color.RED,Color.GREEN,Color.BLUE]:
  var image := Image.create(64,48,false,Image.FORMAT_RGB8); image.fill(colour); images.append(image)
 var path := "user://river-encoder-test.gif"
 check(preload("res://scripts/StoryGif.gd").save(path,images),"animated export encodes multiple frames across many LZW clear blocks")
 check(FileAccess.get_file_as_bytes(path).slice(0,6).get_string_from_ascii() == "GIF89a","animated export has a valid GIF89a signature")
 check(not preload("res://scripts/StoryGif.gd").save("user://missing-river-share/test.gif",images),"failed export reports failure without claiming a share")
 check(not preload("res://scripts/StoryGif.gd").save(path,[]),"empty story exports are rejected")
 var stamp: String = h.river_story.frame_path(h,0); images[0].save_png(stamp)
 images[1].save_png(h.river_story.frame_path(h,1)); images[2].save_png(h.river_story.frame_path(h,2))
 var strip: String = h.river_story.export_strip(h)
 check(strip != "" and Image.load_from_file(strip).get_width() == 192,"story-strip export includes all recorded frames without editing originals")
 for stage in range(4):
  var file: String = h.river_story.frame_path(h,stage)
  if FileAccess.file_exists(file): DirAccess.remove_absolute(file)
 h.queue_free(); h = null; await process_frame
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(540,960),"dp":1.0}]:
  root.size = display.size
  var mobile = preload("res://tests/fixtures/MobileMain.gd").new(); mobile.display_dp = display.dp; mobile.show_menu_on_launch = false; mobile.store.path = "user://river-mobile-controls.json"
  root.add_child(mobile); await process_frame; mobile.set_process(false)
  mobile.model = fixture(); mobile.model.state.text_scale = 1.2; mobile.services.model = mobile.model; mobile.apply_settings()
  mobile.corridor_ui.show(mobile)
  for frame in range(6): await process_frame
  mobile.apply_layout(); await process_frame
  var fits := true
  for action in mobile.modal_box.find_children("*","Button",true,false):
   fits = fits and action.size.y >= mobile.touch_height()-1 and action.get_global_rect().end.x <= mobile.modal_scroll.get_global_rect().end.x+1
  check(fits,"river chapter controls retain enlarged-text touch bounds at "+str(display.size))
  mobile.modal.hide(); mobile.corridor_ui.begin(mobile,"grove")
  for frame in range(6): await process_frame
  mobile.corridor_ui.layout(mobile)
  check(mobile.corridor_ui.bar.size.x <= mobile.layout.world.size.x and mobile.corridor_ui.bar.position.y >= mobile.layout.world.position.y,"planning toolbar stays in the island area at "+str(display.size))
  for action in mobile.corridor_ui.bar.find_children("*","Button",true,false):
   check(action.get_global_rect().end.x <= mobile.corridor_ui.bar.get_global_rect().end.x+1 and action.size.y >= mobile.touch_height()-1,"planning action fits the accessible toolbar: "+action.text)
  mobile.queue_free(); await process_frame
 print("CORRIDOR CONTROLS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
