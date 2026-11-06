extends RefCounted
# Authored home chapter: limited flow -> grove -> migration -> a flowering seedbed.
const BRANCHES = ["wetland","woodland"]
const NAMES = {"wetland":"Clover's wetland","woodland":"Juniper's woodland"}
const STAGES = ["grove","wings","bloom"]
const ROLES = ["grove","garden"]
const LAND = ["grass","dirt","fiber","oak","forest","water"]
static func unlocked(m) -> bool: return m.state.get("habitat_projects",[]).has("shaded_pond")
static func record(m) -> Dictionary: return m.state.get("living_corridors",{})
static func earned(m) -> bool: return record(m).get("ledger",[]).has("bloom")
static func fresh(now: float) -> Dictionary:
 return {"branch":"","source":"","routes":{},"seedbed":"","growth":{"grove":0,"garden":0,"bloom":0},"stage":0,"season":0,"ledger":[],"next_at":now+4}
static func ensure(m) -> void:
 if not m.state.has("living_corridors"): m.state["living_corridors"] = fresh(m.state.time)
static func tile(m, at: String) -> Dictionary:
 var origin: String = m.origin(at)
 return {} if origin == "" else m.state.tiles[origin]
static func passable(m, at: String) -> bool: return tile(m,at).get("type","") in LAND
static func adjacent(m, a: String, b: String) -> bool:
 var delta: Vector2i = m.coord(a)-m.coord(b)
 return absi(delta.x)+absi(delta.y) == 1
static func base_budget(m) -> int: return 4 if record(m).get("branch","") == "wetland" else 3
static func dry(m) -> bool: return not earned(m) and int(record(m).get("stage",0)) in [1,2]
static func budget(m) -> int: return base_budget(m)-(1 if dry(m) else 0)
static func choose_branch(m, branch: String) -> bool:
 if not unlocked(m) or branch not in BRANCHES: return false
 ensure(m)
 var s: Dictionary = record(m)
 if s.branch == branch: return false
 s.branch = branch; s.routes = {}; s.seedbed = ""; s.stage = 0
 s.growth = {"grove":0,"garden":0,"bloom":0}
 m.message = NAMES[branch]+" chosen. Earned chapter moments stay in your field notes."
 return true
static func set_source(m, at: String) -> bool:
 if not unlocked(m) or record(m).get("branch","") not in BRANCHES or tile(m,at).get("type","") != "water": return false
 var s: Dictionary = record(m)
 s.source = at; s.routes = {}; s.stage = 0; s.growth = {"grove":0,"garden":0,"bloom":0}
 return true
static func path_valid(m, path: Array) -> bool:
 if path.size() < 2 or path.size() > 12 or record(m).get("source","") == "" or path[0] != record(m).source or tile(m,path[0]).get("type","") != "water": return false
 var seen := []
 for index in range(path.size()):
  if not path[index] is String or not passable(m,path[index]) or seen.has(path[index]): return false
  if index > 0 and not adjacent(m,path[index-1],path[index]): return false
  seen.append(path[index])
 return true
static func role_valid(m, role: String, path: Array) -> bool:
 if role not in ROLES or not path_valid(m,path): return false
 var target: Dictionary = tile(m,path[-1])
 if role == "grove":
  var delta: Vector2i = m.coord(path[-1])-m.coord(path[0])
  return target.get("type","") in ["oak","forest"] and absi(delta.x)+absi(delta.y) >= 2
 return target.get("type","") in ["fiber","grass","dirt"]
static func set_route(m, role: String, path: Array) -> bool:
 if not unlocked(m) or not role_valid(m,role,path): return false
 var s: Dictionary = record(m)
 var old_water: int = int(s.routes.get(role,{}).get("water",0))
 s.routes[role] = {"path":path.duplicate(),"water":old_water}
 if role == "grove": s.stage = 0; s.growth = {"grove":0,"garden":0,"bloom":0}
 else: s.stage = mini(s.stage,1); s.growth.garden = 0; s.growth.bloom = 0
 return true
