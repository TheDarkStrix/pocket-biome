extends RefCounted
# Optional guidance ledger. Real gameplay authorities determine every step.
const IDS = ["river","fusion","automation","network"]
const TITLES = {"river":"Carry a living river","fusion":"Shape a sanctuary","automation":"Let your island help","network":"Connect a thriving home"}
const River = preload("res://scripts/LivingCorridors.gd")
const Projects = preload("res://scripts/HabitatProjects.gd")
const Pacing = preload("res://scripts/PacingGuide.gd")
static func record(m) -> Dictionary: return m.state.get("lessons",{"active":"","skipped":[],"completed":[]})
static func eligible(m, id: String) -> bool:
 match id:
  "river": return River.unlocked(m)
  "fusion": return m.state.chapter >= 3
  "automation": return m.campaign.has_structure(m,"workbench")
  "network": return m.state.chapter >= 4 and m.state.get("habitat_projects",[]).has("thermal_refuge")
 return false
static func accomplished(m, id: String) -> bool:
 match id:
  "river": return River.earned(m)
  "fusion": return m.state.stats.fusions > 0
  "automation": return m.state.stats.automation_coins >= 3
  "network": return m.state.get("habitat_projects",[]).has("sanctuary_network") and Projects.network(m).ready
 return false
static func recommended(m) -> String:
 var order: Array = ["river","fusion","automation","network"] if m.state.chapter == 3 else ["automation","river","fusion","network"]
 for id in order:
  if eligible(m,id) and not accomplished(m,id) and not record(m).skipped.has(id) and not record(m).completed.has(id): return id
 return ""
static func start(m, id: String) -> bool:
 if id not in IDS or (not eligible(m,id) and not accomplished(m,id)): return false
 var s := record(m).duplicate(true); s.active = id; s.skipped.erase(id); m.state["lessons"] = s
 return true
static func skip(m) -> bool:
 var s := record(m).duplicate(true)
 if s.active == "": return false
 if not s.skipped.has(s.active): s.skipped.append(s.active)
 s.active = ""; m.state["lessons"] = s; return true
static func finish(m) -> bool:
 var s := record(m).duplicate(true)
 if s.active == "" or not accomplished(m,s.active): return false
 if not s.completed.has(s.active): s.completed.append(s.active)
 s.active = ""; m.state["lessons"] = s; return true
static func make(id: String, title: String, why: String, instruction: String, action: String, button: String, target: String = "") -> Dictionary:
 return {"step":id,"title":title,"why":why,"body":instruction,"action":action,"button":button,"target":target,"icon":"ecology"}
