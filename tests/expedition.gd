extends SceneTree
const Quest = preload("res://scripts/Expedition.gd")
const Model = preload("res://scripts/WorldModel.gd")
const Store = preload("res://scripts/SaveStore.gd")
var checks := 0
var failures := 0
class AdBridge extends Node:
 var shown := 0
 var initialized := 0
 func initializeServices() -> void: initialized += 1
 func showInterstitial() -> void: shown += 1
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func solve(s: Dictionary, water: Array, flowers: Array) -> void:
 for index in water: check(Quest.place(s,index,"water"),"water placement succeeds")
 for index in flowers: check(Quest.place(s,index,"flowers"),"flower placement succeeds")
 for season in range(3): Quest.advance(s)
func _init() -> void: call_deferred("run")
func run() -> void:
 var store = Store.new(); store.path = "user://expedition-tests.json"
 var model = Model.new()
 check(store.valid(model.state),"old-format home without expeditions remains valid")
 var before := JSON.stringify(model.state)
 var s := Quest.fresh()
 check(not Quest.progress(s).ready and Quest.goal(s).begins_with("1"),"expedition starts with an explicit unsolved water problem")
 check(not Quest.place(s,0,"water") and not Quest.place(s,8,"meadow"),"rooted trees cannot be overwritten")
 check(not Quest.place(s,-1,"water") and not Quest.place(s,9,"flowers"),"out of bounds clicks cannot modify expedition")
 solve(s,[3,4,5],[1,7])
 check(Quest.progress(s).ready and Quest.groves(s) == 2,"first spatial solution restores groves and flowering habitats")
 check(not Quest.place(s,2,"water"),"three-water budget cannot be exceeded")
 check(Quest.place(s,4,"meadow") and not Quest.progress(s).ready,"removing water changes live habitat eligibility")
 check(Quest.place(s,2,"water") and Quest.place(s,2,"meadow") and Quest.place(s,4,"water"),"water can be reclaimed and rearranged without purchases")
 check(Quest.progress(s).ready,"restoring the relationship restores wildlife eligibility")
 check(JSON.stringify(model.state) == before,"puzzle operations never spend home inventory or alter home terrain")
 var alternative := Quest.fresh(); solve(alternative,[1,4,7],[3,5])
 check(Quest.progress(alternative).ready,"a second layout independently solves the restoration")
 model.state.expeditions = {Quest.ID:s}
 check(store.save_state(model.state),"unfinished expedition persists in the home atomic save")
 var loaded := store.load_state()
 check(loaded.expeditions[Quest.ID].plots == s.plots and loaded.expeditions[Quest.ID].moisture == s.moisture,"layout and environmental progress survive JSON round trip")
 for kind in ["bad_kind","bad_moisture","bad_complete","bad_tree","extra_water"]:
  var corrupt: Dictionary = model.state.duplicate(true)
  var record: Dictionary = corrupt.expeditions[Quest.ID]
  if kind == "bad_kind": record.plots[2] = "invented"
  elif kind == "bad_moisture": record.moisture[0] = -1
  elif kind == "bad_complete": record.completed = "yes"
  elif kind == "bad_tree": record.plots[0] = "meadow"
  else: record.plots[2] = "water"
  check(not store.valid(corrupt),"corrupt expedition rejected: "+kind)
 var premature: Dictionary = model.state.duplicate(true); premature.expeditions[Quest.ID] = Quest.fresh(); premature.expeditions[Quest.ID].completed = true
 check(not store.valid(premature),"incomplete habitats cannot validate a completed restoration")
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://expedition-ui-tests.json"; h.show_menu_on_launch = false
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = Model.new(); h.services.model = h.model
 h.model.state.discoveries = ["rainforest"]
 h.model.state.objectives = [0,1,2]
 h.expedition_ui.begin(h)
 check(h.modal_screen == "expedition","expedition entry opens the real playable board")
 await process_frame
 await process_frame
 var click := InputEventMouseButton.new(); click.button_index = MOUSE_BUTTON_LEFT; click.pressed = true
 click.position = h.expedition_ui.board.center(3)
 h.expedition_ui.board._gui_input(click)
 check(h.expedition_ui.selected == 3,"touching a rendered plot selects that plot for terrain editing")
 var home_tiles := JSON.stringify(h.model.state.tiles)
 var home_coins: int = h.model.state.coins
 h.expedition_ui.selected = 3; h.expedition_ui.change(h,"water")
 var valid_path: String = h.store.path
 h.store.path = "user://absent-expedition-parent/failed.json"
 h.expedition_ui.leave(h)
 check(h.modal.visible and h.expedition_ui.status.contains("Save failed"),"failed save keeps the expedition open with a visible retry explanation")
 h.store.path = valid_path
 h.expedition_ui.leave(h)
 h.expedition_ui.begin(h)
 check(h.model.state.expeditions[Quest.ID].plots[3] == "water","leaving and continuing retains the partial puzzle")
 var record: Dictionary = h.model.state.expeditions[Quest.ID]
 solve(record,[3,4,5],[1,7])
 var save_path: String = h.store.path
 h.store.path = "user://absent-expedition-parent/failed.json"
 h.expedition_ui.complete(h)
 check(not record.completed and not h.services.restoration_break,"failed completion save cannot commit restoration or trigger an ad")
 h.store.path = save_path
 h.expedition_ui.complete(h)
 check(record.completed and h.store.load_state().expeditions[Quest.ID].completed,"completion is durable before the ad break becomes eligible")
 var completed := JSON.stringify(record)
 h.expedition_ui.complete(h)
 check(JSON.stringify(record) == completed and not Quest.advance(record) and not Quest.place(record,1,"water"),"repeat completion and edits cannot replay the restored milestone")
 check(JSON.stringify(h.model.state.tiles) == home_tiles and h.model.state.coins == home_coins,"expedition completion leaves the home island and currency intact")
 check(h.services.restoration_break,"durable completion registers a natural interstitial opportunity")
 var bridge := AdBridge.new(); h.services.bridge = bridge; h.services.interstitial_ready = true
 h.services.online_requested = false
 var discoveries: Array = h.model.state.discoveries.duplicate()
 h.model.state.discoveries.clear(); h.services.prepare_ad_services()
 check(bridge.initialized == 0,"ads do not initialize before the first discovery")
 h.model.state.discoveries = discoveries
 h.model.state.learning = {"completed":true}
 h.services.prepare_ad_services(); h.services.prepare_ad_services()
 check(bridge.initialized == 1,"ad preparation is automatic after discovery and occurs once per session")
 h.model.state.chapter_rewards = []
 h.services.cadence.path = "user://expedition-test-ad-cadence-%d.json" % Time.get_ticks_usec()
 h.services.active_seconds = 179
 check(not h.services.maybe_interstitial("expedition") and bridge.shown == 0,"expedition completion cannot bypass the three-minute first-play guard")
 h.services.active_seconds = 180
 # The early skipped opportunity is consumed; the original result cannot resurface.
 check(not h.services.maybe_interstitial("expedition"),"late readiness never resurrects a skipped expedition result")
 h.services.register_attempt_completion("expedition_replay",Quest.ID)
 check(h.services.maybe_interstitial("expedition_replay") and bridge.shown == 1,"a fresh completed replay can monetize at an explicit result break")
 h.services.register_expedition_completion(Quest.ID)
 check(not h.services.restoration_break,"same restored island cannot register another break")
 h.services.bridge = null; bridge.free()
 h.expedition_ui.leave(h)
 check(not h.modal.visible,"return home remains functional without any ad provider")
 h.queue_free(); h = null; await process_frame
 print("EXPEDITION RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
