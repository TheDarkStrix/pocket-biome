extends RefCounted
# Pure cosmetic geometry. Every occupied cell counts, including fusion-owned cells.
const HALF_WIDTH = 66.0
const HALF_HEIGHT = 33.0
static func coord(key: String) -> Vector2i:
 var parts := key.split(",")
 return Vector2i(int(parts[0]),int(parts[1]))
static func turn(point: Vector2i, count: int) -> Vector2i:
 for step in range(posmod(count,4)): point = Vector2i(-point.y,point.x)
 return point
static func project(point: Vector2) -> Vector2:
 return Vector2((point.x-point.y)*HALF_WIDTH,(point.x+point.y)*HALF_HEIGHT)
static func depth(corner: Vector2i) -> float:
 # World-space corner key makes adjacent wall segments meet without cracks.
 return 73.0+float(posmod(corner.x*73856093 ^ corner.y*19349663,29))
static func signature(tiles: Dictionary, rotation: int) -> String:
 var keys := tiles.keys(); keys.sort()
 var entries := PackedStringArray([str(posmod(rotation,4))])
 for key in keys:
  var origin: String = tiles[key].get("owner",key)
  var tile: Dictionary = tiles.get(origin,{})
  entries.append("%s:%s:%s:%s" % [key,origin,tile.get("type",""),tile.get("evolution","")])
 return "|".join(entries)
static func build(tiles: Dictionary, rotation: int) -> Dictionary:
 var cells := {}; var center := Vector2.ZERO
 for key in tiles:
  var at: Vector2i = turn(coord(key),rotation)
  cells[at] = key; center += Vector2(at)
 if cells.is_empty(): return {"caps":[],"walls":[],"bounds":Rect2(),"waterfalls":0}
 center /= cells.size()
 var cap_list := []; var walls := []
 var bounds := Rect2(project(center),Vector2.ZERO)
 var positions := cells.keys()
 positions.sort_custom(func(a: Vector2i,b: Vector2i): return a.x < b.x if a.x+a.y == b.x+b.y else a.x+a.y < b.x+b.y)
 for at in positions:
  var key: String = cells[at]
  var origin: String = tiles[key].get("owner",key)
  var tile: Dictionary = tiles.get(origin,{})
  var p: Vector2 = project(Vector2(at))
  var cap := PackedVector2Array([p+Vector2(0,-33),p+Vector2(66,0),p+Vector2(0,33),p+Vector2(-66,0)])
  cap_list.append(cap)
  for point in cap: bounds = bounds.expand(point)
  for side in range(2):
   var neighbor: Vector2i = at+(Vector2i.RIGHT if side == 0 else Vector2i.DOWN)
   if cells.has(neighbor): continue
   var a: Vector2 = Vector2(at)+Vector2(0.5,-0.5) if side == 0 else Vector2(at)+Vector2(0.5,0.5)
   var b: Vector2 = Vector2(at)+Vector2(0.5,0.5) if side == 0 else Vector2(at)+Vector2(-0.5,0.5)
   var top_a := project(a); var top_b := project(b)
   var center_x: float = project(center).x
   var bottom_a := top_a+Vector2(clampf((center_x-top_a.x)*0.26,-24,24),depth(turn(Vector2i(a*2),-rotation)))
   var bottom_b := top_b+Vector2(clampf((center_x-top_b.x)*0.26,-24,24),depth(turn(Vector2i(b*2),-rotation)))
   var points := PackedVector2Array([top_a,top_b,bottom_b,bottom_a])
   var middle := (top_a+top_b)/2
   var seed: int = posmod(coord(key).x*101+coord(key).y*71+side*23,997)
   var frozen: bool = tile.get("evolution","") == "frozen"
   var root: bool = tile.get("type","") in ["oak","forest","grass","fiber","water","dirt"] and seed%3 != 1 and not frozen
   var notch_b := bottom_a.lerp(bottom_b,0.70)+Vector2(0,7+seed%13)
   var notch_a := bottom_a.lerp(bottom_b,0.30)+Vector2(0,-4-seed%9)
   var mesh := PackedVector2Array([top_a,top_b,bottom_b,notch_b,notch_a,bottom_a])
   var wall := {"mesh":mesh,"key":key,"origin":origin,"side":side,"points":points,"top":middle,"seed":seed,"root":root,"fall":false}
   walls.append(wall)
   for point in mesh: bounds = bounds.expand(point)
   bounds = bounds.expand(middle+Vector2(-35,116)); bounds = bounds.expand(middle+Vector2(35,116))
   if root:
    bounds = bounds.expand(middle+Vector2(-21,8)); bounds = bounds.expand(middle+Vector2(21,137))
 # Painted pond artwork has no registered pond-to-lip outlet. An exposed
 # water tile alone must never spawn a disconnected decorative waterfall.
 return {"caps":cap_list,"walls":walls,"bounds":bounds.grow(12),"waterfalls":0}