static func current(m, id: String = "") -> Dictionary:
 if id == "": id = record(m).active
 if id not in IDS: return {}
 if accomplished(m,id): return make("done",TITLES[id]+" · complete","You did this through real island actions.","You can revisit the instructions or continue your chapter. Lessons grant no extra currency or repeat rewards.","chapter_goal","Review my chapter")
 if id == "river":
  var s := River.record(m)
  var purpose := "Water carries recovery from your spring through shelter and flowers into a dormant corner."
  if s.get("branch","") == "": return make("approach","Choose wetland or woodland",purpose,"Choose an approach in Living Corridors. Wetland has more flow; woodland saves flow with neighboring trees.","corridors","Choose my approach")
  if s.source == "" or River.tile(m,s.source).get("type","") != "water": return make("source","Choose an existing Water spring",purpose,"Select a Water plot, then confirm it. Changing the source clears current routes, while earned moments remain.","river_plan","Choose spring","source")
  if not s.routes.has("grove") or not River.role_valid(m,"grove",s.routes.grove.path): return make("grove_path","Trace Water to a distant tree",purpose,"Tap or drag through edge-sharing natural plots to Oak or Forest at least two edges from the spring. Preview, then save; stone and machines block flow.","river_plan","Trace grove route","grove")
  var flow := River.delivered(m)
  if flow.grove < River.grove_demand(m): return make("grove_flow","Give the grove enough flow",purpose,"Use + / − so the grove receives %d flow. Delivered Water matters, not just the requested amount. Dry spells reduce supply and prioritize the grove." % River.grove_demand(m),"corridors","Review Water allocation")
  if s.growth.grove < 2: return make("grove_growth","Help the grove take root",purpose,"Keep 60 moisture and at most 65 heat, then observe seasons. Check the live soil readings and earned care tools if growth stalls.","corridors","Observe the grove")
  if not s.routes.has("garden") or not River.role_valid(m,"garden",s.routes.garden.path): return make("flower_path","Guide Sola through the grove",purpose,"Trace a flower route through the mature grove to Fiber or soil. Wetland flowers need Water beside them; woodland flowers need two healthy tree neighbors.","river_plan","Trace flower route","garden")
  var passes_grove := false
  for cell in s.routes.garden.path:
   if m.origin(cell) == m.origin(River.end_of(m,"grove")): passes_grove = true
  if not passes_grove: return make("flower_path","Route the flowers through the grove",purpose,"The current flower path bypasses the grove. Trace it again through the mature tree so Sola can travel to the flowers.","river_plan","Repair flower route","garden")
  if flow.garden < 1: return make("flower_flow","Redirect Water to the flowers",purpose,"Give the garden one delivered flow. Woodland shelter can reduce grove demand to one, freeing Water during the dry spell.","corridors","Adjust the two allocations")
  if s.growth.garden < 2: return make("flower_growth","Make the flowers welcoming",purpose,"Keep both routes working. The garden needs 50 moisture, 70 fertility and at most 65 heat, plus your approach's neighbors. Observe and review its readings.","corridors","Review the flower habitat")
  if s.seedbed == "" or River.tile(m,s.seedbed).get("size",0) != 1 or River.tile(m,s.seedbed).get("type","") not in ["grass","dirt"] or River.tile(m,s.seedbed).get("evolution","") not in ["","meadow"] or River.link(m,River.end_of(m,"garden"),s.seedbed).is_empty(): return make("seedbed","Choose a dormant corner",purpose,"Choose bare Meadow or Ploughed Soil within three natural-land steps of the garden. Confirm before Sola carries growth there.","river_plan","Choose seedbed","seedbed")
  return make("bloom","Let the corner bloom",purpose,"Keep both habitats supplied and observe seasons. The seedbed needs 50 moisture, 80 fertility and at most 65 heat for two qualifying observations. Harvest and machine clocks stay ordinary.","corridors","Review seedbed growth")
 if id == "fusion":
  var options: Array = preload("res://scripts/FusionGuide.gd").options(m,"0,0")
  var body := "Choose four matching single-cell tiles in an edge-sharing 2 × 2 square. Four in a row do not count. Build can shape the missing terrain."
  if not options.is_empty(): body += " Your closest group: "+options[0].reason
  if not options.is_empty() and options[0].ready: return make("confirm","Preview and confirm your sanctuary","The matching square is ready; confirmation changes its four plots.","Open the matching group, review its footprint, then confirm fusion. Cancel keeps all four tiles and your supplies.","fusion","Preview my ready sanctuary")
  return make("square","Find and preview a matching square","Fusion turns four plots into one larger sanctuary while keeping your discoveries.",body+" Review the footprint before confirming; active Pulse boosts must expire first.","fusion","Find a matching group")
 if id == "automation":
  if not m.campaign.has_structure(m,"windmill"):
   var plan := Pacing.recipe(m,"windmill")
   return make("mill","Craft and place a Windmill","A working Windmill earns Coins while you gather, plan and restore habitats.",plan.body,plan.action,plan.button,plan.target)
  var plan := preload("res://scripts/ObjectiveGuide.gd").advice(m,"automation_coins")
  return make("income","See your first automated income","Machines support your island without repeated collection.",plan.body+" Earn three automated Coins to finish this lesson; help screens grant none.",plan.action,plan.button,plan.target)
 for project in Projects.IDS.slice(0,4):
  if not m.state.get("habitat_projects",[]).has(project) or not Projects.inspect(m,project).ready:
   var missing: Dictionary = preload("res://scripts/HabitatGuidance.gd").advice(m,project)
   return make("habitat_"+project,"Restore "+Projects.NAMES[project],"The connected ending needs four currently suitable habitats.",missing.text,"project","Review "+Projects.NAMES[project],project)
 if Projects.network(m).ready:
  return make("claim","Complete your connected sanctuary","Your four habitats now share a living route.","Review the suitable network and complete its restoration. The final chapter also needs at least 25 land cells.","project","Complete the connected project","sanctuary_network")
 var hint: Dictionary = preload("res://scripts/HabitatGuidance.gd").advice(m,"sanctuary_network")
 return make("connect","Keep four habitats alive and connected","The ending celebrates a currently thriving island, not just old completion receipts.",hint.text+" Meadow and natural land carry the connection; blocking machinery can be moved or the land restored.","project","Review the connected sanctuary","sanctuary_network")
static func validate(value: Variant) -> bool:
 if not value is Dictionary or value.size() != 3 or not value.get("active") is String or value.active not in ["","river","fusion","automation","network"]: return false
 for field in ["skipped","completed"]:
  if not value.get(field) is Array or value[field].size() > IDS.size(): return false
  var seen := []
  for id in value[field]:
   if id not in IDS or seen.has(id): return false
   seen.append(id)
 return true

static func instructions(id: String) -> Array:
 return {
  "river":["Choose an approach and an existing Water spring. Wetland starts with four flow; woodland with three.","Trace and confirm an edge-sharing natural route to a remote tree. Allocate its required flow and observe two healthy seasons.","A dry spell removes one flow. Woodland tree shelter can lower grove demand, freeing Water for flowers.","Route flowers through the mature grove. Give one flow, 50 moisture, 70 fertility and at most 65 heat, plus the approach's neighbors.","Select nearby bare Meadow or Ploughed Soil. Maintain both habitats until its 50 moisture / 80 fertility / at most 65 heat earn two qualifying observations."],
  "fusion":["Look for four matching single-cell tiles in a 2 × 2 square; a line does not count.","Shape missing terrain in Build. Finish saved drafts and let active Pulse boosts expire.","Review the footprint and confirm fusion. Discoveries stay yours. World tools can later dismantle a sanctuary to recover its four plots."],
  "automation":["Place a Workbench, then plan a Windmill. Material help points to an actual source or missing prerequisite.","Craft the Windmill and place its finished blueprint on empty Meadow. Placement asks for confirmation.","Keep it enabled. It earns Coins at its ordinary interval while you gather, plan or restore habitats. World tools expose pause/resume and upgrades."],
  "network":["Restore the spring, pollinator garden, working woodland workshop and climate refuge.","Keep every habitat currently suitable. Earned project receipts alone do not make the ending thrive.","Connect the four through Meadow or other natural land; move blocking machines or restore the route.","Review the connected project, complete it and grow to at least 25 cells. Full discovery collection remains optional mastery."]
 }.get(id,[])
