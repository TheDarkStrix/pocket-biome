extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Eco = preload("res://scripts/EcologyDirector.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = Model.new(); m.state.ecology_rules = "balanced"; m.add_tile(Vector2i(-1,0),"water"); m.state.expansions = 1
 for second in range(30): m.tick(1)
 check(m.state.tiles["0,0"].dna.moisture == 98,"living climate approaches a predictable local moisture balance")
 m.add_tile(Vector2i(-1,0),"grass")
 for second in range(30): m.tick(1)
 check(m.state.tiles["0,0"].dna.moisture == 50,"removing Water allows moisture to recover to its natural baseline")
 check(m.state.discoveries.has("rainforest"),"changing climate never removes a recorded discovery")
 var sources := {"rainforest":["water"],"ember":["vent","crystal"],"lake":["crystal"],"steam":["water","vent"],"frozen":["glacier","water"],"meadow":["forest","water"],"mossrock":["forest","water"],"reedwater":["forest"],"sunstone":["vent","crystal"],"mistforest":["water","glacier"],"crystalforest":["crystal","stone"],"oasis":["water","vent"],"ironwood":["vent","stone"],"moonflower":["crystal","glacier"],"obsidian":["vent","crystal"],"celestial":["water","forest","stone","crystal"]}
 for recipe in m.config.recipes:
  var example = Model.new(); example.state.tiles.clear(); example.state.ecology_rules = "balanced"
  example.add_tile(Vector2i.ZERO,recipe.types[0])
  for index in range(sources[recipe.id].size()): example.add_tile(Model.DIRS[index],sources[recipe.id][index])
  for second in range(40): example.tick(1)
  check(example.state.discoveries.has(recipe.id),"living climate preserves authored reachability: "+recipe.id)
 m = Model.new(); m.state.tiles["0,0"].dna.moisture = 75; m.evaluate_once()
 m.state.tiles["0,0"].dna.heat = 0; m.state.tiles["0,0"].ready = 8
 var coins: int = m.state.coins
 check(Eco.cultivate(m,"0,0","frozen") and m.state.tiles["0,0"].evolution == "frozen","explicit cultivation permits a qualifying same-tier form")
 check(m.state.tiles["0,0"].ready == 8 and m.state.tiles["0,0"].id == 1,"cultivation preserves protected-node identity and cooldown")
 var earned: int = m.state.coins
 Eco.cultivate(m,"0,0","frozen")
 check(m.state.coins == earned and earned > coins,"cultivation cannot replay an earned discovery reward")
 m.state.tiles["0,0"].dna.magic = 100; m.state.tiles["0,0"].dna.stability = 100; m.evaluate_once()
 check(m.state.tiles["0,0"].evolution == "frozen","a chosen cultivated form stays deliberate instead of silently promoting")
 check(Eco.release(m,"0,0"),"players can resume automatic discovery")
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://director-clarity.json"
 check(store.save_state(m.state) and store.load_state().discoveries.has("frozen"),"cultivation roundtrips through the existing save")
 var corrupt: Dictionary = m.state.duplicate(true); corrupt.ecology_rules = "unknown"
 check(not store.valid(corrupt),"unknown climate modes are rejected")
 corrupt = m.state.duplicate(true); corrupt.tiles["0,0"].cultivated = "yes"
 check(not store.valid(corrupt),"malformed cultivated state is rejected")
 m = Model.new(); m.state.discoveries = ["rainforest"]; m.state.tiles["0,0"].dna.moisture = 70
 m.add_tile(Vector2i(-1,0),"water"); m.add_tile(Vector2i(-1,1),"grass"); m.state.expansions = 2
 var before := JSON.stringify(m.state)
 var preview: String = Eco.consequences(m,"forest","-1,1")
 check(not preview.is_empty() and JSON.stringify(m.state) == before,"consequence previews are read-only")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://director-clarity-ui.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = m; h.services.model = m; h.playtest.path = "user://director-playtest.json"; h.playtest.erase(); h.playtest.attach(m)
 h.playtest.record("probe")
 check(not FileAccess.file_exists(h.playtest.path),"private reporting is off by default")
 m.state.private_playtest = true
 for index in range(205): h.playtest.record("probe",{"id":"oak","name":"must not collect"})
 check(h.playtest.rows().size() == 200 and not h.playtest.report().contains("must not collect"),"local reporting is bounded and excludes arbitrary names")
 m.state.private_playtest = false; var count: int = h.playtest.rows().size(); h.playtest.record("after_opt_out")
 check(h.playtest.rows().size() == count,"opt-out immediately stops local reporting")
 h.refresh(); h.modal.hide(); h.game_hud.show_selection(); h.island_actions.update(h)
 check(h.island_actions.strip.visible and h.island_actions.strip.get_child_count() == 4,"four direct island actions are available after selection")
 h.open_inspector("0,0")
 check(h.inspection_view.has("outlook"),"the real inspector explains current climate trends")
 h.model.state.habitat_projects = ["shaded_pond"]; h.restoration_moment.show(h,"shaded_pond")
 check(h.modal_screen == "restoration_moment","restoration uses an actual-island celebration and earned-tool route")
 h.model.state.ecology_rules = "balanced"; h.care_ui.show_tools(h)
 var labels: Array = h.modal_box.find_children("*","Label",true,false).map(func(label): return label.text)
 check(" ".join(labels).contains("approach") and not " ".join(labels).contains("Effects happen every four"),"care instructions explain balance rather than classic instant pulses")
 check(preload("res://scripts/RestorationCare.gd").description(h.model,"channel").contains("36"),"earned tools describe their actual living-climate effect")
 h.playtest.erase(); h.queue_free(); h = null; await process_frame
 var fusion = Model.new()
 for cell in [Vector2i(2,0),Vector2i(3,0),Vector2i(2,1),Vector2i(3,1)]: fusion.add_tile(cell,"forest")
 fusion.state.expansions = 4; fusion.state.habitat_projects = ["pollinator_patch","sanctuary_network"]
 fusion.state.tiles["2,0"].dna.moisture = 75
 Eco.cultivate(fusion,"2,0","rainforest")
 var care = preload("res://scripts/RestorationCare.gd")
 care.assign(fusion,"shade","2,0"); care.assign(fusion,"shade","3,0",1)
 check(fusion.fuse("2,0") and not fusion.state.tiles["2,0"].has("cultivated") and care.targets(fusion,"shade") == ["2,0"] and store.valid(fusion.state),"fusion clears per-tile cultivation and merges care markers into a valid sanctuary save")
 print("DIRECTOR CLARITY RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
