extends RefCounted
# Read-only affordances, not additional chores, payouts or timers.
static func ideas(model, selected: String) -> Array:
 var result := []
 if model.state.objectives.size() >= 3:
  var goals := {2:["shaded_pond"],3:["pollinator_patch"],4:["living_workshop","thermal_refuge"],5:["sanctuary_network"]}
  for id in goals.get(int(model.state.chapter),[]):
   if not model.state.get("habitat_projects",[]).has(id):
    var projects = preload("res://scripts/HabitatProjects.gd")
    result.append({"title":projects.NAMES[id],"body":projects.RULES[id]+" Unlock: "+projects.UNLOCKS[id],"action":"habitat","button":"Plan the chapter restoration","icon":"ecology"})
    break
 if model.state.harvests == 0:
  result.append({"title":"Bring your island to life","body":"Collect Wood from the Oak, then choose its first neighbor. Water can help its roots transform.","action":"collect","target":"0,0","button":"Show the Oak","icon":"wood"})
 if not model.state.pending.is_empty():
  result.append({"title":"Your next plot is waiting","body":"Compare the three cards, or move the same offers to another cloud. Coins are spent only when you place one.","action":"draft","button":"Review my cards","icon":"world"})
 if not model.state.discoveries.is_empty():
  var projects = preload("res://scripts/HabitatProjects.gd")
  for id in projects.IDS:
   if not model.state.get("habitat_projects",[]).has(id) and projects.inspect(model,id).ready:
    result.append({"title":projects.NAMES[id]+" is ready","body":"Your neighboring plots support a habitat project. Review it to welcome wildlife and claim its one-time reward.","action":"habitat","button":"Review habitat projects","icon":"ecology"})
    break
 var expeditions = preload("res://scripts/Expedition.gd")
 for id in expeditions.ISLANDS:
  if expeditions.unlocked(model,id) and not model.state.get("expeditions",{}).get(id,{}).get("completed",false):
   result.append({"title":"Restore "+expeditions.NAMES[id],"body":"A new environmental puzzle awaits beyond home. Review its rules on the expedition map; rearrangement is free and home supplies stay safe.","action":"expedition","button":"Explore expedition islands","icon":"world"})
   break
 var empty := ""
 for key in model.state.tiles:
  var tile: Dictionary = model.state.tiles[key]
  if tile.get("type","") == "grass" and tile.get("evolution","") == "" and tile.get("size",0) == 1 and not model.state.event.targets.has(key): empty = key; break
 if model.state.pending.is_empty():
  for type in model.state.blueprints:
   if model.state.blueprints[type] <= 0: continue
   if empty != "":
    result.append({"title":"Your %s is ready" % type.capitalize(),"body":"Choose where it will help the island. Its blueprint is already crafted.","action":"blueprint","target":type,"button":"Choose its place","icon":"craft"})
   else:
    result.append({"title":"Make room for your blueprint","body":"Select an unprotected plot and use World to restore it to Meadow, or expand with Grass. Restoration replaces that plot; discoveries stay collected.","action":"world","button":"Open world tools","icon":"world"})
   break
 if model.state.chapter == 3 and model.state.stats.fusions == 0:
  var groups: Array = preload("res://scripts/FusionGuide.gd").options(model,selected)
  var body := "Four matching tiles form a square. You can shape tiles in the Workshop as well as draft them."
  if not groups.is_empty(): body = groups[0].reason
  result.append({"title":"Create your first sanctuary","body":body,"action":"fusion","button":"Find a matching group","icon":"craft"})
 if model.state.pending.is_empty() and model.state.tiles.size() < model.config.economy.max_cells and model.state.coins < model.cost():
  var spare := false
  for resource in ["wood","stone","fiber","clay","iron","brick"]:
   if model.state.inventory[resource] >= 10: spare = true
  if spare:
   result.append({"title":"Spare materials can fund a plot","body":"You need %d more coins. Trade materials at one coin each, while keeping enough for your next project." % (model.cost()-model.state.coins),"action":"trade","button":"Choose what to trade","icon":"coins"})
 if not model.campaign.has_structure(model,"workbench") and model.state.harvests >= 3:
  result.append({"title":"Open up new building choices","body":"A Workbench costs 4 Wood and 2 Stone. It lets you shape the tiles you need instead of waiting for a lucky draft.","action":"workshop","button":"Plan a Workbench","icon":"craft"})
 if model.campaign.has_structure(model,"workbench") and model.state.pending.is_empty():
  if not model.campaign.has_structure(model,"windmill"):
   result.append({"title":"Start earning while you experiment","body":"A Windmill produces coins without repeated collection. Craft one and decide where its plot fits your island.","action":"workshop","button":"Plan a Windmill","icon":"craft"})
  else:
   for key in model.state.tiles:
    var tile: Dictionary = model.state.tiles[key]
    if tile.get("type","") != "windmill" or tile.get("level",1) >= 3: continue
    var level: int = tile.get("level",1)
    var costs: Dictionary = model.config.upgrades[str(level)]
    var affordable := true
    for resource in costs:
     var owned: int = model.state.coins if resource == "coins" else model.state.inventory.get(resource,0)
     if owned < costs[resource]: affordable = false
    if affordable:
     result.append({"title":"Make this Windmill work harder","body":"Upgrade from %d to %d coins every %ds. Compare the upgrade cost with buying more land; your existing mill keeps working." % [level,level+1,model.config.tiles.windmill.interval],"action":"world","target":key,"button":"Review this upgrade","icon":"craft"})
     break
 if model.state.expansions > 0 and model.state.energy >= 100 and model.state.stats.pulses == 0:
  result.append({"title":"Change the conditions yourself","body":"Try Rain, Heat or Frost on a chosen area. Preview its reach before confirming; discoveries and chapter rewards replenish energy.","action":"pulse","button":"Explore World Pulse","icon":"rain"})
 if model.state.pending.is_empty() and model.state.coins >= model.cost() and not model.frontier().is_empty():
  result.append({"title":"Choose a new neighbor","body":"You can afford a %d-coin plot. Compare the cards and their nearby effects; where you place them changes what grows." % model.cost(),"action":"expand","button":"Explore the cloud plots","icon":"world"})
 result.append({"title":"Try a different transformation","body":"Water, warmth and crystals change what nearby land can become. The Journal has free clues for every discovery.","action":"journal","button":"Explore discovery clues","icon":"codex"})
 return result.slice(0,3)

