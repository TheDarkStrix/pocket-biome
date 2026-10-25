extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
var m = Model.new()
var failures := 0
var elapsed := 0
var operations := 0
var manual_collections := 0
var milestones := []
var automation_first := false
func fail(message: String) -> void:
 printerr("PROGRESSION FAIL: "+message)
 quit(1)
func second() -> void:
 m.tick(1)
 elapsed += 1
 for key in m.state.tiles:
  var tile: Dictionary = m.state.tiles[key]
  if tile.has("owner"): continue
  if tile.ready <= m.state.time and m.harvest(key): manual_collections += 1
  if tile.type == "furnace" and m.state.inventory.brick >= 20 and tile.get("enabled",true): m.campaign.toggle_automation(m,key)
 if automation_first:
  for key in m.state.tiles:
   var tile: Dictionary = m.state.tiles[key]
   if tile.get("type","") == "windmill" and tile.get("level",1) == 1:
    var costs: Dictionary = m.config.upgrades["1"]
    if m.state.coins >= costs.coins and m.state.inventory.wood >= costs.wood and m.state.inventory.stone >= costs.stone:
     m.campaign.upgrade_structure(m,key)
 for resource in ["wood","stone","fiber","clay","iron","brick"]:
  if m.state.inventory[resource] > 200: m.campaign.trade(m,resource,100)
 if elapsed > 50000: fail("economy exceeded 50,000 active seconds")
func can_pay(cost: Dictionary) -> bool:
 for resource in cost:
  if m.state.inventory[resource] < cost[resource]: return false
 return true
func blueprint(type: String) -> void:
 if m.state.blueprints.get(type,0) > 0: return
 var recipe: Dictionary = {}
 for candidate in m.config.crafting:
  if candidate.get("tile","") == type: recipe = candidate
 if recipe.is_empty(): fail("no crafting path to "+type); return
 if not m.campaign.has_structure(m,recipe.requires): fail("missing craft prerequisite "+recipe.requires); return
 while not can_pay(recipe.cost) or m.state.jobs.size() >= 3: second()
 if not m.craft(recipe.id): fail("craft rejected "+type); return
 mark("craft_started",{"type":type})
 while m.state.blueprints.get(type,0) < 1: second()
 operations += 1
func set_plot(at: String, type: String, reset: bool = false) -> void:
 var tile: Dictionary = m.state.tiles[at]
 if tile.type == type and not reset: return
 # Finish the blueprint first: an unattended meadow can evolve while crafting.
 if type != "grass": blueprint(type)
 tile = m.state.tiles[at]
 if tile.type != "grass" or tile.evolution != "":
  if not m.campaign.retire(m,at): fail("cannot restore "+at); return
 if type == "grass": return
 if not m.deploy(type,at): fail("blueprint deployment rejected "+at+" / "+type)
 mark("blueprint_placed",{"type":type})
 operations += 1
func buy(at: String) -> void:
 if m.state.tiles.has(at): return
 if not m.frontier().has(at): fail("planned plot disconnected "+at); return
 while m.state.coins < m.cost(): second()
 if not m.begin_draft(at): fail("expansion transaction rejected "+at); return
 var choice := 0
 for index in range(m.state.pending.cards.size()):
  if m.config.tiles[m.state.pending.cards[index]].resource == "wood": choice = index; break
 if not m.place(choice): fail("expansion transaction rejected "+at)
 operations += 1
func mark(name: String, details: Dictionary = {}) -> void:
 milestones.append({"active_seconds":m.state.time,"event":name,"details":details})
