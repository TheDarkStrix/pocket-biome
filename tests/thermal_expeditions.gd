extends SceneTree
const Q = preload("res://scripts/Expedition.gd")
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func solve_frost(s: Dictionary) -> void:
 Q.place(s,1,"vent"); Q.place(s,4,"water"); Q.place(s,3,"flowers"); Q.place(s,5,"flowers")
 for turn in range(3): Q.advance(s)
func solve_ember(s: Dictionary, alternate: bool = false) -> void:
 for index in ([1,4,7] if alternate else [3,4,5]): Q.place(s,index,"water")
 for index in ([3,5] if alternate else [1,7]): Q.place(s,index,"flowers")
 for turn in range(3): Q.advance(s)
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = Model.new()
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://thermal-expeditions-tests.json"
 m.state.discoveries = ["rainforest"]
 check(Q.unlocked(m,Q.ID) and not Q.unlocked(m,"frost_hollow"),"frozen expedition waits for the first restoration")
 var frost := Q.fresh("frost_hollow")
 check(Q.trees(frost) == [0,2] and not Q.progress(frost).ready,"frozen island has a different rooted-tree arrangement")
 Q.place(frost,3,"vent")
 check(Q.progress(frost).connected == 1,"poor heat placement reaches only one tree")
 check(not Q.place(frost,1,"vent"),"the single heat-source budget forces a spatial choice")
 Q.place(frost,3,"meadow"); solve_frost(frost)
 check(Q.progress(frost).ready and frost.heat[0] == 65 and frost.heat[2] == 65,"shared heat source restores both groves and flowering habitats")
 for turn in range(2): Q.advance(frost)
 check(not Q.progress(frost).ready,"overheating invalidates a frozen habitat instead of ignoring the upper threshold")
 Q.place(frost,1,"meadow"); Q.place(frost,4,"meadow"); Q.place(frost,3,"water"); Q.place(frost,5,"water")
 for turn in range(3): Q.advance(frost)
 Q.place(frost,3,"flowers"); Q.place(frost,5,"flowers"); Q.place(frost,4,"water"); Q.place(frost,1,"vent")
 check(Q.progress(frost).ready,"an overheated layout can be repaired without restarting or watching ads")
 var ember := Q.fresh("ember_shore")
 check(not Q.place(ember,2,"meadow"),"the volcanic rock cannot be removed to bypass the challenge")
 check(not Q.place(ember,4,"vent"),"players cannot add unbudgeted heat sources to the volcanic island")
 solve_ember(ember)
 check(Q.progress(ember).ready and ember.heat[0] == 50 and ember.moisture[0] == 70,"water balances volcanic heat and moisture to restore habitats")
 Q.advance(ember); Q.advance(ember)
 check(not Q.progress(ember).ready,"too much cooling requires the player to adjust the layout")
 var alternate := Q.fresh("ember_shore"); solve_ember(alternate,true)
 check(Q.progress(alternate).ready,"volcanic restoration supports a second spatial solution")
 var dry := Q.fresh(); dry.plots = ["oak","flowers","meadow","water","water","water","meadow","flowers","oak"]
 for turn in range(3): Q.advance(dry)
 dry.completed = true
 m.state.expeditions = {Q.ID:dry}
 check(Q.unlocked(m,"frost_hollow") and not Q.unlocked(m,"ember_shore"),"restoration unlocks the next island, not the whole chain")
 frost.completed = true; alternate.completed = true
 m.state.expeditions.frost_hollow = frost; m.state.expeditions.ember_shore = alternate
 check(store.save_state(m.state),"all three completed islands can be persisted together")
 var loaded: Dictionary = store.load_state()
 check(loaded.expeditions.frost_hollow.heat == frost.heat and loaded.expeditions.ember_shore.heat == alternate.heat,"thermal arrays survive JSON canonicalization")
 check(Q.unlocked(m,"ember_shore"),"restoring the frozen island unlocks volcanic restoration")
 for failure in ["bad_heat","missing_heat","wrong_identity","vent_budget"]:
  var corrupt: Dictionary = m.state.duplicate(true)
  if failure == "bad_heat": corrupt.expeditions.frost_hollow.heat[0] = 101
  elif failure == "missing_heat": corrupt.expeditions.frost_hollow.erase("heat")
  elif failure == "wrong_identity": corrupt.expeditions.frost_hollow.island = "ember_shore"
  else: corrupt.expeditions.frost_hollow.plots[6] = "vent"
  check(not store.valid(corrupt),"invalid thermal save rejected: "+failure)
 var capped := Q.fresh(); capped.seasons = 10000; Q.place(capped,1,"water")
 Q.advance(capped)
 check(capped.moisture[0] > 25 and capped.seasons == 10000,"the bounded season counter never soft-locks environmental recovery")
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://thermal-ui-tests.json"; h.show_menu_on_launch = false
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = m; h.services.model = m
 var before := JSON.stringify(h.model.state.expeditions[Q.ID])
 h.expedition_ui.begin(h,"frost_hollow")
 check(h.expedition_ui.active_id == "frost_hollow" and h.modal_title.text.contains("Frost Hollow"),"map entry opens the selected frozen expedition")
 h.expedition_ui.begin(h,"ember_shore")
 check(h.expedition_ui.active_id == "ember_shore" and h.modal_title.text.contains("Ember Shore"),"map entry opens the selected volcanic expedition")
 check(JSON.stringify(h.model.state.expeditions[Q.ID]) == before,"switching islands cannot overwrite a previous restoration")
 h.services.register_expedition_completion("frost_hollow"); h.services.register_expedition_completion("ember_shore")
 check(h.services.expedition_breaks.size() == 2,"each restored island can register its own capped natural ad break")
 h.queue_free(); h = null; await process_frame
 print("THERMAL EXPEDITIONS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