static func placement(model, type: String, at: String) -> String:
 var neighbors := []
 for offset in model.DIRS:
  var origin: String = model.origin(model.key(model.coord(at)+offset))
  if origin != "" and not neighbors.has(origin): neighbors.append(origin)
 if model.config.tiles[type].category == "structure":
  if type == "golem":
   var targets := 0
   for key in neighbors:
    if model.production(model.state.tiles[key]).resource in ["stone","iron"]: targets += 1
   return "Here: reaches %d Stone or Iron node%s. Its helper cannot collect from plots outside that reach." % [targets,"" if targets == 1 else "s"]
  return "Build a %s on this new plot, or choose natural land to grow another biome." % type.capitalize()
 var effects: Dictionary = model.config.effects.get(type,{})
 if neighbors.is_empty(): return "No neighboring land will be influenced here."
 if effects.is_empty():
  return "This plot touches %d existing biomes. Nearby sources will shape its conditions." % neighbors.size()
 var parts := PackedStringArray()
 for attribute in effects: parts.append("%+d %s" % [effects[attribute],attribute])
 var seconds: int = model.config.tiles[type].get("effect_interval",1)
 return "Here: shares %s with %d neighboring biome%s every %ds. Other nearby sources can strengthen or oppose the effect." % [", ".join(parts),neighbors.size(),"" if neighbors.size() == 1 else "s",seconds]

# Read-only preview: direct neighbors and configured influences, never secret recipes.
static func placement_neighbors(model, at: String) -> Array[String]:
 var result: Array[String] = []
 for direction in model.DIRS:
  var target: String = model.origin(model.key(model.coord(at)+direction))
  if target != "" and not result.has(target): result.append(target)
 result.sort()
 return result

static func placement_summary(model, type: String, at: String) -> String:
 var neighbors := placement_neighbors(model,at)
 if neighbors.is_empty(): return "No neighbors here yet. Expand next to living land to connect habitats."
 var names := PackedStringArray()
 for key in neighbors:
  var name: String = str(model.state.tiles[key].type).capitalize()
  if not names.has(name): names.append(name)
 var effects: Dictionary = model.config.effects.get(type,{})
 var descriptions := PackedStringArray()
 var words := {"moisture":"adds moisture", "heat":"adds warmth", "fertility":"enriches soil", "stability":"adds stability", "magic":"shares magic"}
 for attribute in effects:
  if effects[attribute] > 0: descriptions.append(words.get(attribute,attribute))
  elif effects[attribute] < 0: descriptions.append("cools the land" if attribute == "heat" else "reduces "+attribute)
 var action := ", ".join(descriptions) if not descriptions.is_empty() else "receives conditions from nearby sources"
 return "%s %s near %s. Changes happen over time." % [type.capitalize(),action,", ".join(names)]