static func allocate(m, role: String, amount: int) -> bool:
 var s: Dictionary = record(m)
 if not s.get("routes",{}).has(role) or amount < 0 or amount > 3: return false
 var total := amount
 for other in s.routes:
  if other != role: total += int(s.routes[other].water)
 if total > base_budget(m): return false
 s.routes[role].water = amount
 return true
static func delivered(m) -> Dictionary:
 var result := {"grove":0,"garden":0}
 var remaining := budget(m)
 for role in ROLES:
  var route: Dictionary = record(m).get("routes",{}).get(role,{})
  if route.is_empty() or not role_valid(m,role,route.path): continue
  result[role] = mini(remaining,int(route.water)); remaining -= result[role]
 return result
static func end_of(m, role: String) -> String:
 var path: Array = record(m).get("routes",{}).get(role,{}).get("path",[])
 return "" if path.is_empty() else path[-1]
static func leafy(m, at: String) -> bool:
 var plant: Dictionary = tile(m,at)
 return plant.get("type","") in ["oak","forest"] and plant.dna.moisture >= 60 and plant.dna.heat <= 65
static func trees_near(m, at: String) -> int:
 var total := 0
 for other in m.neighbors(at):
  if leafy(m,other): total += 1
 return total
static func grove_demand(m) -> int:
 var at := end_of(m,"grove")
 return 1 if record(m).get("branch","") == "woodland" and at != "" and trees_near(m,at) >= 1 else 2
static func link(m, from: String, to: String, limit: int = 3) -> Array:
 if from == "" or to == "" or not passable(m,from) or not passable(m,to): return []
 var frontier := [[from]]; var seen := [from]
 for depth in range(limit+1):
  var next := []
  for path in frontier:
   if path[-1] == to: return path
   if path.size() > limit: continue
   for direction in m.DIRS:
    var other: String = m.key(m.coord(path[-1])+direction)
    if passable(m,other) and not seen.has(other):
     var branch: Array = path.duplicate(); branch.append(other); next.append(branch); seen.append(other)
  frontier = next
 return []
static func grove_options(m) -> Array:
 var result:=[]
 var source: String=record(m).get("source","")
 if tile(m,source).get("type","")!="water":return result
 var keys: Array=m.state.tiles.keys();keys.sort()
 for key in keys:
  if m.state.tiles[key].has("owner") or tile(m,key).get("type","") not in ["oak","forest"]:continue
  var path:=link(m,source,key,11)
  if role_valid(m,"grove",path):result.append({"target":key,"path":path})
 result.sort_custom(func(a,b):return a.path.size()<b.path.size() if a.path.size()!=b.path.size() else a.target<b.target)
 return result

static func garden_ready(m) -> bool:
 var at := end_of(m,"garden"); var grove := end_of(m,"grove")
 if at == "" or grove == "" or int(record(m).growth.grove) < 2: return false
 var route: Array = record(m).routes.get("garden",{}).get("path",[])
 var linked := false
 for cell in route:
  if m.origin(cell) == m.origin(grove): linked = true
 if not linked: return false
 var plant: Dictionary = tile(m,at)
 if plant.dna.moisture < 50 or plant.dna.fertility < 70 or plant.dna.heat > 65: return false
 if record(m).branch == "woodland": return trees_near(m,at) >= 2
 for other in m.neighbors(at):
  if tile(m,other).get("type","") == "water": return true
 return false
static func set_seedbed(m, at: String) -> bool:
 if not unlocked(m) or tile(m,at).get("type","") not in ["grass","dirt"] or tile(m,at).get("evolution","") != "" or tile(m,at).get("size",0) != 1: return false
 var garden := end_of(m,"garden")
 if garden == "" or link(m,garden,at).is_empty(): return false
 var s: Dictionary = record(m)
 s.seedbed = at; s.growth.bloom = 0; s.stage = mini(s.stage,2)
 return true
