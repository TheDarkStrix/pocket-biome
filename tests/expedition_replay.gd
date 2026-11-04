extends SceneTree
const Q = preload("res://scripts/Expedition.gd")
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+text)
func solve_river(s: Dictionary, alternate: bool = false) -> void:
 for index in ([5,4,3] if alternate else [1,4,7]): Q.place(s,index,"water")
 for index in ([1,7] if alternate else [3,5]): Q.place(s,index,"flowers")
 for turn in range(3): Q.advance(s)
func solve_dry(s: Dictionary) -> void:
 for index in [3,4,5]: Q.place(s,index,"water")
 for index in [1,7]: Q.place(s,index,"flowers")
 for turn in range(3): Q.advance(s)
func _init() -> void: call_deferred("run")
func run() -> void:
 var river := Q.fresh("river_link")
 check(not Q.river_connected(river) and Q.goal(river).contains("Connect"),"river objective starts with a genuine path requirement")
 check(not Q.place(river,2,"meadow") and not Q.place(river,6,"flowers"),"spring and outlet are protected")
 Q.place(river,4,"water")
 check(not Q.river_connected(river),"diagonal water is not a continuous river")
 solve_river(river)
 check(Q.progress(river).ready,"a complete path also supports the restored neighboring habitats")
 check(not Q.place(river,3,"water"),"river's total supply budget includes its fixed endpoints")
 var alternate := Q.fresh("river_link"); solve_river(alternate,true)
 check(Q.progress(alternate).ready,"another water route supports an independent solution")
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://replay-tests.json"
 var m = Model.new(); m.state.discoveries = ["rainforest"]
 var original := Q.fresh(); solve_dry(original); original.completed = true
 m.state.expeditions = {Q.ID:original}
 m.state.expedition_attempts = {Q.ID:Q.fresh()}
 check(store.save_state(m.state) and store.load_state().expeditions[Q.ID].completed,"fresh replay coexists with an unchanged original restoration")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://replay-ui-tests.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = m; h.services.model = m
 var original_text := JSON.stringify(original); var coins: int = m.state.coins
 h.expedition_ui.begin(h,Q.ID,true)
 check(h.expedition_ui.replaying and h.modal_title.text.begins_with("Replay"),"replay entry opens a separate playable attempt")
 h.expedition_ui.selected = 3; h.expedition_ui.change(h,"water")
 h.expedition_ui.leave(h); h.expedition_ui.begin(h,Q.ID,true)
 check(h.expedition_ui.record(h).plots[3] == "water","unfinished replay resumes without resetting its layout")
 solve_dry(h.expedition_ui.record(h)); h.expedition_ui.complete(h)
 check(h.store.load_state().expedition_attempts[Q.ID].completed,"replay completion is saved independently")
 check(JSON.stringify(m.state.expeditions[Q.ID]) == original_text and m.state.coins == coins,"replay cannot overwrite original restoration or award additional Coins")
 check(not h.services.restoration_break and h.services.expedition_breaks.is_empty(),"replay does not register another restoration ad milestone")
 h.expedition_ui.begin(h,Q.ID,true,true)
 check(not h.expedition_ui.record(h).completed and h.expedition_ui.record(h).seasons == 0,"explicit fresh replay replaces only the old attempt")
 check(JSON.stringify(m.state.expeditions[Q.ID]) == original_text,"fresh-attempt reset preserves the original island")
 var other := Q.fresh("river_link"); solve_river(other); other.completed = true
 m.state.expeditions["river_link"] = other
 check(store.save_state(m.state) and store.load_state().expeditions["river_link"].completed,"connection-based island remains compatible with the home save")
 var corrupt: Dictionary = m.state.duplicate(true); corrupt.expedition_attempts[Q.ID].plots[1] = "invalid"
 check(not store.valid(corrupt),"invalid replay terrain is rejected without weakening original save validation")
 h.queue_free(); h = null; await process_frame
 print("EXPEDITION REPLAY RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
