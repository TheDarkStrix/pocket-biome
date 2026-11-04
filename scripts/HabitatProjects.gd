extends RefCounted
# Layout achievements are persistent; suitability and visitor preferences remain live.
const IDS = ["shaded_pond","pollinator_patch","living_workshop","thermal_refuge","sanctuary_network"]
const NAMES = {"shaded_pond":"The Returning Spring","pollinator_patch":"Wings over the Garden","living_workshop":"The Sheltered Workshop","thermal_refuge":"A Refuge from the Weather","sanctuary_network":"The Living Sanctuary"}
const REWARDS = {"shaded_pond":40,"pollinator_patch":60,"living_workshop":80,"thermal_refuge":90,"sanctuary_network":120}
const UNLOCKS = {"shaded_pond":"Water channel · carry moisture up to two natural-land steps from Water.","pollinator_patch":"Shade canopy · shelter one natural plot from heat.","living_workshop":"Landscape movement · relocate unprotected natural tiles without losing their conditions.","thermal_refuge":"Warmth lantern · warm one natural plot without spending Pulse energy.","sanctuary_network":"Sanctuary tending · use two of each earned care tool instead of one."}
const RULES = {"shaded_pond":"Restore a spring with living trees: a compact water's edge or a broader woodland pond.","pollinator_patch":"Give butterflies a watered flower patch or a sheltered garden with two healthy trees.","living_workshop":"Shelter a working Workbench: keep an enabled Windmill and fertile woodland nearby.","thermal_refuge":"Create a cool woodland retreat with Glacier, or a mild rainy shelter beside a Rain Totem.","sanctuary_network":"Complete the four restorations, keep them suitable, and connect their anchors through natural land."}
const DESIGNS = {"shaded_pond":"Compact shore: Water touching one healthy tree. Woodland pond: Water within two natural-land steps of two healthy trees.","pollinator_patch":"Waterside flowers: Fiber or Wildflower Meadow touching Water and a healthy tree. Sheltered garden: the flower plot has 50 moisture, 70 fertility and two healthy tree neighbors.","living_workshop":"Compact workshop: Workbench touching an enabled Windmill and a tree with 60 fertility. Woodland workshop: an enabled Windmill within two steps and two fertile trees within two steps. Trees need at most 65 heat.","thermal_refuge":"Cool retreat: tree touching Glacier, at least 60 moisture and at most 35 heat. Rain shelter: tree touching an enabled Rain Totem, at least 80 moisture and 35–65 heat.","sanctuary_network":"Connect suitable spring, flower, workshop and climate-refuge anchors. Natural terrain and Workbenches carry the path; other machines block it. Compact clusters or longer green corridors both work."}
const ANIMALS = {"shaded_pond":"Frogs","pollinator_patch":"Butterflies","living_workshop":"Woodland birds","thermal_refuge":"Shelter birds","sanctuary_network":"Fireflies"}
static func tree(tile: Dictionary) -> bool: return tile.type in ["oak","forest"]
static func healthy(tile: Dictionary) -> bool: return tree(tile) and tile.dna.moisture >= 60 and tile.dna.heat <= 65
static func reach(model, start: String, distance: int = 36, endpoints: Array = []) -> Array:
 var visited := [start]; var frontier := [start]
 for depth in range(distance):
  var next := []
  for key in frontier:
   for other in model.neighbors(key):
    if visited.has(other): continue
    var t: Dictionary = model.state.tiles[other]
    if model.config.tiles[t.type].category == "natural" or endpoints.has(other): visited.append(other); next.append(other)
  frontier = next
  if frontier.is_empty(): break
 return visited
