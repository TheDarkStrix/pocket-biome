extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Lessons = preload("res://scripts/JourneyLessons.gd")
const Goals = preload("res://scripts/ObjectiveGuide.gd")
const Pacing = preload("res://scripts/PacingGuide.gd")
const River = preload("res://scripts/LivingCorridors.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func world():
 var m = Model.new();m.state.chapter=3;m.state.ecology_rules="balanced";m.state.habitat_projects=["shaded_pond"];m.state.discoveries=["rainforest"];m.state.learning={"completed":true}
 for entry in [[Vector2i(2,1),"water"],[Vector2i(3,1),"grass"],[Vector2i(4,1),"forest"],[Vector2i(4,2),"fiber"],[Vector2i(5,2),"water"],[Vector2i(5,3),"grass"],[Vector2i(4,3),"grass"],[Vector2i(2,2),"grass"]]:m.add_tile(entry[0],entry[1])
 for at in ["4,1","4,2"]:m.state.tiles[at].dna.moisture=75;m.state.tiles[at].dna.fertility=80
 m.state.expansions=m.state.tiles.size()-4
 return m
func _init() -> void:call_deferred("run")
func run() -> void:
 var store=preload("res://scripts/SaveStore.gd").new();store.path="user://journey-guidance-tests.json"
 var m=Model.new();var original:=JSON.stringify(m.state)
 check(store.valid(m.state) and not m.state.has("lessons"),"legacy worlds need no lesson field")
 for chapter in range(1,6):
  m.state.chapter=chapter
  for row in Goals.rows(m):
   check(row.why!="" and row.body!="" and row.button!="" and row.action in ["resource","expand","draft","journal","pulse","project","corridors","fusion","recipe","projects","blueprint","world","trade","workshop"],"every campaign requirement has a reason and executable action: "+row.id)
 m.state.chapter=1
 check(JSON.stringify(m.state)==original,"objective and material guidance are read-only")
 check(not Lessons.start(m,"fusion") and not m.state.has("lessons"),"locked lessons cannot start or create progress")
 for id in Lessons.IDS:check(Lessons.instructions(id).size()>=3,"completed lessons retain full reusable instructions: "+id)
 m=world();check(Lessons.start(m,"river") and Lessons.current(m).step=="approach","river starts with a real approach choice")
 var before:=JSON.stringify(m.state);Lessons.current(m);check(JSON.stringify(m.state)==before,"reading an active lesson does not complete a step")
 River.choose_branch(m,"wetland");check(Lessons.current(m).step=="source","branch choice advances to spring selection")
 River.set_source(m,"2,1");check(Lessons.current(m).step=="grove_path","a selected spring advances to on-island drawing")
 River.set_route(m,"grove",["2,1","3,1","4,1"]);check(Lessons.current(m).step=="grove_flow","saving a path still requires actual Water allocation")
 River.allocate(m,"grove",2);check(Lessons.current(m).step=="grove_growth","allocation teaches healthy observed seasons")
 River.advance(m);River.advance(m);check(Lessons.current(m).step=="flower_path","mature grove advances to the flower route")
 m.add_tile(Vector2i(3,2),"grass");m.state.expansions=m.state.tiles.size()-4
 River.set_route(m,"garden",["2,1","2,2","3,2","4,2"])
 check(Lessons.current(m).step=="flower_path" and Lessons.current(m).button=="Repair flower route","a passable flower route that misses the grove receives actionable repair guidance")
 River.set_route(m,"garden",["2,1","3,1","4,1","4,2"]);check(Lessons.current(m).step=="flower_flow","flowers require their own delivered flow")
 River.allocate(m,"garden",1);check(Lessons.current(m).step=="flower_growth","supply alone never manufactures mature flowers")
 River.advance(m);River.advance(m);check(Lessons.current(m).step=="seedbed","healthy flowers expose the seedbed action")
 m.add_tile(Vector2i(-1,0),"grass");m.state.expansions=m.state.tiles.size()-4;m.state.living_corridors.seedbed="-1,0"
 check(store.valid(m.state) and Lessons.current(m).step=="seedbed","an old seedbed beyond the new garden reach is saveable and receives reselection guidance")
 River.set_seedbed(m,"5,3");check(Lessons.current(m).step=="bloom","selected corner teaches real pollination thresholds")
 for season in range(6):River.advance(m)
 check(Lessons.current(m).step=="done" and m.state.tiles["5,3"].evolution=="meadow","lesson completion follows genuine terrain restoration")
 var coins: int=m.state.coins;check(Lessons.finish(m) and not Lessons.finish(m) and m.state.coins==coins,"lesson receipt is once-only and grants no extra payout")
 check(store.save_state(m.state) and store.load_state().lessons.completed==["river"],"lesson receipt survives JSON and canonical save load")
 Lessons.start(m,"fusion");Lessons.skip(m);check(Lessons.record(m).active=="" and Lessons.record(m).skipped.has("fusion"),"skip is durable and releases the active tutorial")
 Lessons.start(m,"fusion");check(not Lessons.record(m).skipped.has("fusion"),"explicit replay restores a skipped lesson")
 for bad in [{"active":"unknown","skipped":[],"completed":[]},{"active":"","skipped":["river","river"],"completed":[]},{"active":"","skipped":[],"completed":[7]}]:
  var state: Dictionary=m.state.duplicate(true);state.lessons=bad;check(not store.valid(state),"malformed lesson save is rejected without a crash")
 var machine=Model.new();machine.add_tile(Vector2i(2,1),"workbench");machine.state.expansions=1
 check(Lessons.start(machine,"automation") and Lessons.current(machine).step=="mill","a Workbench unlocks the automation lesson")
 var find:=Pacing.recipe(machine,"windmill");check(find.action=="resource" and machine.origin(find.target)!="","missing-material help points to a real producing tile")
 for recipe in machine.config.crafting:
  if recipe.id=="windmill":
   for resource in recipe.cost:machine.state.inventory[resource]=recipe.cost[resource]
 check(machine.craft("windmill"),"automation fixture pays the real crafting recipe")
 check(Pacing.recipe(machine,"windmill").action=="projects","pending crafting leads to its ordinary timer rather than another payment")
 machine.tick(30);check(Pacing.recipe(machine,"windmill").action=="blueprint","finished project leads directly to placing its existing blueprint")
 check(machine.deploy("windmill","1,1"),"finished Windmill is placed through the real authority")
 check(Lessons.current(machine).step=="income" and not Lessons.accomplished(machine,"automation"),"a building alone does not count as earned automated income")
 for second in range(int(machine.config.tiles.windmill.interval)*3):machine.tick(1)
 check(Lessons.accomplished(machine,"automation"),"ordinary production finishes the automation lesson")
 var fusion=Model.new();fusion.state.chapter=3
 for cell in [Vector2i(2,0),Vector2i(3,0),Vector2i(2,1),Vector2i(3,1)]:fusion.add_tile(cell,fusion.config.fusions[0].type)
 fusion.state.expansions=fusion.state.tiles.size()-4;Lessons.start(fusion,"fusion")
 check(Lessons.current(fusion).step=="confirm","ready matching square changes the fusion lesson to preview/confirmation")
 check(fusion.fuse("2,0") and Lessons.current(fusion).step=="done","only actual fusion completes its lesson")
 check(store.valid(fusion.state),"guided fusion retains a valid four-cell sanctuary save")
 var network=Model.new();network.state.chapter=4;network.state.discoveries=["rainforest"]
 for entry in [[Vector2i(-1,0),"water"],[Vector2i(-1,1),"water"],[Vector2i(1,1),"workbench"],[Vector2i(2,1),"windmill"],[Vector2i(1,2),"forest"],[Vector2i(0,2),"water"],[Vector2i(2,2),"glacier"]]:network.add_tile(entry[0],entry[1])
 network.state.tiles["0,0"].dna.moisture=75;network.state.tiles["1,2"].dna.moisture=75;network.state.expansions=network.state.tiles.size()-4
 var projects=preload("res://scripts/HabitatProjects.gd");network.state.habitat_projects=projects.IDS.slice(0,4)
 check(Lessons.start(network,"network") and Lessons.current(network).step=="claim","a suitable live connection leads to the actual project claim")
 network.state.tiles["2,1"].enabled=false
 check(Lessons.current(network).step=="habitat_living_workshop" and not Lessons.accomplished(network,"network"),"historical receipts cannot finish a network whose workshop is paused")
 network.state.tiles["2,1"].enabled=true
 check(projects.claim(network,"sanctuary_network") and Lessons.current(network).step=="done","real suitable network claim completes the connection lesson")
 check(store.valid(network.state),"connection lesson outcome remains a valid save")
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://journey-ui-tests.json";root.add_child(h);await process_frame;h.set_process(false)
 h.model=world();h.services.model=h.model;h.modal.hide();h.refresh()
 h.journey_ui.start(h,"river");check(h.modal_screen=="journey_lesson","starting a lesson opens its actual interaction screen")
 h.open_ideas();check(h.modal_screen=="journey_lesson","the objective returns to the active lesson")
 h.choose_idea(Lessons.current(h.model));check(h.modal_screen=="corridors","lesson primary action opens the actual corridor tool")
 var review_before:=JSON.stringify(h.model.state)
 h.model.state.lessons.completed=["river"];h.model.state.living_corridors={"branch":"wetland","source":"","routes":{},"seedbed":"","growth":{"grove":0,"garden":0,"bloom":0},"stage":0,"season":0,"ledger":["grove","wings","bloom"],"next_at":4.0}
 review_before=JSON.stringify(h.model.state);h.journey_ui.start(h,"river")
 check(JSON.stringify(h.model.state)==review_before,"reviewing an accomplished lesson neither changes the active lesson nor writes new progress")
 h.journey_ui.goal(h);check(h.modal_screen=="island_goal" and h.modal_box.find_children("*","Button",true,false).size()>5,"chapter checklist exposes actionable requirements and lesson routes")
 h.campaign_ui.craft_quantity=3;h.choose_idea({"action":"recipe","target":"brick"});check(h.campaign_ui.build_choice=="brick" and h.campaign_ui.build_family=="Craft" and h.campaign_ui.craft_quantity==1,"guided recipe opens the correct category with the quoted single quantity")
 h.store.path="user://missing-journey-parent/fail.json";var saved: Dictionary=Lessons.record(h.model).duplicate(true)
 check(not h.journey_ui.change(h,func():return Lessons.start(h.model,"fusion")) and Lessons.record(h.model)==saved,"failed tutorial save preserves the previous active lesson")
 h.queue_free();h=null;await process_frame
 print("JOURNEY GUIDANCE RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
