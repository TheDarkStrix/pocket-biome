extends RefCounted
# Original painted caps join locally; no replacement island floor or outer cliffs.
const Grid=preload("res://scripts/PaintedGrid.gd")
const Art=preload("res://scripts/TileArtwork.gd")
static func coord(key: String) -> Vector2i:
 var pair:=key.split(",");return Vector2i(int(pair[0]),int(pair[1]))
static func front_mask(tiles: Dictionary, key: String, turn: int) -> int:
 if not tiles.has(key):return 0
 var origin:=coord(key)
 var footprint: Array[Vector2i]=[origin]
 if tiles[key].get("size",1)==4:footprint.append_array([origin+Vector2i.RIGHT,origin+Vector2i.DOWN,origin+Vector2i.ONE])
 var mask:=0
 for face in range(2):
  var direction:=Vector2i.RIGHT if face==0 else Vector2i.DOWN
  for step in range(posmod(turn,4)):direction=Vector2i(direction.y,-direction.x)
  var complete:=true
  for cell in footprint:
   var neighbor:=cell+direction
   if footprint.has(neighbor):continue
   var neighbor_key:="%d,%d" % [neighbor.x,neighbor.y]
   if not tiles.has(neighbor_key) or tiles[neighbor_key].get("owner",neighbor_key)==key:complete=false
  if complete:mask|=1<<face
 return mask
static func strips(tiles: Dictionary) -> Array:
 var result:=[]
 for key in tiles:
  var cell:=coord(key)
  for direction in [Vector2i.RIGHT,Vector2i.DOWN]:
   var next: Vector2i=cell+direction
   var other:="%d,%d" % [next.x,next.y]
   if not tiles.has(other) or tiles[key].get("owner",key)==tiles[other].get("owner",other):continue
   var a:=Vector2(cell)+(Vector2(0.5,-0.5) if direction==Vector2i.RIGHT else Vector2(-0.5,0.5))
   var b:=Vector2(cell)+Vector2(0.5,0.5)
   result.append({"a":a.lerp(b,0.07),"b":a.lerp(b,0.93)})
 return result
static func draw(canvas: CanvasItem, tiles: Dictionary, mapper: Callable, scale: float, tint: Color=Color.WHITE) -> void:
 var spec: Dictionary=Art.appearance("grass","")
 var uvs:=PackedVector2Array()
 for point in [Vector2(150,202),Vector2(268,202),Vector2(268,240),Vector2(150,240)]:uvs.append((spec.region.position+point)/spec.texture.get_size())
 for strip in strips(tiles):
  var a: Vector2=mapper.call(strip.a)+Vector2(0,Grid.SURFACE_Y)*scale
  var b: Vector2=mapper.call(strip.b)+Vector2(0,Grid.SURFACE_Y)*scale
  var across: Vector2=(b-a).orthogonal().normalized()*3.5*scale
  canvas.draw_polygon(PackedVector2Array([a-across,b-across,b+across,a+across]),PackedColorArray([tint]),uvs,spec.texture)
