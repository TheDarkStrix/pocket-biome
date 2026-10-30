extends RefCounted
signal occurred(name: String, data: Dictionary)
# Authoritative state; no scene dependencies. All timers use active simulation time.
const Campaign = preload("res://scripts/CampaignSystem.gd")
var campaign = Campaign.new()
const DIRS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/game.json"))
var state: Dictionary
var message := "Harvest the Oak, then open a cloud plot beside it."

func _init() -> void:
 state = {"version":3,"seed":randi() % 1000000000,"tiles":{},"coins":int(config.economy.starting_coins),"inventory":{"wood":0,"stone":0,"fiber":0,"clay":0,"iron":0},"expansions":0,"pending":{},"discoveries":[],"energy":0,"time":0.0,"harvests":0,"objectives":[],"next_id":1}
 state.merge(Campaign.defaults())
 state.inventory.merge({"brick":0,"star_dew":0})
 add_tile(Vector2i(0,0), "oak")
 add_tile(Vector2i(1,0), "stone")
 add_tile(Vector2i(0,1), "fiber")
 add_tile(Vector2i(1,1), "grass")

func key(c: Vector2i) -> String:
 return "%d,%d" % [c.x,c.y]

func coord(k: String) -> Vector2i:
 var a = k.split(",")
 return Vector2i(int(a[0]),int(a[1]))

func add_tile(c: Vector2i, type: String) -> void:
 var d: Dictionary = config.tiles[type]
 var dna := {}
 for i in range(5): dna[config.attributes[i]] = d.dna[i]
 state.tiles[key(c)] = {"id":state.next_id,"type":type,"dna":dna,"ready":0.0,"last_tap":-1.0,"evolution":"","size":1,"level":1,"next_effect":state.time+config.tiles[type].get("effect_interval",1),"next_production":state.time+config.tiles[type].get("interval",0)}
 state.next_id += 1
 if type in ["golem","windmill"]: state.stats["built_"+type] += 1

func origin(k: String) -> String:
 if not state.tiles.has(k): return ""
 return state.tiles[k].get("owner", k)

func footprint(k: String) -> Array[String]:
 k = origin(k)
 var cells: Array[String] = []
 if k == "": return cells
 cells.append(k)
 if state.tiles[k].size == 4:
  for offset in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: cells.append(key(coord(k)+offset))
 return cells

func neighbors(k: String) -> Array[String]:
 var source := origin(k)
 var result: Array[String] = []
 for cell in footprint(source):
  for direction in DIRS:
   var neighbor := origin(key(coord(cell)+direction))
   if neighbor != "" and neighbor != source and not result.has(neighbor): result.append(neighbor)
 result.sort()
 return result

func pulse_targets(k: String) -> Array[String]:
 var center := origin(k)
 if center == "": return []
 var targets := neighbors(center)
 targets.push_front(center)
 return targets

func frontier() -> Array[String]:
 var out: Array[String] = []
 if state.tiles.size() >= int(config.economy.max_cells): return out
 for k in state.tiles:
  for d in DIRS:
   var n := key(coord(k)+d)
   if not state.tiles.has(n) and not out.has(n): out.append(n)
 out.sort()
 return out

func cost() -> int:
 if not state.pending.is_empty(): return int(state.pending.cost)
 return preload("res://scripts/ExpansionPricing.gd").price(config.economy,int(state.expansions))

func begin_draft(k: String) -> bool:
 if not state.pending.is_empty():
  if not frontier().has(k):
   message = "Choose a cloud beside your island. Your card choices are kept."
   return false
  state.pending.at = k
  message = "Draft moved to this plot. Your cards and price are unchanged."
  return true
 if not frontier().has(k) or state.coins < cost():
  message = "Expansion costs %d coins · you have %d. Harvest resources to earn more." % [cost(),state.coins] if state.coins < cost() else "Choose a cloud directly beside your island."
  return false
 if state.expansions == 0: record_event("first_draft")
 var cards: Array = preload("res://scripts/DraftDealer.gd").deal(config,int(state.seed),int(state.expansions),int(state.chapter))
 state.pending = {"at":k,"cost":cost(),"cards":cards,"pricing_revision":preload("res://scripts/ExpansionPricing.gd").CURRENT_REVISION}
 return true