static func empty() -> Dictionary: return {"ready":false,"anchor":"","cells":[],"matched":0,"total":2,"design":"","quality":0}
static func inspect(model, id: String, allowed: Array = []) -> Dictionary:
 var result := empty()
 if id not in IDS: return result
 if id == "sanctuary_network": return network(model)
 var keys: Array = model.state.tiles.keys(); keys.sort()
 for key in keys:
  var tile: Dictionary = model.state.tiles[key]
  if tile.has("owner") or (not allowed.is_empty() and not allowed.has(key)): continue
  var kind: String = {"shaded_pond":"water","pollinator_patch":"fiber","living_workshop":"workbench","thermal_refuge":"tree"}[id]
  if kind == "tree":
   if not tree(tile): continue
  elif tile.type != kind and not (id == "pollinator_patch" and tile.type == "grass" and tile.evolution == "meadow"): continue
  var near: Array = model.neighbors(key)
  var broad := reach(model,key,2)
  var plants := []; var fertile := []; var mills := []; var water := []; var ice := []; var rain := []
  for other in broad:
   if other == key: continue
   var t: Dictionary = model.state.tiles[other]
   if healthy(t): plants.append(other)
   if tree(t) and t.dna.fertility >= 60 and t.dna.heat <= 65: fertile.append(other)
   if t.type == "windmill" and t.get("enabled",true): mills.append(other)
  # Machines are endpoints, not green corridors.
  for other in near:
   var t: Dictionary = model.state.tiles[other]
   if t.type == "water": water.append(other)
   if t.type == "glacier": ice.append(other)
   if t.type == "totem" and t.get("enabled",true): rain.append(other)
   if t.type == "windmill" and t.get("enabled",true) and not mills.has(other): mills.append(other)
   for outer in model.neighbors(other):
    if model.config.tiles[t.type].category == "natural" and model.state.tiles[outer].type == "windmill" and model.state.tiles[outer].get("enabled",true) and not mills.has(outer): mills.append(outer)
  var local_plants := plants.filter(func(at): return near.has(at))
  var local_fertile := fertile.filter(func(at): return near.has(at))
  var local_mills := mills.filter(func(at): return near.has(at))
  var score := 0; var design := ""; var quality := 1; var cells := [key]
  if id == "shaded_pond":
   score = 1+mini(1,local_plants.size())
   if not local_plants.is_empty(): design = "Compact shore"; cells.append(local_plants[0])
   if plants.size() >= 2: score = 2; quality = 2; design = "Woodland pond"; cells.append_array(plants)
  elif id == "pollinator_patch":
   score = mini(1,water.size())+mini(1,local_plants.size())
   if score == 2: design = "Waterside flowers"; cells.append_array(water); cells.append_array(local_plants)
   if local_plants.size() >= 2 and tile.dna.moisture >= 50 and tile.dna.fertility >= 70:
    score = 2; quality = 2; design = "Sheltered garden"; cells.append_array(local_plants)
  elif id == "living_workshop":
   score = mini(1,local_mills.size())+mini(1,local_fertile.size())
   if score == 2: design = "Compact workshop"; cells.append_array(local_mills); cells.append_array(local_fertile)
   if not mills.is_empty() and fertile.size() >= 2:
    score = 2; quality = 2; design = "Woodland workshop"; cells.append_array(mills); cells.append_array(fertile)
  else:
   score = 1 if not ice.is_empty() or not rain.is_empty() else 0
   if not ice.is_empty() and tile.dna.moisture >= 60 and tile.dna.heat <= 35:
    score = 2; design = "Cool retreat"; cells.append_array(ice)
   elif not rain.is_empty() and tile.dna.moisture >= 80 and tile.dna.heat >= 35 and tile.dna.heat <= 65:
    score = 2; quality = 2; design = "Rain shelter"; cells.append_array(rain)
  if result.anchor == "" or score > result.matched or (score == result.matched and quality > result.quality):
   result = {"ready":score == 2,"anchor":key,"cells":cells,"matched":score,"total":2,"design":design,"quality":quality if score == 2 else 0}
 return result
