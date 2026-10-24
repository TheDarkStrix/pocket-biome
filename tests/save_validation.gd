extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Store = preload("res://scripts/SaveStore.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 var store = Store.new()
 store.path = "user://validation-save.json"
 var model = Model.new()
 var baseline: Dictionary = model.state.duplicate(true)
 var invalid_values = [null,true,"oops",[],{},-1.5,INF,NAN]
 for field in baseline:
  for invalid in invalid_values:
   var broken = baseline.duplicate(true)
   broken[field] = invalid
   # Empty collections are legitimate for some initial fields.
   if broken == baseline: continue
   check(not store.valid(broken),"reject root %s = %s" % [field,str(invalid)])
 for field in baseline.tiles["0,0"]:
  for invalid in invalid_values:
   var broken = baseline.duplicate(true)
   broken.tiles["0,0"][field] = invalid
   if broken == baseline: continue
   check(not store.valid(broken),"reject tile %s = %s" % [field,str(invalid)])
 var bad = baseline.duplicate(true)
 bad.tiles["1,1"] = {"owner":"0,0"}
 check(not store.valid(bad),"dangling fusion reference")
 bad = baseline.duplicate(true)
 bad.tiles["0,0"].size = 4
 bad.tiles["0,0"].evolution = "grove"
 bad.discoveries = ["grove"]
 check(not store.valid(bad),"incomplete fusion footprint")
 bad = baseline.duplicate(true)
 bad.tiles["1,0"].id = bad.tiles["0,0"].id
 check(not store.valid(bad),"duplicate entity ID")
 bad = baseline.duplicate(true)
 bad.tiles["0,0"].boosts = [{"power":"rain","until":12,"applied":{"moisture":"bad"}}]
 check(not store.valid(bad),"malformed temporary modifier")
 model.harvest("0,0")
 model.begin_draft("-1,0")
 bad = model.state.duplicate(true)
 bad.pending.at = "50,50"
 check(not store.valid(bad),"nonadjacent pending transaction")
 bad = model.state.duplicate(true)
 bad.pending.cost = 1
 check(not store.valid(bad),"forged draft price")
 check(store.save_state(model.state),"save valid pending transaction")
 var committed = FileAccess.get_file_as_string(store.path)
 check(not store.save_state(bad),"reject invalid write")
 check(FileAccess.get_file_as_string(store.path) == committed,"invalid write preserves primary")
 var f = FileAccess.open(store.path+".tmp",FileAccess.WRITE)
 f.store_string("{interrupted")
 f.close()
 check(store.load_state().pending.at == "-1,0","ignore interrupted temporary file")
 var corruptions = ["null","[]","{broken",JSON.stringify(bad)]
 check(store.save_state(model.state),"create known backup")
 for text in corruptions:
  f = FileAccess.open(store.path,FileAccess.WRITE)
  f.store_string(text)
  f.close()
  check(store.load_state().pending.at == "-1,0","fallback from "+text.left(20))
 var resumed = Model.new()
 resumed.state = store.load_state()
 var coins: int = resumed.state.coins
 var energy: int = resumed.state.energy
 resumed.objectives()
 check(resumed.state.coins == coins and resumed.state.energy == energy,"objective reward cannot replay after JSON load")
 check(resumed.state.coins is int and resumed.state.objectives[0] is int,"load restores integer identity")
 print("SAVE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