func place(index: int) -> bool:
 if state.pending.is_empty() or index < 0 or index >= 3: return false
 var p: Dictionary = state.pending
 if state.tiles.has(p.at) or not frontier().has(p.at) or state.coins < p.cost: return false
 add_tile(coord(p.at),p.cards[index])
 state.coins -= p.cost
 if state.expansions == 0: record_event("first_expansion")
 state.expansions += 1
 record_event("tile_placed",{"type":p.cards[index]})
 state.pending = {}
 message = "Nearby tiles influence each other. Hold a tile to see what it can become."
 objectives()
 return true

func harvest(k: String, automatic: bool = false) -> bool:
 k = origin(k)
 if k.is_empty(): return false
 var t: Dictionary = state.tiles[k]
 var def := production(t)
 var amount: int = def.amount
 if def.resource == "": return false
 if state.inventory[def.resource]+amount > config.economy.inventory_limit:
  if not automatic: message = "Storage full. Craft with your materials to make room."
  return false
 if state.time < t.ready:
  if state.time-t.last_tap >= 0.25-0.000001:
   if t.ready-state.time > 1.0: t.ready = maxf(state.time+1.0,t.ready-0.5)
   t.last_tap = state.time
  return false
 state.inventory[def.resource] += amount
 state.coins += int(config.economy.harvest_coins)
 t.ready = state.time+def.cooldown
 if state.harvests == 0: record_event("first_harvest")
 state.harvests += 1
 message = "+%d %s · +2 coins" % [amount,def.resource]
 objectives()
 return true

func objectives() -> void:
 var checks = [state.harvests >= 1,state.expansions >= 1,state.discoveries.size() >= 1]
 for i in range(checks.size()):
  if checks[i] and not state.objectives.has(i):
   state.objectives.append(i)
   record_event("quest_completed",{"objective":i})
   if i == 2: record_event("tutorial_completed")
   state.coins += 10
   state.energy = mini(200,state.energy+100)

func objective_text() -> String:
 if not state.objectives.has(0): return "FIRST SEED · Tap Oak to gather Wood (+10 coins)"
 if not state.objectives.has(1): return "NEW HORIZONS · Tap a cloud; choose Water beside Oak"
 if not state.objectives.has(2): return "LIVING ROOTS · Raise Oak moisture to 70 (Water or Rain)"
 var chapter: Dictionary = campaign.chapter_definition(self)
 if state.chapter_rewards.has(5): return "YOUR LIVING WORLD · All chapters complete. Keep creating."
 for id in chapter.checks:
  var current: int = campaign.metric(self,id)
  if current < chapter.checks[id]:
   var names := {"cells":"Expand your island","discoveries":"Discover new biomes","pulses":"Use World Pulse","fusions":"Create a sanctuary fusion","crafted_brick":"Craft Bricks","built_golem":"Build a Stone Golem","built_windmill":"Build a Windmill","automation_coins":"Earn automated Coins"}
   return "%s · %d / %d" % [names.get(id,id),current,chapter.checks[id]]
 return "Chapter complete · "+chapter.name

func advance_time(seconds: float) -> void:
 if is_finite(seconds) and seconds > 0: state.time += seconds

func tick(seconds: float = 1.0) -> void:
 advance_time(seconds)
 var buffer := {}
 var emissions := {}
 var keys: Array = state.tiles.keys()
 keys.sort()
 for k in keys:
  var source: Dictionary = state.tiles[k]
  if source.has("owner") or not source.get("enabled",true): continue
  var interval: int = config.tiles[source.type].get("effect_interval",1)
  if state.time >= source.get("next_effect",0.0):
   emissions[k] = config.effects.get(source.type,{})
   source.next_effect = next_cycle(source.get("next_effect",state.time),interval,state.time)
 for k in keys:
  var t: Dictionary = state.tiles[k]
  if t.has("owner"): continue
  buffer[k] = t.dna.duplicate()
  for n in neighbors(k):
   var effects: Dictionary = emissions.get(n,{})
   for a in effects: buffer[k][a] += effects[a]*int(state.tiles[n].get("level",1))
  for a in buffer[k]: buffer[k][a] = clampi(buffer[k][a],0,100)
 for k in buffer: state.tiles[k].dna = buffer[k]
 expire_boosts()
 evaluate()
 campaign.tick(self)

