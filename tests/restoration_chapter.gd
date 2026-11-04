extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Projects = preload("res://scripts/HabitatProjects.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func find_button(node: Node, title: String) -> Button:
 for child in node.find_children("*","Button",true,false):
  if child.text == title: return child
 return null
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = Model.new()
 m.harvest("0,0"); m.begin_draft("-1,0"); m.place(1)
 for second in range(4): m.tick(1)
 check(m.state.chapter == 2 and m.objective_text().contains("Create a living habitat"),"the first evolution leads to a concrete home restoration goal")
 check(m.campaign.metric(m,"habitats") == 0,"unclaimed layouts do not silently count as completed projects")
 var coins: int = m.state.coins
 check(Projects.claim(m,"shaded_pond"),"the existing Water/Oak experiment can complete the first habitat through normal rules")
 check(m.campaign.metric(m,"habitats") == 1 and m.state.coins == coins+40,"one habitat claim records a milestone and its one-time reward")
 check(m.objective_text().contains("Expand your island"),"after restoration the campaign guides the next unmet objective")
 check(not Projects.claim(m,"shaded_pond") and m.state.coins == coins+40,"restoration milestone cannot replay reward")
 m.state.tiles["0,0"].dna.moisture = 0
 check(m.campaign.metric(m,"habitats") == 1,"later habitat changes do not erase campaign accomplishments")
 var old = Model.new(); old.state.chapter = 3; old.state.chapter_rewards = [1,2]
 var store = preload("res://scripts/SaveStore.gd").new()
 check(store.valid(old.state),"old earned chapter rewards remain valid without a new habitat field")
 old.campaign.evaluate(old)
 check(old.state.chapter == 3 and old.state.chapter_rewards == [1,2],"old completed chapters are not reopened or downgraded")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://restoration-onboarding-tests.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = Model.new(); h.services.model = h.model; h.model.state.settings.tutorial_seen = true
 h.refresh(); h.modal.hide()
 var before := JSON.stringify(h.model.state)
 h.open_ideas()
 check(h.modal_title.text == "Your next step" and find_button(h.modal_box,"Show the Oak") != null,"first teaching step offers one concrete harvest action")
 check(find_button(h.modal_box,"Explore other ideas") != null,"teaching remains optional rather than locking exploration")
 check(JSON.stringify(h.model.state) == before,"opening the teaching step cannot harvest or grant progress")
 h.modal.hide(); h.model.harvest("0,0"); h.refresh(); h.open_ideas()
 check(find_button(h.modal_box,"Explore the cloud plots") != null and find_button(h.modal_box,"Show the Oak") == null,"teaching advances from harvesting to expansion")
 h.model.begin_draft("-1,0"); h.model.place(1); h.open_ideas()
 check(find_button(h.modal_box,"Inspect the Oak") != null,"after placement the next step explains live environmental change")
 find_button(h.modal_box,"Inspect the Oak").pressed.emit()
 check(h.inspection_mode,"the teaching shortcut opens the real condition inspector")
 h.queue_free(); h = null; await process_frame
 print("RESTORATION CHAPTER RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
