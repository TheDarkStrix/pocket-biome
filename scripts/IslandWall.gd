extends Node2D
const ROCK = preload("res://assets/environment/cliff-rock.png")
const ROOTS = preload("res://assets/environment/hanging-roots.png")
const WATER = preload("res://assets/environment/waterfall.png")
var environment: Node2D
var wall := {}
var waterfall: Sprite2D
var elapsed := 0.0
func _ready() -> void:
 texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
 waterfall = Sprite2D.new(); waterfall.texture = WATER; waterfall.centered = false
 waterfall.material = environment.flow
 add_child(waterfall); waterfall.hide()
func present(clock: float) -> void:
 if wall.is_empty(): return
 elapsed = clock
 var scale: float = environment.host.zoom_level
 waterfall.visible = wall.fall
 waterfall.position = environment.project(wall.top+Vector2(-18,5))
 waterfall.scale = Vector2(36,156)*scale/Vector2(WATER.get_size())
 waterfall.modulate = environment.grade()
 queue_redraw()
func _draw() -> void:
 if wall.is_empty(): return
 paint(self,wall,environment.project,environment.host.zoom_level,environment.grade(),elapsed)
static func paint(canvas: CanvasItem, data: Dictionary, mapper: Callable, scale: float, tint: Color, clock: float) -> void:
 var points := PackedVector2Array(); var uvs := PackedVector2Array()
 var mesh: PackedVector2Array = data.get("mesh",data.points)
 for index in range(mesh.size()):
  var point: Vector2 = mesh[index]
  points.append(mapper.call(point))
  uvs.append(Vector2(point.x/170.0,0 if index < 2 else 0.8))
 var light := Color(0.86,0.9,0.88) if data.side == 0 else Color(0.66,0.76,0.77)
 canvas.draw_polygon(points,PackedColorArray([light*tint]),uvs,ROCK)
 if not data.root: return
 var variant: int = data.seed%2
 var source := Rect2(369,59,286,779) if variant == 0 else Rect2(1115,65,400,796)
 var factor := Vector2(ROOTS.get_size())/Vector2(1774,887)
 source = Rect2(source.position*factor,source.size*factor)
 var length: float = 100+data.seed%24
 var width: float = minf(34,length*source.size.x/source.size.y)
 var at: Vector2 = mapper.call(data.top+Vector2(-width/2,8))
 var sway: float = sin(clock*0.7+data.seed)*1.7*scale if clock > 0 else 0.0
 var corners := PackedVector2Array([at,at+Vector2(width*scale,0),at+Vector2(width*scale+sway,length*scale),at+Vector2(sway,length*scale)])
 var root_uvs := PackedVector2Array([source.position/Vector2(ROOTS.get_size()),Vector2(source.end.x,source.position.y)/Vector2(ROOTS.get_size()),source.end/Vector2(ROOTS.get_size()),Vector2(source.position.x,source.end.y)/Vector2(ROOTS.get_size())])
 canvas.draw_polygon(corners,PackedColorArray([tint]),root_uvs,ROOTS)
