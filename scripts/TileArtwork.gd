extends RefCounted
# Reviewed candidate atlas regions; source retained unchanged. Not final art approval.
const DEPLETED = preload("res://assets/nodes/harvest_states.png")
const DEPLETED_CELLS = {"oak":Vector2i(0,0),"forest":Vector2i(0,0),"stone":Vector2i(1,0),"fiber":Vector2i(2,0),"clay":Vector2i(0,1),"iron":Vector2i(1,1)}
const BIOMES_A = preload("res://assets/biomes/biomes_a.png")
const BIOMES_B = preload("res://assets/biomes/biomes_b.png")
const EXTRA_A = {"meadow":Vector2i(0,0),"mossrock":Vector2i(1,0),"reedwater":Vector2i(2,0),"sunstone":Vector2i(0,1),"mistforest":Vector2i(1,1),"crystalforest":Vector2i(2,1),"oasis":Vector2i(0,2),"ironwood":Vector2i(1,2),"moonflower":Vector2i(2,2)}
const EXTRA_B = {"obsidian":Vector2i(0,0),"celestial":Vector2i(1,0),"lagoon":Vector2i(2,0),"quarry":Vector2i(0,1),"verdant":Vector2i(1,1),"dirt":Vector2i(2,1),"shrine":Vector2i(0,2),"lantern":Vector2i(1,2),"cloud":Vector2i(2,2)}
const STRUCTURES = preload("res://assets/structures/structures.png")
const STRUCTURE_CELLS = {"workbench":Vector2i(0,0),"furnace":Vector2i(1,0),"windmill":Vector2i(2,0),"golem":Vector2i(0,1),"totem":Vector2i(1,1),"compost":Vector2i(2,1),"clay":Vector2i(0,2),"iron":Vector2i(1,2),"cloud":Vector2i(2,2)}
static var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/game.json"))
const SOURCE = preload("res://assets/terrain/biome_candidates.png")
const EVOLVED = preload("res://assets/biomes/evolved_candidates.png")
const EVOLUTIONS = {
 "rainforest":Vector2i(0,0), "ember":Vector2i(1,0), "lake":Vector2i(2,0),
 "steam":Vector2i(0,1), "frozen":Vector2i(1,1), "grove":Vector2i(2,1)
}
const REGIONS = {
 "oak": [Rect2(0,0,418,445),Vector2(209,320)],
 "stone": [Rect2(418,0,418,445),Vector2(209,320)],
 "fiber": [Rect2(836,0,418,445),Vector2(209,320)],
 "grass": [Rect2(0,445,418,367),Vector2(209,235)],
 "forest": [Rect2(418,445,418,367),Vector2(209,235)],
 "water": [Rect2(836,445,418,367),Vector2(209,235)],
 "vent": [Rect2(0,812,418,400),Vector2(209,241)],
 "crystal": [Rect2(418,812,418,400),Vector2(209,241)],
 "glacier": [Rect2(836,812,418,400),Vector2(209,241)]
}
static var images := {}
static func appearance(type: String, evolution: String, depleted: bool = false) -> Dictionary:
 if depleted and evolution == "" and DEPLETED_CELLS.has(type):
  var cell: Vector2i = DEPLETED_CELLS[type]
  var top := 0 if cell.y == 0 else 448
  return {"texture":DEPLETED,"region":Rect2(cell.x*418,top,418,448 if cell.y == 0 else 397),"pivot":Vector2(209,285 if cell.y == 0 else 247),"normalization":1.0,"tint":Color.WHITE}
 var art := evolution
 var tint := Color.WHITE
 for recipe in catalog.recipes:
  if recipe.id == evolution:
   art = recipe.art
   if recipe.has("tint"): tint *= Color(recipe.tint)
 for fusion in catalog.fusions:
  if fusion.id == evolution: art = fusion.art
 if art == "" and EXTRA_B.has(type): art = type
 if EXTRA_A.has(art) or EXTRA_B.has(art):
  var first: bool = EXTRA_A.has(art)
  var cell: Vector2i = EXTRA_A[art] if first else EXTRA_B[art]
  var tops := [0,418,828] if first else [0,458,816]
  var heights := [418,410,426] if first else [458,358,438]
  var pivots := [265,267,247] if first else [305,202,244]
  return {"texture":BIOMES_A if first else BIOMES_B,"region":Rect2(cell.x*418,tops[cell.y],418,heights[cell.y]),"pivot":Vector2(209,pivots[cell.y]),"normalization":1.0,"tint":tint}
 if art.begins_with("base_"): type = art.trim_prefix("base_"); art = ""
 if EVOLUTIONS.has(art):
  var cell: Vector2i = EVOLUTIONS[art]
  return {"texture":EVOLVED,"region":Rect2(cell.x*418,cell.y*627,418,627),"pivot":Vector2(209,450 if cell.y == 0 else 393),"normalization":418.0/334.0,"tint":tint}
 if STRUCTURE_CELLS.has(type):
  var cell: Vector2i = STRUCTURE_CELLS[type]
  var row_top := [0,445,835]
  var row_height := [445,390,419]
  var ground_y := [320,270,204]
  return {"texture":STRUCTURES,"region":Rect2(cell.x*418,row_top[cell.y],418,row_height[cell.y]),"pivot":Vector2(209,ground_y[cell.y]),"normalization":1.0,"tint":tint}
 if not REGIONS.has(type): return {}
 return {"texture":SOURCE,"region":REGIONS[type][0],"pivot":REGIONS[type][1],"normalization":1.0,"tint":tint}
