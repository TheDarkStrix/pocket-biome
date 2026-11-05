extends RefCounted
# Steps follow real progress. Looking at help never manufactures a completed action.
static func current(m) -> Dictionary:
 if m.state.chapter_rewards.has(2) or m.state.get("learning",{}).get("dismissed",false) or m.state.get("learning",{}).get("completed",false): return {}
 var learned: Dictionary = m.state.get("learning",{})
 if m.state.harvests == 0: return step("Gather your first Wood","Tap the highlighted Oak. Ready resources also earn Coins.","collect","Show the Oak","0,0")
 if m.state.expansions == 0:
  if not m.state.pending.is_empty():
   return step("Compare Water before placing it","Select Water, then tap Info. Its moisture reaches edge-sharing neighbors; place it beside the Oak.","draft","Compare the Water card")
  return step("Give the Oak a Water neighbor","Open a cloud touching the Oak. Inspect Water before confirming your land choice.","expand","Explore the cloud plots","0,0")
 var watered := false
 for at in m.neighbors("0,0"):
  if m.state.tiles[at].type == "water": watered = true
 if m.state.discoveries.is_empty():
  if not watered: return step("Bring Water beside the Oak","Inspect the Oak to see its neighbors. Add Water on an edge-sharing cloud; Rain can also help.","expand","Choose a Water neighbor","0,0")
  return step("Watch the Oak recover","Inspect its live moisture. Water adds moisture over active time; a changed biome is your first discovery.","inspect","Inspect the Oak","0,0")
 if not learned.get("inspected",false): return step("See what changed","Inspect your Oak's live conditions and neighbor influences. The same rules help with your next habitat.","inspect","Inspect the Oak","0,0")
 if not m.campaign.has_structure(m,"workbench"):
  if int(m.state.blueprints.get("workbench",0)) > 0: return step("Place your Workbench","Choose an empty Meadow. Inspect the nearby habitats before you confirm; the finished blueprint stays yours until placement.","blueprint","Place the Workbench","workbench")
  for job in m.state.jobs:
   if job.recipe == "workbench": return step("Your Workbench is being made","Review its short crafting timer. Your island keeps growing while you build.","projects","Review the Workbench project")
  return step("Build something useful","A Workbench costs 4 Wood and 2 Stone. Gather those materials, then craft it in Build. It unlocks terrain and machine recipes.","workbench","Plan a Workbench","workbench")
 if not m.state.get("habitat_projects",[]).has("shaded_pond"):
  return step("Welcome your first visitor","Review the Shaded Pond. A healthy tree beside Water can welcome frogs and unlock a reusable Water channel.","habitat","Review habitat projects")
 return {}
static func step(title: String, body: String, action: String, button: String, target: String = "") -> Dictionary:
 return {"title":title,"body":body,"action":action,"button":button,"target":target,"icon":"ecology"}
static func mark(m, field: String) -> void:
 if field not in ["inspected","compared","dismissed"]: return
 if not m.state.has("learning"): m.state.learning = {}
 m.state.learning[field] = true
 finish_if_ready(m)
static func finish_if_ready(m) -> void:
 if not m.state.get("learning",{}).get("inspected",false) or not m.state.get("habitat_projects",[]).has("shaded_pond") or not m.campaign.has_structure(m,"workbench"): return
 m.state.learning.completed = true
static func validate(value: Variant) -> bool:
 if not value is Dictionary or value.size() > 4: return false
 for key in value:
  if key not in ["inspected","compared","dismissed","completed"] or not value[key] is bool: return false
 return true
