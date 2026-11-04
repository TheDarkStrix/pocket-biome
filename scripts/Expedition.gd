extends RefCounted
# A bounded, reversible ecology puzzle. Home inventory, timers and rewards are untouched.
const ID = "dry_springs"
const TREES = [0,8]
const ISLANDS = ["dry_springs","frost_hollow","ember_shore"]
const NAMES = {"dry_springs":"Dry Springs","frost_hollow":"Frost Hollow","ember_shore":"Ember Shore"}
static func island(s: Dictionary) -> String: return s.get("island",ID)
static func trees(s: Dictionary) -> Array: return [0,2] if island(s) == "frost_hollow" else TREES
static func budget(s: Dictionary, kind: String) -> int:
 if kind == "vent": return 1 if island(s) == "frost_hollow" else 0
 return 2 if island(s) == "frost_hollow" else 3
static func unlocked(model, id: String) -> bool:
 if id not in ISLANDS or model.state.discoveries.is_empty(): return false
 var position: int = ISLANDS.find(id)
 return position == 0 or model.state.get("expeditions",{}).get(ISLANDS[position-1],{}).get("completed",false)
static func healthy(s: Dictionary, tree: int) -> bool:
 if s.moisture[tree] < 70: return false
 if island(s) == "frost_hollow": return s.heat[tree] >= 60 and s.heat[tree] <= 85
 if island(s) == "ember_shore": return s.heat[tree] >= 35 and s.heat[tree] <= 65
 return true
static func instructions(s: Dictionary) -> String:
 var common := "Tap a plot, then choose terrain. Changes are free; only edge-sharing neighbors count. "
 if island(s) == "frost_hollow": return common+"One Vent adds 15 warmth per season to each adjacent Oak. Water beside a tree removes 10 warmth. Groves need 60–85 warmth; moisture stays at 80. Flowers need Water and a healthy grove."
 if island(s) == "ember_shore": return common+"The volcanic air adds 5 heat each season. Each neighboring Water removes 20 heat and adds 15 moisture. Groves need 35–65 heat and 70 moisture. The volcanic rock is fixed. Flowers need Water and a healthy grove."
 return common+"Each season adds 15 moisture per neighboring Water; a dry tree loses 10. Groves need 70 moisture. Flowers need Water and a living grove."
static func fresh(id: String = ID) -> Dictionary:
 if id not in ISLANDS: return {}
 var result: Dictionary = {"plots":["oak","meadow","meadow","meadow","meadow","meadow","meadow","meadow","oak"],"moisture":[25,0,0,0,0,0,0,0,25],"seasons":0,"completed":false}
 if id != ID:
  result.island = id
  result.heat = [0,0,0,0,0,0,0,0,0]
  if id == "frost_hollow":
   result.plots[8] = "meadow"; result.plots[2] = "oak"; result.moisture[8] = 0
   for tree in [0,2]: result.moisture[tree] = 80; result.heat[tree] = 20
  elif id == "ember_shore":
   result.plots[2] = "vent"
   for tree in TREES: result.heat[tree] = 95
 return result
static func neighbors(index: int) -> Array[int]:
 var result: Array[int] = []
 for other in range(9):
  if absi(other%3-index%3)+absi(other/3-index/3) == 1: result.append(other)
 return result
static func count_near(s: Dictionary, index: int, kind: String) -> int:
 var count := 0
 for other in neighbors(index):
  if s.plots[other] == kind: count += 1
 return count
static func groves(s: Dictionary) -> int:
 var total := 0
 for tree in trees(s):
  if healthy(s,tree): total += 1
 return total
static func habitat(s: Dictionary, index: int) -> bool:
 if s.plots[index] != "flowers" or count_near(s,index,"water") == 0: return false
 for other in neighbors(index):
  if other in trees(s) and healthy(s,other): return true
 return false
static func progress(s: Dictionary) -> Dictionary:
 var connected := 0
 for tree in trees(s):
  if count_near(s,tree,"vent" if island(s) == "frost_hollow" else "water") > 0: connected += 1
 var habitats := 0
 for index in range(9):
  if habitat(s,index): habitats += 1
 return {"connected":connected,"groves":groves(s),"habitats":habitats,"ready":connected == 2 and groves(s) == 2 and habitats >= 2}
static func goal(s: Dictionary) -> String:
 if s.completed: return "%s is restored. Wildlife has returned to its flowering habitats." % NAMES[island(s)]
 var p := progress(s)
 if p.connected < 2:
  return ("1 · Place your Vent to warm both Oaks (%d / 2)." if island(s) == "frost_hollow" else "1 · Bring water beside both thirsty Oaks (%d / 2).") % p.connected
 if p.groves < 2:
  if island(s) == "frost_hollow": return "2 · Grow two groves at 60–85 warmth (%d / 2)." % p.groves
  if island(s) == "ember_shore": return "2 · Balance 35–65 heat and 70 moisture (%d / 2 groves)." % p.groves
  return "2 · Advance seasons to grow two groves (%d / 2)." % p.groves
 if p.habitats < 2: return "3 · Plant two flower patches beside water AND a grove (%d / 2)." % p.habitats
 return "The habitats are alive. Complete your expedition!"
static func place(s: Dictionary, index: int, kind: String) -> bool:
 if s.completed or index < 0 or index >= 9 or index in trees(s) or (island(s) == "ember_shore" and index == 2) or kind not in ["water","meadow","flowers","vent"]: return false
 if kind in ["water","vent"] and s.plots[index] != kind and s.plots.count(kind)-(1 if island(s) == "ember_shore" and kind == "vent" else 0) >= budget(s,kind): return false
 s.plots[index] = kind
 return true
static func advance(s: Dictionary) -> bool:
 if s.completed: return false
 for tree in trees(s):
  var sources := count_near(s,tree,"water")
  if island(s) == "frost_hollow": s.heat[tree] = clampi(s.heat[tree]+count_near(s,tree,"vent")*15-sources*10,0,100)
  else:
   s.moisture[tree] = clampi(s.moisture[tree]+(sources*15 if sources > 0 else -10),0,100)
   if island(s) == "ember_shore": s.heat[tree] = clampi(s.heat[tree]+5-sources*20,0,100)
 s.seasons = mini(10000,int(s.seasons)+1)
 return true
static func validate(value: Variant, store) -> bool:
 if not value is Dictionary or value.size() > 3: return false
 for id in value:
  if id not in ISLANDS or not value[id] is Dictionary: return false
  var s: Dictionary = value[id]
  var thermal: bool = id != ID
  if s.size() != (6 if thermal else 4) or not s.get("plots") is Array or s.plots.size() != 9 or not s.get("moisture") is Array or s.moisture.size() != 9: return false
  if thermal and (s.get("island") != id or not s.get("heat") is Array or s.heat.size() != 9): return false
  if not store.integer(s.get("seasons"),0,10000) or not s.get("completed") is bool: return false
  for index in range(9):
   if not s.plots[index] is String or s.plots[index] not in ["oak","meadow","water","flowers","vent"]: return false
   if (index in trees(s)) != (s.plots[index] == "oak"): return false
   if not store.integer(s.moisture[index],0,100): return false
   if index not in trees(s) and s.moisture[index] != 0: return false
   if thermal and (not store.integer(s.heat[index],0,100) or (index not in trees(s) and s.heat[index] != 0)): return false
  if s.plots.count("water") > budget(s,"water"): return false
  if id == "ember_shore":
   if s.plots[2] != "vent" or s.plots.count("vent") != 1: return false
  elif s.plots.count("vent") > budget(s,"vent"): return false
  if s.completed and not progress(s).ready: return false
 return true