static func draw_tile(canvas: CanvasItem, type: String, position: Vector2, scale: float, tint: Color, evolution: String = "", depleted: bool = false) -> void:
 var spec := appearance(type,evolution,depleted)
 if spec.is_empty(): return
 var normalized: float = scale*spec.normalization
 canvas.draw_texture_rect_region(spec.texture,Rect2(position-spec.pivot*normalized,spec.region.size*normalized),spec.region,tint*spec.tint)
static func hit(type: String, evolution: String, relative_position: Vector2, scale: float, depleted: bool = false, joined: bool = false) -> bool:
 if joined and relative_position.y+0.46*absf(relative_position.x) > 26.0*scale/(132.0/418.0): return false
 var spec := appearance(type,evolution,depleted)
 if spec.is_empty() or scale <= 0: return false
 var local: Vector2 = relative_position/(scale*spec.normalization)+spec.pivot
 if not Rect2(Vector2.ZERO,spec.region.size).has_point(local): return false
 var texture: Texture2D = spec.texture
 var id := texture.get_instance_id()
 if not images.has(id):
  var pixels := texture.get_image()
  if pixels == null: return false
  if pixels.is_compressed(): pixels.decompress()
  images[id] = pixels
 var point: Vector2i = Vector2i(floori(local.x),floori(local.y))+Vector2i(spec.region.position)
 var pixels: Image = images[id]
 # Floating-point edge addition may round a subpixel sample onto the atlas boundary.
 if point.x < 0 or point.y < 0 or point.x >= pixels.get_width() or point.y >= pixels.get_height(): return false
 return pixels.get_pixel(int(point.x),int(point.y)).a > 0.2

static func joined_mesh(spec: Dictionary, scale: float, cut: float = 0.0) -> Dictionary:
 # Clip the baked soil skirts at the shared island surface. Tall props/foliage
 # retain their silhouettes; the foundation owns all extrusion below this plane.
 var normalized: float = scale*spec.normalization
 var left: float = -spec.pivot.x*normalized
 var right: float = (spec.region.size.x-spec.pivot.x)*normalized
 var top: float = (cut-spec.pivot.y)*normalized
 var bottom: float = (spec.region.size.y-spec.pivot.y)*normalized
 var points := PackedVector2Array([Vector2(left,top),Vector2(right,top),Vector2(right,bottom),Vector2(left,bottom)])
 var edge: float = 26.0*scale/(132.0/418.0)
 for normal in [Vector2(0.46,1),Vector2(-0.46,1)]:
  var clipped := PackedVector2Array()
  for index in range(points.size()):
   var start: Vector2 = points[index]
   var end: Vector2 = points[(index+1)%points.size()]
   var a: float = start.dot(normal)-edge
   var b: float = end.dot(normal)-edge
   if a <= 0: clipped.append(start)
   if (a < 0 and b > 0) or (a > 0 and b < 0): clipped.append(start.lerp(end,a/(a-b)))
  points = clipped
 var uvs := PackedVector2Array()
 for point in points:
  uvs.append((spec.region.position+spec.pivot+point/normalized)/Vector2(spec.texture.get_size()))
 return {"points":points,"uvs":uvs}

static func draw_joined(canvas: CanvasItem, type: String, position: Vector2, scale: float, tint: Color, evolution: String = "", depleted: bool = false, cut: float = 0.0) -> void:
 var spec := appearance(type,evolution,depleted)
 if spec.is_empty() or scale <= 0: return
 var mesh := joined_mesh(spec,scale,cut)
 var points: PackedVector2Array = mesh.points
 for index in range(points.size()): points[index] += position
 if points.size() >= 3: canvas.draw_polygon(points,PackedColorArray([tint*spec.tint]),mesh.uvs,spec.texture)