static func effects(m) -> Dictionary:
 var result := {}; var water := delivered(m)
 for role in ROLES:
  if water[role] <= 0: continue
  for cell in record(m).routes[role].path:
   var at: String = m.origin(cell)
   if not result.has(at): result[at] = {"moisture":0,"heat":0}
   result[at].moisture = mini(36,result[at].moisture+int(water[role])*12)
 for at in result:
  if dry(m): result[at].heat += 12
  if dry(m) and record(m).get("branch","") == "woodland" and trees_near(m,at) >= 1: result[at].heat -= 12
 return result
static func apply_classic(m) -> void:
 var s: Dictionary = record(m)
 if s.is_empty() or m.state.time < s.next_at: return
 s.next_at = m.next_cycle(s.next_at,4,m.state.time)
 if m.state.get("ecology_rules","classic") == "balanced": return
 for at in effects(m): m.state.tiles[at].dna.moisture = clampi(m.state.tiles[at].dna.moisture+6,0,100)
static func remember(m, id: String) -> void:
 var s: Dictionary = record(m)
 if s.ledger.has(id): return
 s.ledger.append(id); m.record_event("corridor_stage_completed",{"id":id,"type":s.branch})
static func advance(m) -> bool:
 var s: Dictionary = record(m)
 if not unlocked(m) or s.is_empty() or s.branch not in BRANCHES or s.source == "" or tile(m,s.source).get("type","") != "water" or not s.routes.has("grove"): return false
 s.season = mini(10000,int(s.season)+1)
 var water := delivered(m)
 var flow := effects(m)
 for at in flow:
  m.state.tiles[at].dna.moisture = clampi(m.state.tiles[at].dna.moisture+6,0,100)
 var grove := end_of(m,"grove"); var garden := end_of(m,"garden")
 if grove != "" and water.grove >= grove_demand(m) and leafy(m,grove): s.growth.grove = mini(2,int(s.growth.grove)+1)
 else: s.growth.grove = maxi(0,int(s.growth.grove)-1)
 if s.growth.grove >= 2:
  s.stage = maxi(s.stage,1); remember(m,"grove")
  if garden != "" and water.garden >= 1: tile(m,garden).dna.fertility = mini(100,tile(m,garden).dna.fertility+10)
 if water.garden >= 1 and garden_ready(m): s.growth.garden = mini(2,int(s.growth.garden)+1)
 else: s.growth.garden = maxi(0,int(s.growth.garden)-1)
 if s.growth.garden >= 2:
  s.stage = maxi(s.stage,2); remember(m,"wings")
  var seedbed: String = s.seedbed
  if seedbed != "" and tile(m,seedbed).get("type","") in ["grass","dirt"] and tile(m,seedbed).get("size",0) == 1 and tile(m,seedbed).get("evolution","") in ["","meadow"] and not link(m,garden,seedbed).is_empty():
   var soil: Dictionary = tile(m,seedbed)
   soil.dna.moisture = mini(100,soil.dna.moisture+15); soil.dna.fertility = mini(100,soil.dna.fertility+15)
   if soil.dna.moisture >= 50 and soil.dna.fertility >= 80 and soil.dna.heat <= 65: s.growth.bloom = mini(2,int(s.growth.bloom)+1)
 if s.growth.bloom >= 2:
  s.stage = 3; remember(m,"bloom")
 m.evaluate(); m.campaign.evaluate(m)
 m.message = ["Water is reaching the roots.","The grove holds. Plan Sola's route through its shelter.","Sola can carry growth toward your seedbed.","The Living River is restored. Your flowering route can keep waking new seedbeds."][int(s.stage)]
 if int(water.grove)+int(water.garden) == 0: m.message = "No Water reached the routes. Review the source and blocked plots."
 elif s.stage in [1,2] and s.growth.grove < 2: m.message = "The grove needs Water again. Its earned chapter moment is kept."
 return true
