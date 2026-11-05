extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Learn = preload("res://scripts/LearningJourney.gd")
const Projects = preload("res://scripts/HabitatProjects.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 var evidence := []
 for seed in range(12):
  var m = Model.new(); m.state.seed = seed; m.state.ecology_rules = "balanced"
  var first_discovery := -1
  for second in range(180):
   var step := Learn.current(m)
   if step.is_empty(): break
   match step.action:
    "collect": m.harvest("0,0")
    "expand":
     if m.begin_draft("-1,0" if seed%2 == 0 else "0,-1"):
      for index in range(m.state.pending.cards.size()):
       if m.state.pending.cards[index] == "water": m.place(index); break
    "draft":
     for index in range(m.state.pending.cards.size()):
      if m.state.pending.cards[index] == "water": m.place(index); break
    "inspect":
     if not m.state.discoveries.is_empty(): Learn.mark(m,"inspected")
    "workbench": m.craft("workbench")
    "blueprint": m.deploy("workbench","1,1")
    "habitat": Projects.claim(m,"shaded_pond")
   # The visible Gather-ready affordance is used after its first-harvest unlock.
   if m.state.harvests > 0: m.harvest_ready()
   m.tick(1)
   if first_discovery < 0 and not m.state.discoveries.is_empty(): first_discovery = second+1
  check(m.state.get("learning",{}).get("completed",false),"visible-step explorer finishes building and first restoration for seed "+str(seed))
  check(m.state.get("habitat_projects",[]).has("shaded_pond") and m.campaign.has_structure(m,"workbench"),"explorer earns real prerequisites without injecting materials")
  var store = preload("res://scripts/SaveStore.gd").new()
  check(store.valid(m.state),"explorer outcome remains a valid save")
  evidence.append({"seed":seed,"first_discovery_active_seconds":first_discovery,"completed_active_seconds":m.state.time,"coins":m.state.coins,"note":"Affordance-driven simulated route; not a human understanding or enjoyment result."})
 var file = FileAccess.open("res://artifacts/director-explorers.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(evidence,"  ")); file.close()
 print("DIRECTOR EXPLORERS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
