extends RefCounted
# Read-only help: uses real costs, production sources and active-time timers.
static func step(text: String, action: String, button: String, target: String = "") -> Dictionary:
 return {"body":text,"action":action,"button":button,"target":target,"icon":"craft"}
static func source(m, resource: String, amount: int) -> Dictionary:
 var best := ""; var wait := INF
 for at in m.state.tiles:
  var tile: Dictionary = m.state.tiles[at]
  if tile.has("owner") or m.production(tile).resource != resource: continue
  var seconds: float = maxf(0,tile.ready-m.state.time)
  if seconds < wait: best = at; wait = seconds
 if best != "":
  return step("Need %d more %s. This %s produces it%s. Gather other ready nodes while it recovers; opening help does not advance timers." % [amount,resource.capitalize(),m.state.tiles[best].type.capitalize()," now" if wait <= 0 else " in %ds of active play" % ceili(wait)],"resource","Show "+resource.capitalize()+" source",best)
 if resource == "brick": return step("Brick is crafted in a Furnace. Its recipe shows the required Wood and Stone.","recipe","Plan Brick","brick")
 if resource == "coins": return step("Need %d more Coins. Harvest ready resources, or trade spare materials while keeping construction stock." % amount,"trade","Review spare-material trades")
 return step("No current plot produces %s. Compare land offers or craft suitable terrain in Build; Discoveries explains transformed resources." % resource.capitalize(),"workshop","Find a resource source")
static func recipe(m, id: String, quantity: int = 1) -> Dictionary:
 for recipe in m.config.crafting:
  if recipe.id != id: continue
  if not m.state.pending.is_empty(): return step("Finish your saved land choice first. Its offers and quoted price are kept.","draft","Review saved cards")
  if recipe.has("tile") and m.state.blueprints.get(recipe.tile,0) > 0:
   var guidance: Dictionary = preload("res://scripts/HabitatGuidance.gd").supply(m,recipe.tile)
   return step(guidance.text,"recipe" if guidance.action == "build" else guidance.action,guidance.label,guidance.target)
  for job in m.state.jobs:
   if job.recipe == id: return step("%s is being made · %ds left. Gather ready resources or plan neighbors while this project runs; no extra payment is needed." % [recipe.name,ceili(maxf(0,job.until-m.state.time))],"projects","Review project timer")
  if not m.campaign.has_structure(m,recipe.requires): return step("Place a %s first to unlock this recipe. You keep your materials until you confirm crafting." % recipe.requires.capitalize(),"recipe","Plan "+recipe.requires.capitalize(),recipe.requires)
  for resource in recipe.cost:
   var owned: int = m.state.coins if resource == "coins" else m.state.inventory.get(resource,0)
   var required: int = int(recipe.cost[resource])*quantity
   if owned < required: return source(m,resource,required-owned)
  if m.state.jobs.size() >= 3: return step("All three project slots are working. Review the soonest finish; you can gather or plan your island meanwhile.","projects","Review working projects")
  return step("Materials ready. Craft %s, then place its blueprint on empty Meadow." % recipe.name if recipe.has("tile") else "Materials ready. Craft "+recipe.name+" in Build.","recipe","Plan "+recipe.name,id)
 return step("Review the available recipes in Build.","workshop","Open Build")
static func next_ready(m) -> int:
 var seconds := INF
 for at in m.state.tiles:
  var tile: Dictionary = m.state.tiles[at]
  if tile.has("owner") or m.production(tile).resource == "": continue
  if m.state.inventory.get(m.production(tile).resource,0) >= m.config.economy.inventory_limit: continue
  seconds = minf(seconds,maxf(0,tile.ready-m.state.time))
 return -1 if seconds == INF else ceili(seconds)
