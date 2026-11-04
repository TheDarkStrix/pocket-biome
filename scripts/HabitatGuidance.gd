extends RefCounted
const Projects = preload("res://scripts/HabitatProjects.gd")
static func step(text: String, action: String, label: String, target: String = "") -> Dictionary:
 return {"text":text,"action":action,"label":label,"target":target}
static func supply(model, kind: String) -> Dictionary:
 if not model.state.pending.is_empty(): return step("Your saved land choice is waiting. Finish or review it before planning this placement.","draft","Review saved cards")
 if int(model.state.blueprints.get(kind,0)) > 0:
  for key in model.state.tiles:
   var t: Dictionary = model.state.tiles[key]
   if not t.has("owner") and t.type == "grass" and t.evolution == "" and t.size == 1 and not model.state.event.targets.has(key):
    return step("A %s blueprint is already ready. Choose an empty Grass plot; placing it costs no more materials." % kind.capitalize(),"blueprint","Place ready "+kind.capitalize(),kind)
  for key in model.state.tiles:
   var t: Dictionary = model.state.tiles[key]
   if key not in ["0,0","1,0","0,1"] and not t.has("owner") and t.size == 1 and not model.state.event.targets.has(key):
    return step("Your blueprint is ready, but it needs empty Grass. Review a restorable plot; restoration replaces its biome and asks for confirmation.","world","Review space for blueprint",key)
  return step("Your blueprint is ready, but no empty Grass plot is available. Expand to make room.","expand","Review cloud plots")
 for job in model.state.jobs:
  if job.recipe == kind: return step("Your %s is already being crafted. Review its timer and collect the finished blueprint there." % kind.capitalize(),"projects","Review current project")
 if kind == "fiber": return step("Look for Fiber in land expansion offers. Placement beside Water and a healthy tree is what matters.","expand","Review cloud plots")
 if kind != "workbench" and not model.campaign.has_structure(model,"workbench"):
  return step("A Workbench unlocks the recipe you need. Craft and place one first; its material requirements are shown before payment.","build","Plan a Workbench","workbench")
 return step("Craft %s, then place its blueprint beside the habitat. The Build tray shows benefits, prerequisites and owned/required materials." % kind.capitalize(),"build","Plan "+kind.capitalize(),kind)
static func advice(model, id: String) -> Dictionary:
 if id not in Projects.IDS: return {}
 if model.state.discoveries.is_empty(): return step("First make a discovery at home. Water beside Oak is a useful starting experiment.","ideas","Find a first step")
 var current := Projects.inspect(model,id)
 if current.ready: return step("This layout is suitable. Completed projects keep their reward even if you later change the habitat.","","",current.anchor)
 if id == "sanctuary_network":
  for project in Projects.IDS.slice(0,4):
   if not model.state.get("habitat_projects",[]).has(project) or not Projects.inspect(model,project).ready:
    return step("Restore "+Projects.NAMES[project]+" and keep its habitat suitable before connecting the sanctuary.","habitats","Review restoration projects")
  return step("The four habitats need one green route. Replace blocking machines with natural land or move them; empty Meadow also carries the path.","world","Review the green corridor",current.anchor)
 if id == "thermal_refuge":
  if current.anchor == "": return supply(model,"forest")
  return step("Shelter a tree beside Glacier with 60 moisture and at most 35 heat, or beside a Rain Totem with 80 moisture and 35–65 heat. Water channels and shade can help.","inspect","Inspect the climate refuge",current.anchor)
 if current.anchor == "": return supply(model,{"shaded_pond":"water","pollinator_patch":"fiber","living_workshop":"workbench"}[id])
 var plant := ""; var water := false; var mill := false; var paused := ""
 for key in model.neighbors(current.anchor):
  var t: Dictionary = model.state.tiles[key]
  if Projects.tree(t): plant = key
  if t.type == "water": water = true
  if t.type == "windmill":
   if t.get("enabled",true): mill = true
   else: paused = key
 if id == "living_workshop" and not mill:
  if paused != "": return step("The neighboring Windmill is paused. Review it in World tools and resume it when ready.","world","Review paused Windmill",paused)
  return supply(model,"windmill")
 if id == "pollinator_patch" and not water: return supply(model,"water")
 if plant == "": return supply(model,"forest")
 var tile: Dictionary = model.state.tiles[plant]
 if tile.dna.heat > 65: return step("This neighboring tree has %d heat; the habitat needs 65 or less. Inspect its heat sources and consider cooling or a different neighbor." % tile.dna.heat,"inspect","Inspect overheated tree",plant)
 if id == "living_workshop" and tile.dna.fertility < 60: return step("The tree has %d fertility; it needs 60. Inspect nearby influences, or plan Compost to enrich neighboring land." % tile.dna.fertility,"build","Plan Compost","compost")
 return step("The tree has %d moisture; it needs 60. Keep Water beside it as time passes, or use Rain. Inspect its influences to check what is helping." % tile.dna.moisture,"inspect","Inspect thirsty tree",plant)