func _init() -> void:
 # Fix only the starting seed. Earned progression uses public transactions; waiting is accelerated.
 automation_first = OS.get_cmdline_user_args().has("--automation-first")
 m.state.seed = 90210
 m.occurred.connect(func(name: String, data: Dictionary):
  if name in ["tile_placed","biome_discovered","fusion_completed","chapter_completed","world_pulse_used","structure_upgraded"]: mark(name,data))
 m.harvest("0,0"); manual_collections += 1
 m.begin_draft("-1,0")
 m.place(1)
 for i in range(5): second()
 if not m.state.discoveries.has("rainforest"): fail("first evolution not reached"); return
 m.pulse("rain","0,0")
 blueprint("workbench")
 m.deploy("workbench","1,1")
 buy("2,0"); set_plot("2,0","clay")
 buy("3,0")
 while m.state.inventory.clay < 3: second()
 set_plot("3,0","furnace")
 buy("4,0"); set_plot("4,0","iron")
 for at in ["2,1","2,2","3,2","4,2","2,3","3,3","4,3","3,4"]: buy(at)
 set_plot("2,1","windmill")
 buy("1,-1"); set_plot("1,-1","golem")
 for at in ["4,1","5,1","6,1"]: buy(at); set_plot(at,"windmill")
 var sources := {"rainforest":["water"],"ember":["vent","crystal"],"lake":["crystal"],"steam":["water","vent"],"frozen":["glacier","water"],"meadow":["forest","water"],"mossrock":["forest","water"],"reedwater":["forest"],"sunstone":["vent","crystal"],"mistforest":["water","glacier"],"crystalforest":["crystal","stone"],"oasis":["water","vent"],"ironwood":["vent","stone"],"moonflower":["crystal","glacier"],"obsidian":["vent","crystal"],"celestial":["water","forest","stone","crystal"]}
 var around := ["2,3","4,3","3,2","3,4"]
 for recipe in m.config.recipes:
  if m.state.discoveries.has(recipe.id): continue
  for key in around: set_plot(key,"grass")
  for i in range(sources[recipe.id].size()): set_plot(around[i],sources[recipe.id][i])
  set_plot("3,3",recipe.types[0],true)
  for i in range(50):
   if m.state.discoveries.has(recipe.id): break
   second()
  if not m.state.discoveries.has(recipe.id): fail("recipe unreachable through ordinary play: "+recipe.id); return
 for y in range(4):
  for x in [-1,-2,-3,-4]: buy("%d,%d" % [x,y])
 var origins := [Vector2i(-2,0),Vector2i(-4,0),Vector2i(-2,2),Vector2i(-4,2)]
 for i in range(m.config.fusions.size()):
  var recipe: Dictionary = m.config.fusions[i]
  var origin: Vector2i = origins[i]
  for offset in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: set_plot(m.key(origin+offset),recipe.type)
  if not m.fuse(m.key(origin)): fail("fusion rejected "+recipe.id); return
 for i in range(5): second()
 if m.state.discoveries.size() != 20: fail("catalog incomplete"); return
 if m.state.chapter_rewards.size() != 5: fail("chapter goals incomplete "+str(m.state.stats)); return
 var store = preload("res://scripts/SaveStore.gd").new()
 store.path = "user://complete-progression-test.json"
 if not store.save_state(m.state): fail("final world failed save validation: "+store.error); return
 var restored: Dictionary = store.load_state()
 if restored.discoveries.size() != 20 or restored.chapter_rewards.size() != 5: fail("final progression not restored"); return
 var max_gap := 0.0
 var prior := 0.0
 var first_fifteen := []
 for milestone in milestones:
  max_gap = maxf(max_gap,milestone.active_seconds-prior); prior = milestone.active_seconds
  if milestone.active_seconds <= 900: first_fifteen.append(milestone)
 var evidence := {"seed":90210,"policy":"Collect ready resources, prefer Wood when offered, craft/restore through public transactions; trade surplus above 200.","automation_first":automation_first,"active_seconds":elapsed,"manual_collections":manual_collections,"total_harvests_including_automation":m.state.harvests,"tracked_progression_operations":operations,"max_gap_between_progress_events_seconds":max_gap,"first_fifteen_minutes":first_fifteen,"note":"Omniscient accelerated simulation; not a human session or enjoyment/retention result."}
 var evidence_file := FileAccess.open("res://artifacts/pacing-automation.json" if automation_first else "res://artifacts/pacing-simulation.json",FileAccess.WRITE)
 evidence_file.store_string(JSON.stringify(evidence,"  ")); evidence_file.close()
 print("PROGRESSION RESULT: all 20 discoveries, all 5 chapters, %d cells, %d gameplay transactions, %d active seconds, coins %d" % [m.state.tiles.size(),operations,elapsed,m.state.coins])
 quit(0)
