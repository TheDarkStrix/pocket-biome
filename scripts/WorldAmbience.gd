extends RefCounted
# Deterministic cosmetic motion. Ground, occupancy, production and saves stay fixed.
const Art = preload("res://scripts/TileArtwork.gd")
static func foliage_mesh(spec: Dictionary, scale: float, time: float, seed: int, reduced: bool = false) -> Dictionary:
 var cut: float = maxf(1,spec.pivot.y-80)
 var shift: float = 0.0 if reduced else sin(time*1.35+seed*1.71)*9*scale
 var left: float = -spec.pivot.x*scale
 var top: float = -spec.pivot.y*scale
 var edge: float = (cut-spec.pivot.y)*scale
 var width: float = spec.region.size.x*scale
 var texture_size: Vector2 = spec.texture.get_size()
 var source: Rect2 = spec.region
 var uvs := PackedVector2Array([
  (source.position+Vector2(0.5,0.5))/texture_size,
  (source.position+Vector2(source.size.x-0.5,0.5))/texture_size,
  (source.position+Vector2(source.size.x-0.5,cut))/texture_size,
  (source.position+Vector2(0.5,cut))/texture_size])
 return {"points":PackedVector2Array([Vector2(left+shift,top),Vector2(left+width+shift,top),Vector2(left+width,edge),Vector2(left,edge)]),"uvs":uvs,"base":Rect2(left,edge,width,(source.size.y-cut)*scale),"region":Rect2(source.position+Vector2(0,cut),Vector2(source.size.x,source.size.y-cut)),"shift":shift}

static func draw_tile(canvas: CanvasItem, type: String, position: Vector2, scale: float, tint: Color, evolution: String, depleted: bool, time: float, seed: int, reduced: bool, joined: bool = false) -> void:
 var stump: bool = depleted and evolution == "" and Art.DEPLETED_CELLS.has(type)
 var foliage: bool = type in ["oak","forest","fiber"] or evolution in ["grove","verdant","ironwood","moonflower"]
 if not foliage or stump or reduced:
  if joined: Art.draw_joined(canvas,type,position,scale,tint,evolution,depleted)
  else: Art.draw_tile(canvas,type,position,scale,tint,evolution,depleted)
  return
 var spec: Dictionary = Art.appearance(type,evolution,depleted)
 if spec.is_empty(): return
 var mesh := foliage_mesh(spec,scale*spec.normalization,time,seed)
 var points: PackedVector2Array = mesh.points
 for index in range(points.size()): points[index] += position
 canvas.draw_polygon(points,PackedColorArray([tint*spec.tint]),mesh.uvs,spec.texture)
 if joined: Art.draw_joined(canvas,type,position,scale,tint,evolution,depleted,mesh.region.position.y-spec.region.position.y)
 else:
  var base: Rect2 = mesh.base; base.position += position
  canvas.draw_texture_rect_region(spec.texture,base,mesh.region,tint*spec.tint)

static func activity(tile: Dictionary) -> String:
 if not tile.get("enabled",true): return ""
 if tile.type == "water" or tile.evolution in ["lake","reedwater","lagoon","steam"]: return "water"
 if tile.type in ["furnace","vent"]: return "smoke"
 if tile.type == "windmill": return "flour"
 if tile.type in ["golem","totem","shrine"]: return "glow"
 return ""

static func draw_effects(canvas: CanvasItem, tile: Dictionary, at: Vector2, scale: float, time: float, reduced: bool) -> void:
 if reduced: return
 var kind := activity(tile)
 var seed: float = float(tile.id)*0.31
 if kind == "water":
  for i in range(2):
   var phase := fposmod(time*0.38+seed+i*0.47,1.0)
   var center := at+Vector2(-14 if i == 0 else 18,-14 if i == 0 else -5)*scale
   var points := PackedVector2Array()
   for step in range(17):
    var angle := TAU*step/16.0
    points.append(center+Vector2(cos(angle),sin(angle)*0.42)*(3+phase*13)*scale)
   canvas.draw_polyline(points,Color(0.77,0.93,1,sin(phase*PI)*0.5),maxf(0.7,scale),true)
 elif kind == "smoke":
  for i in range(5):
   var phase := fposmod(time*0.3+seed+i*0.2,1.0)
   var origin := Vector2(-3,-73) if tile.type == "furnace" else Vector2(0,-30)
   var offset := Vector2(sin(phase*3+seed)*7+phase*13,-phase*40)
   canvas.draw_circle(at+(origin+offset)*scale,(2+phase*6)*scale,Color(0.72,0.75,0.79,(1-phase)*0.23))
  var flicker := 0.15+0.06*sin(time*7+seed)
  canvas.draw_circle(at+Vector2(-1,-22)*scale,7*scale,Color(1,0.61,0.25,flicker))
 elif kind == "flour":
  for i in range(4):
   var phase := fposmod(time*0.45+seed+i*0.25,1.0)
   canvas.draw_circle(at+Vector2(10+phase*18,-10-phase*14)*scale,(1+phase)*scale,Color(0.95,0.9,0.73,sin(phase*PI)*0.55))
 elif kind == "glow":
  for i in range(3):
   var phase: float = time*0.9+seed+i*TAU/3
   canvas.draw_circle(at+Vector2(cos(phase)*17,-30+sin(phase)*9)*scale,1.8*scale,Color(0.59,0.89,0.89,0.35+0.2*sin(phase)))