func evaluate() -> void:
 for depth in range(clampi(int(config.simulation.max_chain_depth),1,4)):
  if not evaluate_once(): break
 objectives()

func evaluate_once() -> bool:
 var changed := false
 var keys: Array = state.tiles.keys()
 keys.sort()
 for k in keys:
  var t: Dictionary = state.tiles[k]
  if t.has("owner") or t.size == 4: continue
  var current_tier := 0
  for known in config.recipes:
   if known.id == t.evolution: current_tier = known.tier
  for r in config.recipes:
   if not t.type in r.types or r.tier <= current_tier: continue
   var ok := true
   for structure in r.structures:
    if not campaign.has_structure(self,structure): ok = false
   if r.pulse != "" and (t.get("last_pulse","") != r.pulse or t.get("last_pulse_until",0) < state.time): ok = false
   for a in r.min:
    if t.dna[a] < r.min[a]: ok = false
   for a in r.max:
    if t.dna[a] > r.max[a]: ok = false
   if ok:
    t.evolution = r.id
    changed = true
    discover(r.id,r.name,r.reward)
    break
 return changed

func discover(id: String, title: String, reward: int) -> void:
 message = "DISCOVERED · " + title
 if not state.discoveries.has(id):
  if state.discoveries.is_empty(): record_event("first_discovery")
  state.discoveries.append(id)
  record_event("biome_discovered",{"id":id})
  state.coins += reward
  state.energy = mini(200,state.energy+100)
  state.inventory.star_dew = mini(config.economy.inventory_limit,state.inventory.star_dew+1)

func pulse(power: String, k: String) -> bool:
 if not config.powers.has(power) or origin(k).is_empty() or state.energy < 100: return false
 var targets := pulse_targets(k)
 if power == "frost" and state.chapter < 2: return false
 if power == "heat":
  for target in targets: campaign.clear_event_target(self,target)
 state.stats.pulses += 1
 record_event("world_pulse_used",{"power":power})
 state.energy -= 100
 for n in targets:
  state.tiles[n].last_pulse = power
  state.tiles[n].last_pulse_until = state.time+12
  var applied := {}
  for a in config.powers[power]:
   var previous: int = state.tiles[n].dna[a]
   state.tiles[n].dna[a] = clampi(previous+config.powers[power][a],0,100)
   applied[a] = state.tiles[n].dna[a]-previous
  # Rain growth benefit is immediate; DNA boost expires after 12 active seconds.
  if power == "rain" and config.tiles[state.tiles[n].type].resource in ["wood","fiber"]: state.tiles[n].ready = maxf(state.time,state.tiles[n].ready-3)
  if not state.tiles[n].has("boosts"): state.tiles[n].boosts = []
  state.tiles[n].boosts.append({"power":power,"until":state.time+12,"applied":applied})
 evaluate()
 campaign.event_tick(self)
 campaign.evaluate(self)
 return true

func expire_boosts() -> void:
 for k in state.tiles:
  var t: Dictionary = state.tiles[k]
  if t.has("owner"): continue
  var keep := []
  for b in t.get("boosts",[]):
   if b.until <= state.time:
    for a in b.applied: t.dna[a] = clampi(t.dna[a]-b.applied[a],0,100)
   else: keep.append(b)
  t.boosts = keep

func fusion_recipe(k: String) -> Dictionary:
 if not state.tiles.has(k): return {}
 for recipe in config.fusions:
  var compatible := true
  for offset in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]:
   var tile: Dictionary = state.tiles.get(key(coord(k)+offset),{})
   if state.event.targets.has(key(coord(k)+offset)): compatible = false
   if tile.is_empty() or tile.has("owner") or tile.get("type","") != recipe.type or tile.get("size",0) != 1 or not tile.get("boosts",[]).is_empty(): compatible = false
  if compatible: return recipe
 return {}

