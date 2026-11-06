extends RefCounted
# A continuous UV mesh rigs the painted objects; the soil and contact points never move.
const COLUMNS := 14
const ROWS := 16
static var grids := {}
static func weight(point: Vector2, center: Vector2, radius: Vector2) -> float:
 var distance := ((point-center)/radius).length()
 return 1.0-smoothstep(0.25,1.0,distance)
static func offset(type: String, point: Vector2, time: float, seed: int, impulse: float = 0.0) -> Vector2:
 var phase := time*1.7+seed*1.31
 var result := Vector2.ZERO
 if type == "golem":
  # Separate head nod, shoulder sway and hands; feet are outside every influence.
  result += Vector2(sin(phase*0.55)*2,-1.7*(0.5+0.5*sin(phase)))*weight(point,Vector2(203,111),Vector2(82,79))
  result += Vector2(-sin(phase)*3-impulse*5,cos(phase)*2)*weight(point,Vector2(126,178),Vector2(44,64))
  result += Vector2(sin(phase+0.9)*3+impulse*5,-cos(phase+0.9)*2)*weight(point,Vector2(286,178),Vector2(44,64))
 elif type == "workbench":
  # Tools rock around the holder, while the blueprint lifts lightly at its loose edge.
  var tool_weight := weight(point,Vector2(204,170),Vector2(44,37))
  result += Vector2(sin(phase*0.7)*3.5+impulse*4,0)*tool_weight
  result += Vector2(0,sin(phase*1.2)*1.8)*weight(point,Vector2(226,239),Vector2(53,23))
  result += Vector2(sin(phase*0.9)*1.4,0)*weight(point,Vector2(317,215),Vector2(23,32))
 elif type == "totem":
  result += Vector2(sin(phase)*3,cos(phase)*1.5)*weight(point,Vector2(146,156),Vector2(31,65))
  result += Vector2(sin(phase+1.2)*3,cos(phase+1.2)*1.5)*weight(point,Vector2(250,163),Vector2(33,64))
 return result
static func grid(spec: Dictionary) -> Dictionary:
 var key := str(spec.region)
 if grids.has(key): return grids[key]
 var source: Rect2 = spec.region
 var points := PackedVector2Array()
 var uvs := PackedVector2Array()
 var indices := PackedInt32Array()
 for row in range(ROWS+1):
  for col in range(COLUMNS+1):
   var point := Vector2(source.size.x*col/COLUMNS,source.size.y*row/ROWS)
   points.append(point)
   uvs.append((source.position+point.clamp(Vector2(0.5,0.5),source.size-Vector2(0.5,0.5)))/spec.texture.get_size())
 for row in range(ROWS):
  for col in range(COLUMNS):
   var i := row*(COLUMNS+1)+col
   indices.append_array(PackedInt32Array([i,i+1,i+COLUMNS+1,i+1,i+COLUMNS+2,i+COLUMNS+1]))
 var value := {"points":points,"uvs":uvs,"indices":indices}
 grids[key] = value
 return value
static func draw(canvas: CanvasItem, type: String, spec: Dictionary, at: Vector2, scale: float, tint: Color, time: float, seed: int, impulse: float) -> void:
 var geometry := grid(spec)
 var points: PackedVector2Array = geometry.points.duplicate()
 for i in range(points.size()):
  points[i] = at+(points[i]+offset(type,points[i],time,seed,impulse)-spec.pivot)*scale*spec.normalization
 RenderingServer.canvas_item_add_triangle_array(canvas.get_canvas_item(),geometry.indices,points,PackedColorArray([tint*spec.tint]),geometry.uvs,PackedInt32Array(),PackedFloat32Array(),spec.texture.get_rid())
