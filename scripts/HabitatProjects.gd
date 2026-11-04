extends RefCounted
# Local, read-only layout checks; rewards are explicit, once-only claims.
const IDS = ["shaded_pond","pollinator_patch","living_workshop"]
const NAMES = {"shaded_pond":"Shaded Pond","pollinator_patch":"Pollinator Patch","living_workshop":"Living Workshop"}
const REWARDS = {"shaded_pond":40,"pollinator_patch":60,"living_workshop":80}
const RULES = {"shaded_pond":"Water beside an Oak or Forest with at least 60 moisture and no more than 65 heat.","pollinator_patch":"Fiber beside both Water and a healthy Oak or Forest. The tree needs 60 moisture and no more than 65 heat.","living_workshop":"A Workbench beside an enabled Windmill and a leafy Oak or Forest with at least 60 fertility and no more than 65 heat."}
static func tree(tile: Dictionary) -> bool: return tile.type in ["oak","forest"]
static func healthy(tile: Dictionary) -> bool: return tree(tile) and tile.dna.moisture >= 60 and tile.dna.heat <= 65
static func inspect(model, id: String) -> Dictionary:
 var result := {"ready":false,"anchor":"","cells":[],"matched":0,"total":2}
 if id not in IDS: return result
 var keys: Array = model.state.tiles.keys(); keys.sort()
 for key in keys:
  var tile: Dictionary = model.state.tiles[key]
  if tile.has("owner"): continue
  var kind: String = {"shaded_pond":"water","pollinator_patch":"fiber","living_workshop":"workbench"}[id]
  if tile.type != kind: continue
  var water := ""; var plant := ""; var mill := ""
  for other in model.neighbors(key):
   var adjacent: Dictionary = model.state.tiles[other]
   if adjacent.type == "water": water = other
   if healthy(adjacent) if id != "living_workshop" else (tree(adjacent) and adjacent.dna.fertility >= 60 and adjacent.dna.heat <= 65): plant = other
   if adjacent.type == "windmill" and adjacent.get("enabled",true): mill = other
  var cells: Array = [key]
  if plant != "": cells.append(plant)
  var score := 1 if plant != "" else 0
  if id == "shaded_pond": score += 1
  elif id == "pollinator_patch" and water != "": score += 1; cells.append(water)
  elif id == "living_workshop" and mill != "": score += 1; cells.append(mill)
  if result.anchor == "" or score > result.matched:
   result = {"ready":score == 2,"anchor":key,"cells":cells,"matched":score,"total":2}
 return result
static func claim(model, id: String) -> bool:
 if id not in IDS or model.state.discoveries.is_empty() or model.state.get("habitat_projects",[]).has(id) or not inspect(model,id).ready: return false
 if model.state.coins+REWARDS[id] > 1000000000: return false
 if not model.state.has("habitat_projects"): model.state.habitat_projects = []
 model.state.habitat_projects.append(id)
 model.state.coins += REWARDS[id]
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
  if current.ready: result.append({"id":id,"key":current.anchor})
 return result
static func draw_visitor(canvas: CanvasItem, id: String, at: Vector2, scale: float, clock: float, still: bool) -> void:
 var time := 0.0 if still else clock
 if id == "shaded_pond":
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