func can_fuse(k: String) -> bool:
 return not fusion_recipe(k).is_empty()

func fuse(k: String) -> bool:
 var recipe := fusion_recipe(k)
 if recipe.is_empty(): return false
 var cells := [k,key(coord(k)+Vector2i.RIGHT),key(coord(k)+Vector2i.DOWN),key(coord(k)+Vector2i.ONE)]
 var shared_ready := 0.0
 var dna := {}
 for attribute in config.attributes:
  var total := 0
  for cell in cells: total += state.tiles[cell].dna[attribute]
  dna[attribute] = roundi(total/4.0)
 for cell in cells: shared_ready = maxf(shared_ready,state.tiles[cell].ready)
 var first: Dictionary = state.tiles[k]
 first.ready = shared_ready
 first.dna = dna
 first.size = 4
 first.evolution = recipe.id
 for offset in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: state.tiles[key(coord(k)+offset)] = {"owner":k}
 if state.stats.fusions == 0: record_event("first_fusion")
 state.stats.fusions += 1
 record_event("fusion_completed",{"id":recipe.id})
 discover(recipe.id,recipe.name,recipe.reward)
 objectives()
 campaign.evaluate(self)
 return true

func spend(costs: Dictionary) -> bool:
 for resource in costs:
  if not (costs[resource] is int or costs[resource] is float) or not is_finite(float(costs[resource])) or costs[resource] < 0 or costs[resource] != floor(float(costs[resource])): return false
  if resource == "coins":
   if state.coins < costs[resource]: return false
  elif not state.inventory.has(resource) or state.inventory[resource] < costs[resource]: return false
 for resource in costs:
  if resource == "coins": state.coins -= int(costs[resource])
  else: state.inventory[resource] -= int(costs[resource])
 return true

func craft(recipe_id: String, quantity: int = 1) -> bool:
 return campaign.craft(self,recipe_id,quantity)

func deploy(blueprint: String, at: String) -> bool:
 return campaign.deploy(self,blueprint,at)

func record_event(name: String, data: Dictionary = {}) -> void:
 occurred.emit(name,data)

func reroll_draft() -> bool:
 if state.pending.is_empty() or state.pending.get("ad_rerolled",false): return false
 var pool: Array = config.draft_pools[str(mini(int(state.chapter),3))].duplicate()
 pool.append_array(config.draft_rules.foundation_cards)
 pool.append_array(config.draft_rules.tutorial_cards)
 var cards: Array = preload("res://scripts/DraftDealer.gd").deal(config,int(state.seed),int(state.expansions),int(state.chapter),true)
 if cards == state.pending.cards:
  for type in pool:
   if not cards.has(type): cards[2] = type; break
 state.pending.cards = cards
 state.pending.ad_rerolled = true
 return true

func production(tile: Dictionary) -> Dictionary:
 var base: Dictionary = config.tiles[tile.type]
 var definition: Dictionary = base.duplicate()
 definition.amount = int(tile.size)
 for recipe in config.recipes+config.fusions:
  if recipe.id == tile.evolution and recipe.has("resource"):
   definition.resource = recipe.resource
   definition.cooldown = recipe.cooldown
   definition.amount = recipe.yield_amount
 # The original three nodes always retain a free path to essential materials.
 if int(tile.id) <= 3 and definition.resource != base.resource:
  definition.resource = base.resource
  definition.cooldown = base.cooldown
  definition.amount = int(tile.size)
  for recipe in config.recipes:
   if recipe.id == tile.evolution: definition.amount = maxi(definition.amount,recipe.tier)
 return definition

static func next_cycle(scheduled: float, interval: float, now: float) -> float:
 # Keep the original cadence; minor frame lateness must not add a whole tick.
 # A long stalled frame skips elapsed slots instead of granting a burst of work.
 return scheduled+interval*maxf(1,floorf((now-scheduled)/interval)+1)
