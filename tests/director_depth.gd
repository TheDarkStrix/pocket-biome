extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Quest = preload("res://scripts/Expedition.gd")
const Mastery = preload("res://scripts/ExpeditionMastery.gd")
const Rewards = preload("res://scripts/ExpeditionRewards.gd")
const Care = preload("res://scripts/RestorationCare.gd")
const Life = preload("res://scripts/SanctuaryLife.gd")
const Projects = preload("res://scripts/HabitatProjects.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func solve(trial: Dictionary, id: String) -> void:
 if id == "frost_hollow":
  Mastery.place(trial,1,"vent")
  for index in [6,8]: Mastery.place(trial,index,"water")
  for index in [3,5]: Mastery.place(trial,index,"flowers")
 else:
  for index in ([1,4,7] if id == "river_link" else [3,4,5]): Mastery.place(trial,index,"water")
  for index in ([3,5] if id == "river_link" else [1,7]): Mastery.place(trial,index,"flowers")
 for season in range(3): Quest.advance(trial.board)
func world():
 var m = Model.new(); m.state.discoveries = ["rainforest"]; m.state.objectives = [0,1,2]; m.state.settings.tutorial_seen = true
 for entry in [[Vector2i(-1,0),"water"],[Vector2i(-1,1),"water"],[Vector2i(1,1),"workbench"],[Vector2i(2,1),"windmill"],[Vector2i(1,2),"forest"],[Vector2i(0,2),"water"],[Vector2i(2,2),"glacier"]]: m.add_tile(entry[0],entry[1])
 m.state.tiles["0,0"].dna.moisture = 75; m.state.tiles["1,2"].dna.moisture = 75
 m.state.expansions = m.state.tiles.size()-4
 return m
func _init() -> void: call_deferred("run")
func run() -> void:
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://director-depth.json"
 var m = world(); m.state.expeditions = {}; m.state.expedition_trials = {}
 for id in Quest.ISLANDS:
  var original := Mastery.fresh(id,"swift"); solve(original,id); original.board.completed = true
  m.state.expeditions[id] = original.board.duplicate(true)
  for variant in Mastery.VARIANTS:
   var trial := Mastery.fresh(id,variant); solve(trial,id)
   m.state.expedition_trials[Mastery.key(id,variant)] = trial
   check(Mastery.qualified(trial),"verified legal solution for "+id+" / "+variant)
   check(Mastery.finish(m,id,variant),"challenge completion records result for "+id+" / "+variant)
   check(not Mastery.finish(m,id,variant),"completed challenge cannot replay its record")
 check(m.state.expedition_bests.size() == 8 and store.save_state(m.state),"all eight authored mastery results save together")
 var loaded: Dictionary = store.load_state()
 check(loaded.expedition_bests["dry_springs:swift"].seasons == 3,"personal bests survive JSON canonicalization")
 var old_best: Dictionary = m.state.expedition_bests["dry_springs:swift"].duplicate()
 var slower := Mastery.fresh("dry_springs","swift"); solve(slower,"dry_springs"); Quest.advance(slower.board)
 m.state.expedition_trials["dry_springs:swift"] = slower; Mastery.finish(m,"dry_springs","swift")
 check(m.state.expedition_bests["dry_springs:swift"] == old_best,"a slower qualifying attempt cannot overwrite a better result")
 var practice := Mastery.fresh("dry_springs","swift"); solve(practice,"dry_springs"); Quest.advance(practice.board); Quest.advance(practice.board)
 check(not Mastery.qualified(practice) and Quest.progress(practice.board).ready,"missing the season target keeps a successful practice restoration")
 var careful := Mastery.fresh("dry_springs","careful"); Mastery.place(careful,3,"water")
 check(not Mastery.place(careful,3,"meadow") and careful.moves == 1,"careful challenge enforces irreversible attempt placement without charging home resources")
 check(Care.capacity(m,"shade") == 2 and Care.capacity(m,"warmth") == 2 and Rewards.water_reach(m) == 3,"original expedition completions grant useful derived home capabilities")
 m.state.habitat_projects = ["shaded_pond","pollinator_patch","thermal_refuge"]
 m.add_tile(Vector2i(-2,0),"grass"); m.add_tile(Vector2i(-3,0),"forest"); m.add_tile(Vector2i(-4,0),"forest"); m.state.expansions = m.state.tiles.size()-4
 check(Care.water_source(m,"-4,0") != "","Dry Springs reward extends a channel to three natural steps")
 m.state.expeditions.erase("dry_springs")
 check(Care.water_source(m,"-4,0") == "","without original restoration the extended reach is not available")
 for corrupt in [{"unknown:swift":{}},{"dry_springs:swift":{"board":Quest.fresh(),"variant":"careful","moves":0}},{"dry_springs:careful":{"board":Quest.fresh(),"variant":"careful","moves":9}}]:
  var state: Dictionary = m.state.duplicate(true); state.expedition_trials = corrupt
  check(not store.valid(state),"malformed trial or impossible careful history is rejected")
 m = world(); m.state.habitat_projects = Projects.IDS.duplicate()
 var routes := Life.routes(m)
 check(routes.size() == 5 and routes[0].stops.size() >= 2,"visitors travel through actual suitable habitat cells")
 m.state.tiles["0,0"].dna.moisture = 0; m.state.tiles["1,2"].dna.moisture = 0
 check(Life.routes(m).size() < routes.size() and Life.notes(m).size() == 6,"lost habitat changes routes while field-note memories remain")
 m = world(); m.state.habitat_projects = Projects.IDS.duplicate(); m.state.chapter = 5; m.state.chapter_rewards = [1,2,3,4]
 for x in range(3,18): m.add_tile(Vector2i(x,1),"grass")
 m.state.expansions = m.state.tiles.size()-4
 check(m.state.discoveries.size() < 20 and Projects.network(m).ready,"a thriving finale layout does not require exhaustive collection")
 m.state.tiles["2,1"].enabled = false; m.campaign.evaluate(m)
 check(not m.state.chapter_rewards.has(5),"historical project records cannot finish a currently unsuitable sanctuary")
 m.state.tiles["2,1"].enabled = true; m.campaign.evaluate(m)
 check(m.state.chapter_rewards.has(5),"a currently thriving connected sanctuary completes the campaign")
 var coins: int = m.state.coins; m.state.tiles["2,1"].enabled = false; m.campaign.evaluate(m)
 check(m.state.chapter_rewards.has(5) and m.state.coins == coins,"earned endings stay completed when the player later redesigns")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://director-mastery-ui.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = world(); h.services.model = h.model
 var restored := Mastery.fresh("dry_springs","swift"); solve(restored,"dry_springs"); restored.board.completed = true
 h.model.state.expeditions = {"dry_springs":restored.board}
 var original := JSON.stringify(restored.board)
 h.expedition_ui.begin(h,"dry_springs",true,true,"careful")
 var active: Dictionary = h.model.state.expedition_trials["dry_springs:careful"]; solve(active,"dry_springs")
 var before: Dictionary = h.model.state.duplicate(true); h.store.path = "user://missing-director-parent/fail.json"
 h.expedition_ui.complete(h)
 check(h.model.state == before,"failed mastery save restores trial completion and personal best atomically")
 h.store.path = "user://director-mastery-ui.json"; h.expedition_ui.complete(h)
 check(h.model.state.expedition_bests.has("dry_springs:careful") and not h.services.restoration_break,"saved mastery keeps the original restoration milestone untouched")
 check(JSON.stringify(h.model.state.expeditions.dry_springs) == original,"original restoration is unchanged by challenge attempts")
 h.queue_free(); h = null; await process_frame
 print("DIRECTOR DEPTH RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
