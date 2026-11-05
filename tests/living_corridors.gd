extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const River = preload("res://scripts/LivingCorridors.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func world(branch: String = "wetland"):
 var m = Model.new(); m.state.ecology_rules = "balanced"; m.state.habitat_projects = ["shaded_pond"]; m.state.discoveries = ["rainforest"]; m.state.objectives = [0,1,2]
 for entry in [[Vector2i(2,1),"water"],[Vector2i(3,1),"grass"],[Vector2i(4,1),"forest"],[Vector2i(4,2),"fiber"],[Vector2i(5,2),"water"],[Vector2i(5,3),"grass"],[Vector2i(4,3),"grass"],[Vector2i(2,2),"grass"]]: m.add_tile(entry[0],entry[1])
 if branch == "woodland": m.add_tile(Vector2i(3,1),"forest"); m.add_tile(Vector2i(3,2),"forest")
 for at in ["4,1","4,2","3,1","3,2"]:
  if m.state.tiles.has(at): m.state.tiles[at].dna.moisture = 75; m.state.tiles[at].dna.fertility = 80
 m.state.expansions = m.state.tiles.size()-4
 River.choose_branch(m,branch); River.set_source(m,"2,1")
 return m
func button(node: Node, title: String) -> Button:
 for action in node.find_children("*","Button",true,false):
  if action.text == title: return action
 return null
func _init() -> void: call_deferred("run")
func run() -> void:
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://living-corridors-tests.json"
 for branch in River.BRANCHES:
  var m = world(branch)
  check(store.valid(m.state),"branch initialization has a valid bounded save: "+branch)
  check(River.set_route(m,"grove",["2,1","3,1","4,1"]),"remote grove route can be committed: "+branch)
  var garden: Array = ["2,1","3,1","4,1","4,2"] if branch == "wetland" else ["2,1","2,2","3,2","3,1","4,1","4,2"]
  check(River.set_route(m,"garden",garden),"migration route passes through the grove: "+branch)
  check(River.allocate(m,"grove",2) and River.allocate(m,"garden",1),"limited flow can be split: "+branch)
  check(not River.allocate(m,"garden",3),"allocations cannot exceed spring supply: "+branch)
  check(River.set_seedbed(m,"5,3"),"a bare linked corner can be selected: "+branch)
  var time: float = m.state.time; var coins: int = m.state.coins; var ready: float = m.state.tiles["0,0"].ready
  River.advance(m); River.advance(m)
  check(River.record(m).ledger.has("grove") and River.dry(m),"a mature grove starts the forecast dry spell: "+branch)
  check(m.state.time == time and m.state.tiles["0,0"].ready == ready,"observing river seasons never advances harvest or machine clocks")
  if branch == "woodland":
   check(River.delivered(m).garden == 0 and River.grove_demand(m) == 1,"woodland shelter creates a real redirection decision during drought")
   River.allocate(m,"grove",1)
  else: check(River.budget(m) == 3 and River.delivered(m).garden == 1,"wetland's larger supply keeps both branches watered")
  for season in range(6): River.advance(m)
  check(River.earned(m) and River.record(m).stage == 3,"the full causal chapter completes: "+branch)
  check(m.state.tiles["5,3"].evolution == "meadow","pollination actually transforms the dormant corner: "+branch)
  check(not River.dry(m),"the dry spell resolves with the restored corner")
  var earned: int = m.state.coins; var ledger: Array = River.record(m).ledger.duplicate()
  for season in range(6): River.advance(m)
  check(m.state.coins == earned and River.record(m).ledger == ledger,"repeated seasons cannot repeat discovery or chapter-stage rewards")
  check(store.save_state(m.state) and store.load_state().living_corridors.ledger == ledger,"all chapter progress persists through JSON load")
  var restored = Model.new(); restored.state = store.load_state()
  check(River.delivered(restored).garden == River.delivered(m).garden,"canonicalized allocations retain their behavior")
  River.choose_branch(m,"woodland" if branch == "wetland" else "wetland")
  check(River.earned(m) and River.record(m).stage == 0 and River.record(m).routes.is_empty(),"trying the other approach preserves earned moments without carrying old water allocations")
 var m = world()
 var original := JSON.stringify(m.state)
 for path in [["2,1","4,1"],["2,1","3,1","2,1","4,1"],["2,1","1,1","2,1","3,1","4,1"],["2,1","3,1"]]:
  check(not River.set_route(m,"grove",path),"diagonal/jumping, looping, machine-blocked or wrong-endpoint paths are rejected")
 check(JSON.stringify(m.state) == original,"invalid planning cannot alter progress")
 River.set_route(m,"grove",["2,1","3,1","4,1"]); River.allocate(m,"grove",2)
 var before_preview := JSON.stringify(m.state)
 var message: String = preload("res://scripts/EcologyDirector.gd").consequences(m,"workbench","3,1")
 check(message.contains("Stops Water") and JSON.stringify(m.state) == before_preview,"ordinary placement previews warn about a broken river without modifying it")
 m.add_tile(Vector2i(3,1),"stone")
 check(River.delivered(m).grove == 0 and store.valid(m.state),"editing terrain pauses a broken route without corrupting the save")
 var growth: int = River.record(m).growth.grove; River.advance(m)
 check(River.record(m).growth.grove <= growth,"blocked routes cannot earn growth")
 m.add_tile(Vector2i(3,1),"grass"); River.advance(m); River.advance(m)
 check(River.record(m).growth.grove == 2,"repairing the route recovers progression")
 m.add_tile(Vector2i(2,1),"grass")
 check(River.delivered(m).grove == 0 and store.valid(m.state),"a removed spring remains a repairable state")
 var bad: Dictionary = m.state.duplicate(true); bad.living_corridors.growth.grove = 9
 check(not store.valid(bad),"out-of-bounds growth is rejected")
 bad = m.state.duplicate(true); bad.living_corridors.routes.grove.path = ["2,1","4,1"]
 check(not store.valid(bad),"nonadjacent persisted paths are rejected")
 bad = m.state.duplicate(true); bad.living_corridors.ledger = ["grove","grove"]
 check(not store.valid(bad),"duplicate stage receipts are rejected")
 var invalid = world(); River.set_route(invalid,"grove",["2,1","3,1","4,1"]); River.allocate(invalid,"grove",2)
 invalid.add_tile(Vector2i(2,1),"grass")
 var invalid_before := JSON.stringify(invalid.state)
 check(not River.advance(invalid) and JSON.stringify(invalid.state) == invalid_before,"a removed source cannot advance a season or chemistry")
 var legacy = Model.new(); legacy.state.chapter = 5; legacy.state.chapter_rewards = [1,2,3,4,5]
 check(store.valid(legacy.state) and not legacy.state.has("living_corridors"),"existing completed saves require no new fields or repeated chapter")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://living-corridor-ui.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = world(); h.services.model = h.model; h.refresh(); h.modal.hide()
 h.corridor_ui.begin(h,"grove"); h.corridor_ui.append_cell(h,"3,1"); h.corridor_ui.append_cell(h,"4,1")
 check(h.corridor_ui.draft == ["2,1","3,1","4,1"] and River.record(h.model).routes.is_empty(),"island planning creates a visible uncommitted draft")
 var before: Dictionary = h.model.state.duplicate(true)
 h.corridor_ui.cancel(h)
 check(h.model.state == before and not h.corridor_ui.active(),"canceling a draft changes no terrain, resources or river state")
 h.corridor_ui.begin(h,"grove"); h.corridor_ui.append_cell(h,"3,1"); h.corridor_ui.append_cell(h,"4,1"); h.corridor_ui.confirm_route(h)
 h.store.path = "user://missing-living-corridor/fail.json"; button(h.modal_box,"Save this route").pressed.emit()
 check(h.model.state == before and h.corridor_ui.active(),"failed route save rolls back and retains the editable preview")
 h.store.path = "user://living-corridor-ui.json"; button(h.modal_box,"Save this route").pressed.emit()
 check(River.record(h.model).routes.has("grove") and h.store.load_state().living_corridors.routes.has("grove"),"route confirmation commits through the real UI")
 h.corridor_ui.commit(h,func(): return River.allocate(h.model,"grove",2))
 var before_season: Dictionary = h.model.state.duplicate(true)
 h.store.path = "user://missing-living-corridor/fail.json"; h.corridor_ui.observe(h)
 check(h.model.state == before_season,"failed season save restores chemistry, stage rewards and progress atomically")
 h.store.path = "user://living-corridor-ui.json"; h.corridor_ui.observe(h)
 check(River.record(h.model).season == 1 and h.corridor_ui.moment,"observing shows the actual island and keeps the next season reachable")
 h.queue_free(); h = null; await process_frame
 print("LIVING CORRIDORS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
