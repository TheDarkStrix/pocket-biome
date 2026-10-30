extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 var scene = load("res://scenes/Main.tscn").instantiate()
 scene.orbit_enabled = false
 scene.store.path = "user://scene-test.json"
 scene.show_menu_on_launch = false
 root.add_child(scene)
 await process_frame
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.store.path = "user://scene-test.json"
 scene.modal.hide()
 scene.refresh()
 for k in scene.model.state.tiles:
  check(scene.hit(scene.screen(scene.model.coord(k))) == k,"projection roundtrip")
 check(scene.pick(scene.screen(Vector2.ZERO)-Vector2(0,50)) == "0,0","Oak canopy touch resolves to Oak instead of a cloud")
 var state_before_turn: String = JSON.stringify(scene.model.state)
 var expected := [Vector2(66,33),Vector2(-66,33),Vector2(-66,-33),Vector2(66,-33)]
 for view in range(4):
  check(scene.project(Vector2.RIGHT).is_equal_approx(expected[view]),"camera projects the expected cardinal view %d" % view)
  var cells_match := true
  for key in scene.model.state.tiles: cells_match = cells_match and scene.hit(scene.screen(scene.model.coord(key))) == key
  check(cells_match,"tile inverse picking survives view %d" % view)
  var clouds_match := true
  for key in scene.model.frontier(): clouds_match = clouds_match and scene.pick(scene.screen(scene.model.coord(key))) == key
  check(clouds_match,"all expansion controls remain hittable in view %d" % view)
  scene.rotate_camera(1)
 check(scene.view_turn == 0 and JSON.stringify(scene.model.state) == state_before_turn,"full-circle stepped rotation preserves the exact game state")
 scene.tap(scene.screen(Vector2.ZERO))
 check(scene.model.state.inventory.wood == 1,"scene harvest routing")
 scene.tap(scene.screen(Vector2(-1,0)))
 check(scene.modal.visible,"draft modal opened")
 # Real card button signal follows the same handler as touch selection.
 scene.draft_cards[1].pressed.emit()
 scene.confirm_card.pressed.emit()
 check(not scene.modal.visible,"card selection closes modal")
 check(scene.model.state.tiles.get("-1,0",{}).get("type","") == "water","scene places Water")
 await create_timer(4.2).timeout
 check(scene.model.state.discoveries.has("rainforest"),"live scene timer evolves Oak")
 check(scene.objective.text.contains("Expand your island"),"compact chapter progress keeps the action instruction, not only its count")
 scene.persist()
 var saved = scene.store.load_state()
 check(saved.discoveries.has("rainforest"),"scene persistence")
 check(scene.tile_title(scene.model.state.tiles["0,0"]) == "Rainforest Sanctuary","friendly evolved title")
 check(scene.pulse_bar.value == scene.model.state.energy,"pulse meter follows model")
 var energy: int = scene.model.state.energy
 scene.target("rain")
 check(scene.draft_button.text == "Cancel pulse" and not scene.draft_button.disabled,"targeting exposes cancel action")
 scene.draft_button.pressed.emit()
 check(scene.targeting == "" and scene.model.state.energy == energy,"cancel preserves energy")
 check(scene.draft_button.disabled,"no pending draft cannot resume")
 scene.model.state.energy = 0
 scene.refresh()
 scene.pulse_selector()
 check(scene.rain_button.disabled and scene.heat_button.disabled,"unaffordable pulses disabled in the power selector")
 scene.modal.hide()
 var active: float = scene.model.state.time
 scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 scene._process(30.0)
 check(scene.model.state.time == active,"background suspends active-time progression")
 scene._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 scene._process(30.0)
 check(scene.model.state.time == active,"resume ignores accumulated background frame delta")
 scene._process(0.25)
 check(is_equal_approx(scene.model.state.time,active+0.25),"active-time resumes at frame precision")
 var sky_before: float = scene.ambient_time
 scene.model.state.settings.reduced_motion = true
 scene._process(0.25)
 check(is_equal_approx(sky_before,scene.ambient_time),"reduced motion freezes the cloud shader's animation clock")
 scene.model.state.settings.reduced_motion = false
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.refresh()
 scene.tap(scene.screen(Vector2.ZERO)-Vector2(0,50))
 check(scene.save_dirty and scene.model.state.inventory.wood == 1,"harvest queues a debounced save")
 scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(not scene.save_dirty and scene.store.load_state().inventory.wood == 1,"backgrounding flushes the queued harvest before suspension")
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.model.state.tiles.clear()
 for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: scene.model.add_tile(at,"forest")
 scene.model.fuse("0,0"); scene.selected = "0,0"; scene.refresh()
 var fused_before: String = JSON.stringify(scene.model.state)
 for view in range(4):
  scene.frame_world()
  check(scene.model.origin(scene.pick(scene.entity_screen("0,0"))) == "0,0","rotated sanctuary resolves to its shared origin in view %d" % view)
  scene.rotate_camera(1)
 check(JSON.stringify(scene.model.state) == fused_before,"camera rotation preserves fused reservations and cooldowns")
 print("SCENE RESULT: %d checks, %d failures" % [checks,failures])
 scene.queue_free()
 await process_frame
 # Audio playback references are released asynchronously by the mixer.
 await create_timer(0.15).timeout
 quit(1 if failures else 0)
