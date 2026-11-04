extends RefCounted
# Deterministic cosmetic motion. Ground, occupancy, production and saves stay fixed.
const Art = preload("res://scripts/TileArtwork.gd")
static func foliage_mesh(spec: Dictionary, scale: float, time: float, seed: int, reduced: bool = false, impulse: float = 0.0) -> Dictionary:
 var cut: float = maxf(1,spec.pivot.y-80)
 var shift: float = 0.0 if reduced else clampf(sin(time*1.35+seed*1.71)*8+sin(time*2.1+seed)*2+impulse*9,-9,9)*scale
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

static func draw_tile(canvas: CanvasItem, type: String, position: Vector2, scale: float, tint: Color, evolution: String, depleted: bool, time: float, seed: int, reduced: bool, joined: bool = false, motor_time: float = 0.0, impulse: float = 0.0) -> void:
 if type == "windmill" and evolution == "":
  if joined: Art.draw_joined(canvas,type,position,scale,tint,evolution,depleted,0,motor_time*0.55)
  else: Art.draw_tile(canvas,type,position,scale,tint,evolution,depleted,motor_time*0.55)
  return
 var stump: bool = depleted and evolution == "" and Art.DEPLETED_CELLS.has(type)
 var foliage: bool = type in ["oak","forest","fiber"] or evolution in ["rainforest","grove","verdant","ironwood","moonflower","mistforest","crystalforest"]
 if not foliage or stump or reduced:
  if joined: Art.draw_joined(canvas,type,position,scale,tint,evolution,depleted)
  else: Art.draw_tile(canvas,type,position,scale,tint,evolution,depleted)
  return
 var spec: Dictionary = Art.appearance(type,evolution,depleted)
 if spec.is_empty(): return
 var mesh := foliage_mesh(spec,scale*spec.normalization,time,seed,false,impulse)
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
 if tile.type in ["grass","fiber","forest","oak"] and tile.evolution not in ["frozen","ember"]:
  draw_meadow(canvas,at,scale,time,tile.id)
 var kind := activity(tile)
 var seed: float = float(tile.id)*0.31
 if kind == "water":
  for i in range(3):
   var phase := fposmod(time*0.38+seed+i*0.47,1.0)
   var center := at+Vector2(-14 if i == 0 else 18,-14 if i == 0 else -5)*scale
   var points := PackedVector2Array()
   for step in range(17):
    var angle := TAU*step/16.0
    points.append(center+Vector2(cos(angle),sin(angle)*0.42)*(3+phase*19)*scale)
   canvas.draw_polyline(points,Color(0.77,0.93,1,sin(phase*PI)*0.7),maxf(0.7,scale),true)
 elif kind == "smoke":
  for i in range(5):
   var phase := fposmod(time*0.3+seed+i*0.2,1.0)
   var origin := Vector2(-3,-73) if tile.type == "furnace" else Vector2(0,-30)
   var offset := Vector2(sin(phase*3+seed)*7+phase*13,-phase*40)
   canvas.draw_circle(at+(origin+offset)*scale,(2+phase*6)*scale,Color(0.72,0.75,0.79,(1-phase)*0.23))
  for i in range(3):
   var phase := fposmod(time*0.65+seed+i*0.33,1.0)
   canvas.draw_circle(at+Vector2(sin(phase*8+seed)*5,-24-phase*24)*scale,1.3*scale,Color(1,0.65,0.2,sin(phase*PI)*0.8))
  var flicker := 0.23+0.09*sin(time*7+seed)
  canvas.draw_circle(at+Vector2(-1,-22)*scale,7*scale,Color(1,0.61,0.25,flicker))
 elif kind == "flour":
  for i in range(4):
   var phase := fposmod(time*0.45+seed+i*0.25,1.0)
   canvas.draw_circle(at+Vector2(10+phase*18,-10-phase*14)*scale,(1+phase)*scale,Color(0.95,0.9,0.73,sin(phase*PI)*0.75))
 elif kind == "glow":
  for i in range(3):
   var phase: float = time*0.9+seed+i*TAU/3
   canvas.draw_circle(at+Vector2(cos(phase)*17,-30+sin(phase)*9)*scale,1.8*scale,Color(0.59,0.89,0.89,0.35+0.2*sin(phase)))

# Small anchored plant clusters: only blade tips move, never the soil beneath them.
static func meadow_blade(time: float, seed: int, index: int) -> PackedVector2Array:
 var base := Vector2(-36+index*18,7+sin(seed+index*2.3)*6)
 var lean := sin(time*1.8+seed*0.7+index*0.9)*2.8
 return PackedVector2Array([base,base+Vector2(lean*0.35,-3),base+Vector2(lean,-6-index%3)])

static func draw_meadow(canvas: CanvasItem, at: Vector2, scale: float, time: float, seed: int) -> void:
 for i in range(5):
  var blade := meadow_blade(time,seed,i)
  for j in range(blade.size()): blade[j] = at+blade[j]*scale
  canvas.draw_polyline(blade,Color(0.57,0.7,0.22,0.85),maxf(0.8,scale),true)
  if i%2 == 0:
   canvas.draw_circle(blade[2],1.5*scale,Color(1,0.87,0.49,0.85))
