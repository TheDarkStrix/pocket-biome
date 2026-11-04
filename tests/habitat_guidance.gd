extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Advice = preload("res://scripts/HabitatGuidance.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = Model.new()
 check(Advice.advice(m,"shaded_pond").action == "ideas","new players are guided through their first discovery")
 check(Advice.advice(m,"invented").is_empty(),"unknown projects produce no action")
 m.state.discoveries = ["rainforest"]
 var before := JSON.stringify(m.state)
 var step := Advice.advice(m,"shaded_pond")
 check(step.action == "build" and step.target == "workbench","Water crafting guidance explains the missing Workbench first")
 check(JSON.stringify(m.state) == before,"reading missing-requirement guidance never spends or alters state")
 m.add_tile(Vector2i.ONE,"workbench")
 step = Advice.advice(m,"shaded_pond")
 check(step.action == "build" and step.target == "water","Workbench owner is routed to the Water recipe")
 m.state.blueprints.water = 1
 step = Advice.advice(m,"shaded_pond")
 check(step.action == "world" and step.target == "1,1" and step.text.contains("confirmation"),"full island guidance reviews a restorable plot without removing it")
 m.add_tile(Vector2i(2,1),"grass"); m.state.expansions = m.state.tiles.size()-4
 step = Advice.advice(m,"shaded_pond")
 check(step.action == "blueprint" and step.target == "water","finished blueprint takes priority over recrafting")
 m.begin_draft("-1,0")
 before = JSON.stringify(m.state)
 check(Advice.advice(m,"shaded_pond").action == "draft" and JSON.stringify(m.state) == before,"saved cards take priority without changing offers or quote")
 m.state.pending.clear(); m.state.blueprints.water = 0
 for resource in m.state.inventory: m.state.inventory[resource] = 20
 check(m.craft("water"),"queue fixture uses an actual crafting transaction")
 check(Advice.advice(m,"shaded_pond").action == "projects","already-crafting terrain opens the queue rather than suggesting a duplicate")
 var thirsty = Model.new(); thirsty.state.discoveries = ["rainforest"]; thirsty.add_tile(Vector2i(-1,0),"water")
 step = Advice.advice(thirsty,"shaded_pond")
 check(step.action == "inspect" and step.target == "0,0" and step.text.contains("50 moisture"),"thirsty tree guidance identifies its current moisture deficit")
 thirsty.state.tiles["0,0"].dna.heat = 80
 check(Advice.advice(thirsty,"shaded_pond").text.contains("80 heat"),"overheating is explained rather than recommending more water blindly")
 thirsty.state.tiles["0,0"].dna.heat = 25; thirsty.state.tiles["0,0"].dna.moisture = 70
 check(Advice.advice(thirsty,"shaded_pond").action == "","ready projects stop suggesting unnecessary construction")
 var working = Model.new(); working.state.discoveries = ["rainforest"]
 working.add_tile(Vector2i.ONE,"workbench"); working.add_tile(Vector2i(2,1),"windmill"); working.add_tile(Vector2i(1,2),"forest")
 working.state.tiles["2,1"].enabled = false
 step = Advice.advice(working,"living_workshop")
 check(step.action == "world" and step.target == "2,1","paused automation gets a resume route instead of another Windmill recipe")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.store.path = "user://habitat-guidance-ui-tests.json"; h.show_menu_on_launch = false
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = Model.new(); h.services.model = h.model
 h.model.state.discoveries = ["rainforest"]; h.model.state.settings.tutorial_seen = true
 h.refresh(); h.modal.hide()
 before = JSON.stringify(h.model.state)
 h.habitat_ui.follow(h,"shaded_pond")
 check(h.modal_screen == "build" and h.campaign_ui.build_choice == "workbench","real next-step action opens the selected prerequisite recipe")
 check(JSON.stringify(h.model.state) == before,"opening the guided recipe cannot start or pay for construction")
 h.model.add_tile(Vector2i.ONE,"workbench"); h.model.add_tile(Vector2i(2,1),"grass"); h.model.state.expansions = h.model.state.tiles.size()-4
 h.model.state.blueprints.water = 1
 before = JSON.stringify(h.model.state)
 h.habitat_ui.follow(h,"shaded_pond")
 check(h.placement_blueprint == "water" and not h.modal.visible and JSON.stringify(h.model.state) == before,"guided placement selects the ready blueprint without spending or deploying it")
 h.placement_blueprint = ""; h.model.state.blueprints.water = 0
 h.model.add_tile(Vector2i(-1,0),"water"); h.model.state.expansions = h.model.state.tiles.size()-4
 h.habitat_ui.show_projects(h)
 h.model.state.tiles["0,0"].dna.moisture = 70
 before = JSON.stringify(h.model.state)
 h.habitat_ui.follow(h,"shaded_pond")
 check(h.modal_screen == "habitat_projects" and JSON.stringify(h.model.state) == before,"activation recomputes stale advice when the habitat becomes ready")
 h.queue_free(); h = null; await process_frame
 print("HABITAT GUIDANCE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
