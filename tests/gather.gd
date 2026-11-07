extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = Model.new()
 var original := JSON.stringify(m.state)
 check(m.ready_harvests().size() == 3 and JSON.stringify(m.state) == original,"preview finds ready nodes without changing timers or inventory")
 var single = Model.new(); single.state = m.state.duplicate(true)
 for key in single.ready_harvests(): single.harvest(key)
 var result := m.harvest_ready()
 check(result.nodes.size() == 3 and result.resources == {"wood":1,"fiber":1,"stone":1},"one action gathers each ready node exactly once")
 check(m.state == single.state,"bulk collection matches normal per-node rewards, objectives and cooldowns")
 var before := JSON.stringify(m.state)
 check(m.harvest_ready().nodes.is_empty() and JSON.stringify(m.state) == before,"repeated gathering cannot reduce cooldowns or farm early rewards")
 m.tick(12)
 check(m.ready_harvests().size() == 3,"nodes become collectable again through ordinary simulation time")
 m.state.inventory.wood = m.config.economy.inventory_limit
 var oak: Dictionary = m.state.tiles["0,0"].duplicate(true)
 result = m.harvest_ready()
 check(not result.nodes.has("0,0") and m.state.tiles["0,0"] == oak,"full storage skips the resource without touching its cooldown")
 var crowded = Model.new()
 crowded.add_tile(Vector2i(2,0),"oak"); crowded.add_tile(Vector2i(3,0),"oak")
 crowded.state.inventory.wood = crowded.config.economy.inventory_limit-1
 check(crowded.ready_harvests().size() == 3,"preview accounts for several nodes competing for the same final storage slot")
 crowded.harvest_ready()
 check(crowded.state.inventory.wood == crowded.config.economy.inventory_limit,"batch cannot overflow inventory when multiple nodes share a resource")
 root.size = Vector2i(540,960)
 var h = preload("res://tests/fixtures/MobileMain.gd").new()
 h.show_menu_on_launch = false; h.store.path = "user://gather-tests.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = Model.new(); h.services.model = h.model
 h.model.state.settings.tutorial_seen = true
 h.refresh(); h.start_play(); h.modal.hide()
 check(not h.gather_button.visible,"the first individual harvest remains the introductory action")
 h.model.harvest("0,0"); h.model.state.learning={"dismissed":true}; h.refresh()
 check(h.gather_button.visible and h.gather_button.text.ends_with("2") and h.draft_button.disabled,"gather has its own labelled control without changing draft semantics")
 var coins: int = h.model.state.coins
 for frame in range(4): await process_frame
 h.apply_layout(); await process_frame
 var press := InputEventScreenTouch.new(); press.index = 0; press.position = h.gather_button.get_global_rect().get_center(); press.pressed = true
 Input.parse_input_event(press); Input.flush_buffered_events(); await process_frame
 var release := InputEventScreenTouch.new(); release.index = 0; release.position = press.position; release.pressed = false
 Input.parse_input_event(release); Input.flush_buffered_events(); await process_frame
 check(h.model.state.coins == coins+4 and h.store.load_state().inventory.stone == 1,"real gather button persists the normal ready-node payouts")
 check(h.gather_button.disabled and h.gather_button.visible,"empty collection disables the action without making the layout jump")
 h.model.tick(12); h.refresh(); h.campaign_ui.settings(h)
 before = JSON.stringify(h.model.state)
 h.gather_ready()
 check(JSON.stringify(h.model.state) == before,"other modal screens cannot accidentally activate background gathering")
 h.modal.hide(); h.placement_blueprint = "workbench"; h.refresh()
 check(not h.gather_button.visible and h.draft_button.text == "Cancel placement","placement cancellation keeps priority over gathering")
 h.placement_blueprint = ""; h.refresh()
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(360,780),"dp":1.5},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size = display.size; h.display_dp = display.dp; h.model.state.text_scale = scale
   h.apply_settings(); h.refresh()
   for frame in range(4): await process_frame
   h.apply_layout(); await process_frame
   check(h.gather_button.size.y >= h.touch_height() and h.get_viewport_rect().encloses(h.gather_button.get_global_rect()) and not h.gather_button.get_global_rect().intersects(h.bottom.get_global_rect()),"gather target remains usable on phone layout %s scale %s" % [display.size,scale])
   check(h.world_rect().size.y >= h.get_viewport_rect().size.y*0.55,"gather preserves the world-first screen allocation at %s text %s" % [display.size,scale])
 h.queue_free(); h = null; await process_frame
 print("GATHER RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
