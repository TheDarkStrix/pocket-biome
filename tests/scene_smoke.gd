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
 check(scene.rain_button.disabled and scene.heat_button.disabled,"unaffordable pulses disabled")
 var active: float = scene.model.state.time
 scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 scene._process(30.0)
 check(scene.model.state.time == active,"background suspends active-time progression")
 scene._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 scene._process(30.0)
 check(scene.model.state.time == active,"resume ignores accumulated background frame delta")
 scene._process(0.25)
 check(is_equal_approx(scene.model.state.time,active+0.25),"active-time resumes at frame precision")
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.refresh()
 scene.tap(scene.screen(Vector2.ZERO)-Vector2(0,50))
 check(scene.save_dirty and scene.model.state.inventory.wood == 1,"harvest queues a debounced save")
 scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(not scene.save_dirty and scene.store.load_state().inventory.wood == 1,"backgrounding flushes the queued harvest before suspension")
 print("SCENE RESULT: %d checks, %d failures" % [checks,failures])
 scene.queue_free()
 await process_frame
 # Audio playback references are released asynchronously by the mixer.
 await create_timer(0.15).timeout
 quit(1 if failures else 0)
