extends Node2D
const Topology = preload("res://scripts/IslandTopology.gd")
const Wall = preload("res://scripts/IslandWall.gd")
const Art = preload("res://scripts/TileArtwork.gd")
var host: Node
var geometry := {"caps":[],"walls":[],"bounds":Rect2(),"waterfalls":0}
var geometry_signature := ""
var rebuilds := 0
var slots: Array[Node2D] = []
var flow: ShaderMaterial
var frame_signature := ""
func _ready() -> void:
 show_behind_parent = true
 texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
 flow = ShaderMaterial.new(); flow.shader = preload("res://assets/shaders/island-waterfall.gdshader")
 geometry_signature = ""
func sync(tiles: Dictionary, rotation: int) -> void:
 var next := Topology.signature(tiles,rotation)
 if next == geometry_signature: return
 geometry_signature = next; geometry = Topology.build(tiles,rotation); rebuilds += 1
 if not is_inside_tree(): return
 for index in range(geometry.walls.size()):
  if index >= slots.size():
   var slot = Wall.new(); slot.environment = self; add_child(slot); slots.append(slot)
  slots[index].wall = geometry.walls[index]; slots[index].show()
 for index in range(geometry.walls.size(),slots.size()): slots[index].hide()
func bounds(tiles: Dictionary, rotation: int) -> Rect2:
 sync(tiles,rotation)
 return geometry.bounds
func project(point: Vector2) -> Vector2:
 return host.world_anchor()+host.pan+point*host.zoom_level
func grade() -> Color:
 return {"moon":Color("91a6c2"),"dusk":Color("d1b5ba"),"celestial":Color("b2d5d8")}.get(host.visible_palette(),Color.WHITE)
func _process(_delta: float) -> void:
 if not is_instance_valid(host): return
 sync(host.model.state.tiles,host.view_turn)
 var reduced: bool = host.model.state.settings.reduced_motion or host.photo_mode or host.suspended
 var clock: float = 0 if reduced else floorf(host.ambient_time*30.0)/30.0
 var signature := str([host.zoom_level,host.pan,host.world_anchor(),clock,grade(),geometry_signature,host.modal.visible,host.launch_menu,host.photo_mode,host.targeting,host.placement_blueprint])
 if signature == frame_signature: return
 frame_signature = signature
 flow.set_shader_parameter("flow_clock",clock)
 queue_redraw()
 for slot in slots:
  if slot.visible: slot.present(clock)
func _draw() -> void:
 if not is_instance_valid(host): return
 var scale: float = host.zoom_level
 # Soft local vapor belongs to this island, in front of the distant sky plate.
 for index in range(geometry.walls.size()):
  if index%2 != 0: continue
  var wall: Dictionary = geometry.walls[index]
  var point := project(wall.top+Vector2(0,103))
  var clock: float = 0 if host.model.state.settings.reduced_motion or host.photo_mode else host.ambient_time
  point.x += sin(clock*0.22+wall.seed)*5*scale
  for band in range(4,0,-1):
   var shape := PackedVector2Array()
   for step in range(21):
    var angle := TAU*step/20.0
    shape.append(point+Vector2(cos(angle)*29,sin(angle)*10)*scale*float(band)/4)
   draw_colored_polygon(shape,Color(0.86,0.93,0.91,0.012*float(5-band)))
 paint_caps(self,project,grade())
func paint_caps(canvas: CanvasItem, mapper: Callable, tint: Color) -> void:
 # One opaque world-aligned grass carpet; source tile skirts no longer create
 # brown channels or semi-transparent cracks between neighboring land cells.
 var texture: Texture2D = preload("res://assets/terrain/continuous-grass.png")
 for cap in geometry.caps:
  var center := Vector2.ZERO
  for point in cap: center += point
  center /= cap.size()
  var points := PackedVector2Array(); var uvs := PackedVector2Array()
  for point in cap:
   var seam: Vector2 = center+(point-center)*1.01
   points.append(mapper.call(seam))
   uvs.append(Vector2(seam.x/396.0,seam.y/198.0))
  canvas.draw_polygon(points,PackedColorArray([tint]),uvs,texture)
func paint_static(canvas: CanvasItem, offset: Vector2, scale: float) -> void:
 var mapper: Callable = func(point: Vector2) -> Vector2: return offset+point*scale
 paint_caps(canvas,mapper,Color.WHITE)
 for wall in geometry.walls:
  Wall.paint(canvas,wall,mapper,scale,Color.WHITE,0)
  if wall.fall:
   canvas.draw_texture_rect(Wall.WATER,Rect2(mapper.call(wall.top+Vector2(-18,5)),Vector2(36,156)*scale),false)