static func status(m) -> Dictionary:
 var s: Dictionary = record(m)
 if s.is_empty() or s.get("branch","") == "": return {"title":"Choose your river's future","body":"Clover's wetland has more spring flow; Juniper's woodland saves water with living shelter."}
 if s.source == "" or tile(m,s.source).get("type","") != "water": return {"title":"Choose a living spring","body":"Select Water on your island. A moved or replaced spring can be chosen again; earned moments stay yours."}
 if s.get("routes",{}).has("grove") and not role_valid(m,"grove",s.routes.grove.path): return {"title":"Repair the grove route","body":"A plot on this route changed. Trace a new path across Meadow, plants or Water; stone and machines block it."}
 if s.get("routes",{}).has("garden") and not role_valid(m,"garden",s.routes.garden.path): return {"title":"Repair the flower route","body":"A plot on this route changed. Trace a route through the grove to Fiber or soil so Sola can travel again."}
 if s.seedbed != "" and not earned(m) and (tile(m,s.seedbed).get("size",0) != 1 or tile(m,s.seedbed).get("type","") not in ["grass","dirt"] or tile(m,s.seedbed).get("evolution","") not in ["","meadow"]): return {"title":"Choose a new seedbed","body":"Your selected corner changed. Choose bare Meadow or Ploughed Soil near the garden; earned chapter moments remain."}
 var stage: int = s.stage
 if stage == 0: return {"title":"Carry Water to a remote grove","body":"Trace a route to an Oak or Forest at least two edges from the spring. Supply %d flow and keep it at 60 moisture / at most 65 heat for two observed seasons." % grove_demand(m)}
 if stage == 1: return {"title":"Welcome Sola through the grove","body":"Trace a second route through the mature grove to Fiber or soil. Give it one flow, 50 moisture and 70 fertility. "+("Keep Water beside the flowers." if s.branch == "wetland" else "Shelter the flowers with two healthy tree neighbors.")}
 if stage == 2: return {"title":"Wake a dormant corner","body":"Choose bare Meadow or Ploughed Soil within three green steps of the garden. Keep both routes working as Sola carries moisture and fertile growth there."}
 return {"title":"Living River chapter complete","body":"The Living Heart is earned. Try another seedbed or another approach; chapter rewards cannot repeat."}
static func validate(store, state: Dictionary) -> bool:
 if not state.has("living_corridors"): return true
 var s = state.living_corridors
 if not s is Dictionary or s.size() != 9: return false
 if s.get("branch") not in ["","wetland","woodland"] or not s.get("routes") is Dictionary or s.routes.size() > 2: return false
 for field in ["source","seedbed"]:
  if not s.get(field) is String or (s[field] != "" and (not store.coordinate(s[field]) or not state.tiles.has(s[field]))): return false
 if not store.integer(s.get("stage"),0,3) or not store.integer(s.get("season"),0,10000) or not store.number(s.get("next_at"),0,state.time+4): return false
 if not s.get("growth") is Dictionary or s.growth.size() != 3 or not s.get("ledger") is Array or s.ledger.size() > 3: return false
 for id in ["grove","garden","bloom"]:
  if not store.integer(s.growth.get(id),0,2): return false
 var seen := []
 for id in s.ledger:
  if id not in STAGES or seen.has(id): return false
  seen.append(id)
 var total := 0
 for role in s.routes:
  if role not in ROLES or not s.routes[role] is Dictionary: return false
  var route: Dictionary = s.routes[role]
  if route.size() != 2 or not route.get("path") is Array or route.path.size() < 2 or route.path.size() > 12 or not store.integer(route.get("water"),0,3): return false
  if s.source == "" or route.path[0] != s.source: return false
  var visited := []
  for index in range(route.path.size()):
   var cell = route.path[index]
   if not store.coordinate(cell) or not state.tiles.has(cell) or visited.has(cell): return false
   if index > 0:
    var a: PackedStringArray = cell.split(","); var b: PackedStringArray = route.path[index-1].split(",")
    if absi(int(a[0])-int(b[0]))+absi(int(a[1])-int(b[1])) != 1: return false
   visited.append(cell)
  total += int(route.water)
 if total > (4 if s.branch == "wetland" else 3): return false
 return true
