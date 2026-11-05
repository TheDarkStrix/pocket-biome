extends RefCounted
# Earned tools are reusable, bounded layout choices; no energy, ads or timers to purchase.
const MODES = ["channel","shade","warmth"]
const REQUIRED = {"channel":"shaded_pond","shade":"pollinator_patch","warmth":"thermal_refuge"}
const NAMES = {"channel":"Water channel","shade":"Shade canopy","warmth":"Warmth lantern"}
const EFFECTS = {"channel":{"moisture":12},"shade":{"heat":-12},"warmth":{"heat":12}}
const HELP = {"channel":"Adds 12 moisture every four active seconds while Water is within two edge-sharing steps through natural land.","shade":"Removes 12 heat every four active seconds. Use it to shelter a hot habitat; colder is not always better.","warmth":"Adds 12 heat every four active seconds. Move or remove it when a habitat needs cooler conditions."}
static func unlocked(m, mode: String) -> bool:
 return mode in MODES and m.state.get("habitat_projects",[]).has(REQUIRED[mode])
static func capacity(m, mode: String = "") -> int: return preload("res://scripts/ExpeditionRewards.gd").slots(m.state,mode)
static func natural(m, at: String) -> bool:
 return m.state.tiles.has(at) and m.config.tiles[m.state.tiles[m.origin(at)].type].category == "natural"
static func water_source(m, at: String) -> String:
 if not natural(m,at): return ""
 var reached := [m.origin(at)]
 var frontier := reached.duplicate()
 var reach: int = preload("res://scripts/ExpeditionRewards.gd").water_reach(m)
 for distance in range(reach+1):
  var next := []
  for key in frontier:
   if m.state.tiles[key].type == "water": return key
   if distance == reach: continue
   for other in m.neighbors(key):
    if natural(m,other) and not reached.has(other): reached.append(other); next.append(other)
  frontier = next
 return ""
static func targets(m, mode: String) -> Array: return m.state.get("restoration_care",{}).get(mode,[])
static func can_assign(m, mode: String, at: String) -> bool:
 at = m.origin(at)
 if not unlocked(m,mode) or at == "" or not natural(m,at) or not m.state.pending.is_empty(): return false
 if m.state.event.targets.has(at) or not m.state.tiles[at].get("boosts",[]).is_empty(): return false
 return mode != "channel" or water_source(m,at) != ""
static func assign(m, mode: String, at: String, slot: int = 0) -> bool:
 at = m.origin(at)
 if not can_assign(m,mode,at) or slot < 0 or slot >= capacity(m,mode): return false
 var chosen: Array = targets(m,mode).duplicate()
 if chosen.has(at): return false
 if slot > chosen.size(): return false
 if slot == chosen.size(): chosen.append(at)
 else: chosen[slot] = at
 if not m.state.has("restoration_care"):
  m.state.restoration_care = {"channel":[],"shade":[],"warmth":[],"next_at":m.state.time+4}
 m.state.restoration_care[mode] = chosen
 m.message = NAMES[mode]+" placed. "+description(m,mode)
 return true
static func remove(m, mode: String, at: String) -> bool:
 if mode not in MODES or not targets(m,mode).has(at): return false
 m.state.restoration_care[mode].erase(at)
 m.message = NAMES[mode]+" removed. Future effects stop; existing conditions change through the island’s ordinary influences."
 return true
static func apply(m) -> void:
 if not m.state.has("restoration_care") or m.state.time < m.state.restoration_care.next_at: return
 m.state.restoration_care.next_at = m.next_cycle(m.state.restoration_care.next_at,4,m.state.time)
 if m.state.get("ecology_rules","classic") == "balanced": return
 for mode in MODES:
  if not unlocked(m,mode): continue
  var applied := []
  for cell in targets(m,mode):
   var at: String = m.origin(cell)
   if at == "" or applied.has(at) or not natural(m,at): continue
   if mode == "channel" and water_source(m,at) == "": continue
   applied.append(at)
   for attribute in EFFECTS[mode]: m.state.tiles[at].dna[attribute] = clampi(m.state.tiles[at].dna[attribute]+EFFECTS[mode][attribute],0,100)
static func relocate(m, source: String, destination: String) -> void:
 if not m.state.has("restoration_care"): return
 for mode in MODES:
  var list: Array = targets(m,mode)
  if list.has(source):
   if list.has(destination): list.erase(source)
   else: list[list.find(source)] = destination
static func validate(store, s: Dictionary) -> bool:
 var care = s.get("restoration_care")
 if not care is Dictionary or care.size() != 4 or not store.number(care.get("next_at"),0,s.time+4): return false
 for mode in MODES:
  var limit: int = preload("res://scripts/ExpeditionRewards.gd").slots(s,mode)
  if not care.get(mode) is Array or care[mode].size() > limit: return false
  if not care[mode].is_empty() and not s.get("habitat_projects",[]).has(REQUIRED[mode]): return false
  var seen := []
  for at in care[mode]:
   if not store.coordinate(at) or not s.tiles.has(at) or seen.has(at): return false
   seen.append(at)
 return true

static func description(m, mode: String) -> String:
 if m.state.get("ecology_rules","classic") == "balanced":
  return {"channel":"Raises the local moisture balance by 36 while connected to Water within %d natural-land steps." % preload("res://scripts/ExpeditionRewards.gd").water_reach(m),"shade":"Lowers the local heat balance by 36. Conditions approach it over active time.","warmth":"Raises the local heat balance by 36. Conditions approach it over active time."}.get(mode,"")
 return HELP[mode].replace("two edge-sharing steps", "%d edge-sharing steps" % preload("res://scripts/ExpeditionRewards.gd").water_reach(m))

static func fuse_cells(m, cells: Array, anchor: String) -> void:
 if not m.state.has("restoration_care"): return
 for mode in MODES:
  var merged := []
  for cell in targets(m,mode):
   var at: String = anchor if cells.has(cell) else cell
   if not merged.has(at): merged.append(at)
  m.state.restoration_care[mode] = merged
