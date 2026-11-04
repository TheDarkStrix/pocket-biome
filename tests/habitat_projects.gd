extends SceneTree
const Projects = preload("res://scripts/HabitatProjects.gd")
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func world():
 var m = Model.new()
 m.state.discoveries = ["rainforest"]; m.state.objectives = [0,1,2]; m.state.settings.tutorial_seen = true
 m.add_tile(Vector2i(-1,0),"water"); m.add_tile(Vector2i(-1,1),"water")
 m.add_tile(Vector2i(1,1),"workbench"); m.add_tile(Vector2i(2,1),"windmill"); m.add_tile(Vector2i(1,2),"forest")
 m.state.tiles["0,0"].dna.moisture = 60
 m.state.expansions = m.state.tiles.size()-4
 return m
func button(node: Node, text: String) -> Button:
 for action in node.find_children("*","Button",true,false):
  if action.text == text: return action
 return null
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = world()
 var before := JSON.stringify(m.state)
 for id in Projects.IDS.slice(0,3): check(Projects.inspect(m,id).ready,"real neighboring tiles satisfy "+id)
 check(JSON.stringify(m.state) == before,"project inspection never changes terrain, conditions or rewards")
 m.state.tiles["0,0"].dna.heat = 80
 check(not Projects.inspect(m,"shaded_pond").ready and not Projects.inspect(m,"pollinator_patch").ready,"overheated trees cannot support cool wildlife habitats")
 m.state.tiles["0,0"].dna.heat = 25
 m.state.tiles["2,1"].enabled = false
 check(not Projects.inspect(m,"living_workshop").ready,"a paused windmill cannot qualify an active workshop")
 m.state.tiles["2,1"].enabled = true
 var coins: int = m.state.coins
 for id in Projects.IDS.slice(0,3):
  check(Projects.claim(m,id),"suitable project can be explicitly claimed: "+id)
  check(not Projects.claim(m,id),"same project cannot grant a second reward: "+id)
 check(m.state.coins == coins+180 and Projects.visitors(m).size() == 3,"all three rewards and visitor groups are accounted for")
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://habitat-projects-tests.json"
 check(store.save_state(m.state) and store.load_state().habitat_projects == m.state.habitat_projects,"completed project records persist through JSON load")
 m.state.tiles["0,0"].dna.moisture = 0
 check(Projects.visitors(m).size() == 1 and m.state.coins == coins+180,"unsuitable habitats lose visitors without confiscating rewards")
 for record in [["unknown"],["shaded_pond","shaded_pond"],true,[1]]:
  var corrupt: Dictionary = m.state.duplicate(true); corrupt.habitat_projects = record
  check(not store.valid(corrupt),"invalid or duplicate project records are rejected")
 var locked = world(); locked.state.discoveries.clear()
 check(not Projects.claim(locked,"shaded_pond"),"rewards wait for the introductory discovery")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.store.path = "user://habitat-ui-tests.json"; h.show_menu_on_launch = false
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = world(); h.services.model = h.model
 h.refresh(); h.modal.hide(); h.habitat_ui.show_projects(h)
 check(button(h.modal_box,"Complete project · 40 Coins") != null,"ready habitat exposes a named reward action")
 var path: String = h.store.path; h.store.path = "user://absent-habitat-parent/fail.json"
 var initial: int = h.model.state.coins
 h.habitat_ui.claim(h,"shaded_pond")
 check(h.model.state.coins == initial and not h.model.state.has("habitat_projects"),"failed save rolls back the complete reward transaction")
 h.store.path = path; h.habitat_ui.claim(h,"shaded_pond")
 check(h.store.load_state().habitat_projects.has("shaded_pond") and h.model.state.coins == initial+40,"successful claim commits reward and receipt together")
 h.habitat_ui.claim(h,"shaded_pond")
 check(h.model.state.coins == initial+40,"repeated real UI callback cannot duplicate a committed reward")
 h.model.state.tiles["0,0"].dna.moisture = 0; h.refresh()
 check(h.habitat_visitors.is_empty(),"rendered visitor cache follows current habitat conditions")
 check(button(h.modal_box,"Complete project · 60 Coins").disabled,"an open project screen updates when an environmental condition becomes unsuitable")
 h.model.state.tiles["0,0"].dna.moisture = 60; h.refresh()
 check(not button(h.modal_box,"Complete project · 60 Coins").disabled,"open project screen enables completion when conditions recover")
 h.queue_free(); h = null; await process_frame
 print("HABITAT PROJECTS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
