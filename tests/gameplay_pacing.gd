extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Dealer = preload("res://scripts/DraftDealer.gd")
const Advisor = preload("res://scripts/GameplayAdvisor.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func has_action(items: Array, action: String) -> bool:
 for item in items:
  if item.action == action: return true
 return false
func _init() -> void:
 var m = Model.new()
 var tutorial: Array = Dealer.deal(m.config,17,0,1)
 check(tutorial[0] == "forest" and tutorial[1] == "water" and tutorial.size() == 3,"first draft preserves the normal Water tutorial")
 for chapter in [1,2,3]:
  var allowed: Array = m.config.draft_pools[str(chapter)].duplicate()
  allowed.append_array(m.config.draft_rules.foundation_cards)
  allowed.append_array(m.config.draft_rules.tutorial_cards)
  for seed in [17,90210]:
   var all_valid := true
   var stable := true
   var types := {}
   var distinct_offers := {}
   for expansion in range(1,13):
    var cards: Array = Dealer.deal(m.config,seed,expansion,chapter)
    all_valid = all_valid and cards.size() == 3 and cards[0] != cards[1] and cards[0] != cards[2] and cards[1] != cards[2]
    for card in cards: all_valid = all_valid and allowed.has(card); types[card] = true
    stable = stable and cards == Dealer.deal(m.config,seed,expansion,chapter)
    distinct_offers[str(cards)] = true
   check(all_valid and stable,"unique eligible offers remain deterministic for chapter %d seed %d" % [chapter,seed])
   check(types.size() >= 6 and distinct_offers.size() >= 5,"post-tutorial hands expose several genuinely different choices")
 var fresh: Array = Advisor.ideas(m,"0,0")
 check(has_action(fresh,"collect") and has_action(fresh,"expand"),"first-session guidance provides achievable collection and expansion choices")
 for x in range(2,13): m.add_tile(Vector2i(x,0),"grass")
 m.state.expansions = m.state.tiles.size()-4
 m.state.coins = 103; m.state.inventory.wood = 165
 var before := JSON.stringify(m.state)
 var stalled: Array = Advisor.ideas(m,"0,0")
 check(has_action(stalled,"trade"),"the reported surplus-Wood/short-coins situation exposes the existing free trade route")
 check(JSON.stringify(m.state) == before,"suggestions do not spend, rearrange, reward or mutate saved progression")
 check(m.campaign.trade(m,"wood",20) and m.campaign.trade(m,"wood",5) and m.state.coins >= m.cost(),"two voluntary trades can fund the next plot in this inventory fixture")
 m.begin_draft("13,0")
 var cards: Array = m.state.pending.cards.duplicate()
 check(has_action(Advisor.ideas(m,"0,0"),"draft"),"a postponed draft remains an actionable choice")
 m.begin_draft("12,1")
 check(m.state.pending.cards == cards,"moving a new-style draft cannot redeal it")
 var saved = preload("res://scripts/SaveStore.gd").new(); saved.path = "user://pacing-save.json"
 check(saved.save_state(m.state) and saved.load_state().pending.cards == cards,"new offers retain the unchanged atomic-save contract")
 var n = Model.new()
 var water: String = Advisor.placement(n,"water","-1,0")
 check(water.contains("+8 moisture") and water.contains("1 neighboring biome"),"card placement explains the actual local environmental effect")
 n.add_tile(Vector2i(-1,0),"forest")
 check(Advisor.placement(n,"water","-1,1").contains("2 neighboring biomes"),"local card effect count follows the chosen location")
 var productive = Model.new()
 productive.add_tile(Vector2i(1,1),"workbench")
 productive.state.harvests = 10; productive.state.coins = 100
 productive.state.inventory.wood = 20; productive.state.inventory.stone = 20
 check(has_action(Advisor.ideas(productive,"0,0"),"workshop"),"a Workbench owner can discover passive income without a mandatory extra objective")
 productive.add_tile(Vector2i(2,0),"windmill")
 var upgrade_found := false
 for idea in Advisor.ideas(productive,"0,0"):
  if idea.action == "world" and idea.get("target","") == "2,0": upgrade_found = true
 check(upgrade_found and productive.state.tiles["2,0"].level == 1,"upgrade advice finds a real affordable machine without spending on the player's behalf")
 productive.state.coins = 30; productive.state.expansions = productive.state.tiles.size()-4
 productive.begin_draft("3,0")
 var reserved: String = JSON.stringify(productive.state)
 check(not productive.campaign.upgrade_structure(productive,"2,0") and JSON.stringify(productive.state) == reserved,"an upgrade cannot consume coins reserved by an unfinished saved plot")
 var kiln = Model.new()
 kiln.add_tile(Vector2i(1,1),"furnace")
 kiln.state.inventory.wood = 4; kiln.state.inventory.stone = 5
 kiln.tick(5)
 check(kiln.state.jobs.is_empty() and kiln.state.inventory.stone == 5,"automatic brick production cannot eat the initial construction reserve")
 kiln.state.inventory.wood = 5; kiln.state.inventory.stone = 7
 kiln.tick(5)
 check(kiln.state.jobs.size() == 1 and kiln.state.inventory.wood == 4 and kiln.state.inventory.stone == 5,"automatic crafting resumes from genuine surplus and keeps the reserve")
 check(kiln.craft("brick") and kiln.state.inventory.wood == 3 and kiln.state.inventory.stone == 3,"explicit manual crafting can spend reserved stock")
 var samples := []
 for expansion in range(12): samples.append(Dealer.deal(m.config,90210,expansion,2))
 var report := {"seed":90210,"chapter":2,"offers":samples,"note":"Deterministic offer samples, not human enjoyment/retention evidence."}
 var file := FileAccess.open("res://artifacts/draft-variety.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(report,"  ")); file.close()
 print("PACING RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
