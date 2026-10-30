extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Pricing = preload("res://scripts/ExpansionPricing.gd")
const Store = preload("res://scripts/SaveStore.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void:
 var m = Model.new()
 var unchanged := true
 var monotone := true
 var previous := 0
 var old_total := 0
 var new_total := 0
 for expansion in range(32):
  var old: int = Pricing.price(m.config.economy,expansion,1)
  var current: int = Pricing.price(m.config.economy,expansion)
  if expansion <= 12: unchanged = unchanged and old == current
  monotone = monotone and current >= previous and current <= 360
  old_total += old; new_total += current; previous = current
 check(unchanged,"the tutorial and first twelve expansion quotes keep their existing prices")
 check(monotone,"later land prices increase predictably and stay within the authored cap")
 check(new_total < old_total/3.0,"the complete36-cell island avoids the previous exponential coin demand")
 for revision in [1,2]:
  var world = Model.new()
  for x in range(2,19): world.add_tile(Vector2i(x,0),"grass")
  world.state.expansions = world.state.tiles.size()-4
  world.state.coins = 50000
  world.state.objectives = [1]
  check(world.begin_draft("19,0"),"a connected late-world draft can open")
  if revision == 1:
   world.state.pending.erase("pricing_revision")
   world.state.pending.cost = Pricing.price(world.config.economy,world.state.expansions,1)
  var quote: Dictionary = world.state.pending.duplicate(true)
  var store = Store.new(); store.path = "user://pricing-revision-%d.json" % revision
  check(store.save_state(world.state),"a valid revision%d quote saves" % revision)
  var restored = Model.new(); restored.state = store.load_state()
  check(restored.state.pending == quote,"saved revision%d offers, coordinates and price restore exactly" % revision)
  check(restored.cost() == quote.cost,"world/advice price readouts honor the actual saved revision%d quote" % revision)
  var before: int = restored.state.coins
  check(restored.begin_draft("18,1") and restored.state.pending.cards == quote.cards and restored.state.pending.cost == quote.cost,"relocation retains the quote's original policy and offers")
  check(restored.place(0) and restored.state.coins == before-int(quote.cost),"confirmation charges exactly the legacy or current saved quote once")
  check(store.save_state(restored.state),"the placed legacy/current world remains valid")
  check(restored.begin_draft("19,0") and restored.state.pending.pricing_revision == 2 and restored.state.pending.cost == Pricing.price(restored.config.economy,restored.state.expansions),"the next quote uses the current policy without modifying already-owned land")
  restored.state.pending.cost += 1
  check(not store.valid(restored.state),"a mutated revision quote cannot bypass save validation")
 for revision in [-1,0,3,"2",2.5]:
  check(not Pricing.valid_quote(m.config.economy,0,{"cost":12,"pricing_revision":revision}),"unsupported or malformed pricing revision is rejected")
 var f := FileAccess.open("res://artifacts/expansion-prices.json",FileAccess.WRITE)
 var rows := []
 for expansion in range(32): rows.append({"occupied_before":4+expansion,"old":Pricing.price(m.config.economy,expansion,1),"new":Pricing.price(m.config.economy,expansion)})
 f.store_string(JSON.stringify({"old_total":old_total,"new_total":new_total,"quotes":rows,"note":"Authored price budget, not a human retention result. Existing pending quotes keep revision1."},"  "));f.close()
 print("EXPANSION PRICING RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