static func network(model) -> Dictionary:
 var result := empty(); result.total = 4
 # Search every component so a disconnected high-quality habitat cannot hide a valid connected one.
 var checked := []; var endpoints := []
 for at in model.state.tiles:
  if model.state.tiles[at].get("type","") == "workbench": endpoints.append(at)
 for start in model.state.tiles:
  if checked.has(start) or model.state.tiles[start].has("owner") or (model.config.tiles[model.state.tiles[start].type].category != "natural" and not endpoints.has(start)): continue
  var connected := reach(model,start,36,endpoints)
  checked.append_array(connected)
  var candidate := empty(); candidate.total = 4; candidate.anchor = start
  for id in IDS.slice(0,4):
   var layout := inspect(model,id,connected)
   if model.state.get("habitat_projects",[]).has(id) and layout.ready:
    candidate.matched += 1; candidate.cells.append_array(layout.cells)
  candidate.ready = candidate.matched == 4
  candidate.design = "Connected sanctuary" if candidate.ready else "A green corridor is missing"
  candidate.quality = 2 if candidate.ready else 0
  if candidate.matched > result.matched: result = candidate
  if result.ready: break
 return result
static func wildlife(model, id: String) -> Dictionary:
 var layout := inspect(model,id)
 var arrived: bool = model.state.get("habitat_projects",[]).has(id) and layout.ready
 return {"species":ANIMALS.get(id,"Wildlife"),"arrived":arrived,"design":layout.design,"count":layout.quality if arrived else 0,"preference":DESIGNS.get(id,"")}
static func claim(model, id: String) -> bool:
 if id not in IDS or model.state.discoveries.is_empty() or model.state.get("habitat_projects",[]).has(id) or not inspect(model,id).ready: return false
 if model.state.coins+REWARDS[id] > 1000000000: return false
 if not model.state.has("habitat_projects"): model.state.habitat_projects = []
 model.state.habitat_projects.append(id)
 model.state.coins += REWARDS[id]
 preload("res://scripts/LearningJourney.gd").finish_if_ready(model)
 model.campaign.evaluate(model)
 return true
static func validate(value: Variant) -> bool:
 if not value is Array or value.size() > IDS.size(): return false
 var seen := []
 for id in value:
  if not id is String or id not in IDS or seen.has(id): return false
  seen.append(id)
 return true
static func visitors(model) -> Array:
 var result := []
 for id in model.state.get("habitat_projects",[]):
  var current := inspect(model,id)
  if current.ready: result.append({"id":id,"key":current.anchor,"count":current.quality})
 return result
static func draw_visitor(canvas: CanvasItem, id: String, at: Vector2, scale: float, clock: float, still: bool) -> void:
 var time := 0.0 if still else clock
 if id == "sanctuary_network":
  for i in range(5):
   var p := at+Vector2(sin(time*0.7+i*1.3)*30,-20+cos(time*0.8+i)*15)*scale
   canvas.draw_circle(p,(1.5+absf(sin(time+i)))*scale,Color("e8e49d"))
 elif id == "shaded_pond":
  var p := at+Vector2(14,-9-maxf(0,sin(time*1.7))*3)*scale
  canvas.draw_circle(p,5*scale,Color("6d9f43"))
  for side in [-1,1]:
   canvas.draw_circle(p+Vector2(side*3,-3)*scale,2.5*scale,Color("b7d97b"))
   canvas.draw_circle(p+Vector2(side*3,-3)*scale,1*scale,Color("233a26"))
 elif id == "pollinator_patch":
  for i in range(2):
   var p := at+Vector2(sin(time*0.8+i*2)*18,-24+cos(time+i*2)*8)*scale
   var wing := (3+absf(sin(time*6+i))*3)*scale
   for side in [-1,1]:
    canvas.draw_circle(p+Vector2(side*wing*0.6,0),wing,Color("f1b963") if i == 0 else Color("9acde3"))
   canvas.draw_line(p-Vector2(0,3)*scale,p+Vector2(0,3)*scale,Color("554a39"),maxf(1,scale),true)
 else:
  var p := at+Vector2(sin(time*0.6)*24,-44+cos(time)*4)*scale
  var lift := sin(time*3)*4 if not still else 0.0
  canvas.draw_polyline(PackedVector2Array([p+Vector2(-10,-lift)*scale,p,p+Vector2(10,-lift)*scale]),Color("f4ebd2"),2*scale,true)
