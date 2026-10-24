extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Store = preload("res://scripts/SaveStore.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 var model = Model.new()
 check(model.config.recipes.size()+model.config.fusions.size() == 20,"twenty authored discoveries")
 var rarity := {"common":0,"uncommon":0,"rare":0,"legendary":0}
 for recipe in model.config.recipes+model.config.fusions: rarity[recipe.rarity] += 1
 check(rarity == {"common":6,"uncommon":7,"rare":5,"legendary":2},"authored rarity distribution")
 var sources := {"rainforest":["water"],"ember":["vent","crystal"],"lake":["crystal"],"steam":["water","vent"],"frozen":["glacier","water"],"meadow":["forest","water"],"mossrock":["forest","water"],"reedwater":["forest"],"sunstone":["vent","crystal"],"mistforest":["water","glacier"],"crystalforest":["crystal","stone"],"oasis":["water","vent"],"ironwood":["vent","stone"],"moonflower":["crystal","glacier"],"obsidian":["vent","crystal"],"celestial":["water","forest","stone","crystal"]}
 for recipe in model.config.recipes:
  var world = Model.new()
  world.state.tiles.clear()
  world.add_tile(Vector2i.ZERO,recipe.types[0])
  for i in range(sources[recipe.id].size()): world.add_tile(Model.DIRS[i],sources[recipe.id][i])
  for i in range(40): world.tick()
  check(world.state.discoveries.has(recipe.id),"environmentally reachable: "+recipe.id)
 for recipe in model.config.fusions:
  var world = Model.new()
  world.state.tiles.clear()
  for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: world.add_tile(at,recipe.type)
  check(world.fuse("0,0") and world.state.discoveries.has(recipe.id),"fusion recipe: "+recipe.id)
  var store = Store.new()
  check(store.valid(world.state),"valid fused state: "+recipe.id)
 var crafting = Model.new()
 crafting.state.inventory.wood = 20
 crafting.state.inventory.stone = 20
 check(crafting.craft("workbench"),"workbench craftable by hand")
 crafting.tick(4)
 check(crafting.state.blueprints.get("workbench",0) == 1,"craft output committed after active timer")
 crafting.tick(1)
 check(crafting.state.blueprints.workbench == 1,"craft completion cannot duplicate")
 check(crafting.deploy("workbench","1,1"),"blueprint deployed on explicit empty meadow")
 check(not crafting.deploy("workbench","0,0"),"resource node protected from blueprint overwrite")
 check(not crafting.campaign.retire(crafting,"0,0"),"starting harvest access cannot be removed")
 check(crafting.campaign.retire(crafting,"1,1"),"explicit structure retirement")
 check(crafting.state.blueprints.workbench == 1,"structure recovered as blueprint")
 check(not crafting.craft("brick"),"furnace prerequisite enforced")
 var auto = Model.new()
 auto.add_tile(Vector2i(2,0),"golem")
 auto.add_tile(Vector2i(2,1),"windmill")
 auto.state.expansions = 2
 auto.tick(8)
 check(auto.state.inventory.stone == 1,"golem uses shared harvest authority")
 check(auto.state.stats.automation_coins == 1,"windmill pays once per scheduled transaction")
 auto.tick(0)
 check(auto.state.inventory.stone == 1 and auto.state.stats.automation_coins == 1,"same-time automation cannot replay")
 auto.state.inventory.stone = auto.config.economy.inventory_limit
 auto.tick(20)
 check(auto.state.inventory.stone == auto.config.economy.inventory_limit,"automation respects inventory cap")
 var store = Store.new()
 store.path = "user://campaign-test.json"
 check(store.save_state(auto.state),"expanded campaign save")
 check(store.load_state().stats.automation_coins == auto.state.stats.automation_coins,"automation roundtrip")
 var legacy = Model.new().state
 legacy.version = 1
 for field in preload("res://scripts/CampaignSystem.gd").defaults(): legacy.erase(field)
 legacy.inventory.erase("brick"); legacy.inventory.erase("star_dew")
 check(store.save_state(legacy),"legacy save accepted")
 var upgraded = store.load_state()
 check(upgraded.version == 3 and upgraded.settings.reduced_motion == false,"schema migration to campaign")
 var version_two = Model.new().state
 version_two.version = 2
 version_two.coins = 123
 version_two.settings.music = false
 for field in ["audio_levels","text_scale","hints"]: version_two.erase(field)
 for field in ["tutorial_seen","vibration"]: version_two.settings.erase(field)
 check(store.save_state(version_two),"schema 2 saves accepted for migration")
 var migrated = store.load_state()
 check(migrated.version == 3 and migrated.coins == 123 and not migrated.settings.music,"schema 2 migration preserves economy and preferences")
 check(migrated.audio_levels.music == 0.6 and migrated.text_scale == 1.0 and migrated.hints.is_empty(),"schema 2 migration supplies new accessibility/audio/hint defaults")
 var dusk = Model.new()
 dusk.state.chapter = 3
 dusk.state.time = 301
 dusk.add_tile(Vector2i(-1,0),"water")
 dusk.state.expansions = 1
 check(dusk.campaign.start_event(dusk),"optional Dusk starts only when available")
 check(not dusk.state.event.targets.has("0,0") and not dusk.state.event.targets.has("1,0") and not dusk.state.event.targets.has("0,1"),"Dusk excludes critical resource nodes")
 dusk.state.time += 61
 dusk.campaign.event_tick(dusk)
 check(dusk.state.event.until == 0 and dusk.state.inventory.wood == 0,"ignored Dusk passes without resource loss")
 var reward_world = Model.new()
 reward_world.state.chapter = 3
 reward_world.state.time = 601
 reward_world.state.energy = 200
 reward_world.add_tile(Vector2i(-1,0),"water")
 reward_world.state.expansions = 1
 reward_world.campaign.start_event(reward_world)
 var targets: Array = reward_world.state.event.targets.duplicate()
 for target in targets:
  if reward_world.state.event.until > 0: reward_world.pulse("heat",target)
 check(reward_world.state.event.completed == 1 and reward_world.state.event.until == 0,"Heat interventions resolve the Dusk challenge")
 var earned: int = reward_world.state.coins
 reward_world.tick(1)
 check(reward_world.state.coins == earned,"Dusk reward cannot duplicate")
 var upgrades = Model.new()
 upgrades.add_tile(Vector2i(2,0),"windmill")
 upgrades.state.coins = 100
 upgrades.state.inventory.wood = 10
 upgrades.state.inventory.stone = 10
 check(upgrades.campaign.upgrade_structure(upgrades,"2,0"),"structure upgrade spends an atomic material/coin cost")
 check(upgrades.state.coins == 75 and upgrades.state.inventory.wood == 5,"upgrade cost exact")
 upgrades.tick(5)
 check(upgrades.state.stats.automation_coins == 2,"upgraded windmill produces the configured benefit")
 print("CAMPAIGN RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
