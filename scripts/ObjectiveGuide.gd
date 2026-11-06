extends RefCounted
const Projects = preload("res://scripts/HabitatProjects.gd")
const Habitat = preload("res://scripts/HabitatGuidance.gd")
const Pacing = preload("res://scripts/PacingGuide.gd")
static func rows(m) -> Array:
 var result := []
 var chapter: Dictionary = m.campaign.chapter_definition(m)
 for id in chapter.checks:
  var row := advice(m,id)
  row["id"] = id; row["title"] = m.campaign.ACTIONS.get(id,"Explore your island")
  row["current"] = m.campaign.metric(m,id); row["required"] = int(chapter.checks[id]); row["done"] = row.current >= row.required
  result.append(row)
 return result
static func advice(m, id: String) -> Dictionary:
 var why := ""; var info := {}
 if id == "living_river":
  var river = preload("res://scripts/LivingCorridors.gd")
  info = Pacing.step(river.status(m).body,"corridors","Plan the Living River"); why = "A spring, grove and pollinator route bring a dormant corner back to life."
 elif id.begins_with("restored_") or id == "thriving_network":
  var project: String = {"restored_spring":"shaded_pond","restored_garden":"pollinator_patch","restored_workshop":"living_workshop","restored_climate":"thermal_refuge","thriving_network":"sanctuary_network"}.get(id,"")
  var hint: Dictionary = Habitat.advice(m,project)
  info = Pacing.step(hint.get("text",Projects.RULES.get(project,"")),"project","Review "+Projects.NAMES.get(project,"habitat"),project)
  why = Projects.UNLOCKS.get(project,"Keep all four habitats suitable and connected.")
 elif id == "fusions":
  var groups: Array = preload("res://scripts/FusionGuide.gd").options(m,"0,0")
  info = Pacing.step("Four matching single-cell tiles must share a 2 × 2 square. "+("Shape missing tiles in Build." if groups.is_empty() else groups[0].reason),"fusion","Find a matching square")
  why = "Combine a carefully shaped neighborhood into one larger sanctuary."
 elif id in ["crafted_brick","built_windmill","built_golem"]:
  var type: String = {"crafted_brick":"brick","built_windmill":"windmill","built_golem":"golem"}[id]
  info = Pacing.recipe(m,type)
  if info.has("text"): info["body"] = info.text; info["button"] = info.label; info.action = "blueprint" if info.action == "blueprint" else info.action
  if info.action == "build": info.action = "recipe"
  why = {"brick":"Brick supports the buildings that sustain your island.","windmill":"A working Windmill earns Coins without repeated tapping.","golem":"A Golem collects ready Stone or Iron from its neighboring plots."}[type]
 elif id == "automation_coins":
  why = "Let your island's machinery help pay for expansion."
  var at := ""
  for key in m.state.tiles:
   if m.state.tiles[key].get("type","") == "windmill" and not m.state.tiles[key].has("owner"): at = key; break
  if at == "": info = Pacing.recipe(m,"windmill")
  else:
   var tile: Dictionary = m.state.tiles[at]
   info = Pacing.step("This Windmill is paused. Resume it in World tools." if not tile.get("enabled",true) else "Your Windmill earns %d Coin(s) every %ds · next output in %ds. Gather or restore habitats while it runs." % [tile.get("level",1),m.config.tiles.windmill.interval,ceili(maxf(0,tile.next_production-m.state.time))],"world","Show my Windmill",at)
 elif id in ["cells","expansions"]:
  why = "Make room for neighboring habitats and connected living land."
  info = Pacing.step("Your saved cards and quoted price are waiting." if not m.state.pending.is_empty() else "Choose an edge-sharing cloud. The next plot costs %d Coins; you have %d." % [m.cost(),m.state.coins],"draft" if not m.state.pending.is_empty() else "expand","Review saved cards" if not m.state.pending.is_empty() else "Explore cloud plots")
  if m.state.pending.is_empty() and m.state.coins < m.cost(): info = Pacing.source(m,"coins",m.cost()-m.state.coins)
 elif id == "discoveries":
  why = "Experiment with local conditions to learn what your island can grow."
  info = Pacing.step("The Journal has free clues. Inspect moisture, heat and neighbors on the island; recorded discoveries remain yours.","journal","Find a discovery clue")
 elif id == "pulses":
  why = "Learn to deliberately change a habitat's conditions."
  info = Pacing.step("You need 100 energy. Preview Rain, Heat or Frost and confirm a target; chapter rewards and discoveries replenish energy.","pulse","Preview a World Pulse")
 elif id == "harvests":
  why = "Gather materials and Coins for your first expansion."
  info = Pacing.source(m,"wood",1)
 else: info = Pacing.step("Review the Journal and your island's tools.","journal","Open Journal")
 info["why"] = why
 return info
