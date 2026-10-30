extends CanvasLayer
# Real Camera3D / mesh presentation. WorldModel remains the sole gameplay owner.
const Props = preload("res://scripts/DioramaProps.gd")
const Geometry = preload("res://scripts/DioramaGeometry.gd")
var host: Node
var viewport: SubViewport
var image: TextureRect
var scene: Node3D
var camera: Camera3D
var sun: DirectionalLight3D
var ground: Node3D
var entities := {}
var signatures := {}
var materials := {}
var topology := ""
var yaw := PI/4
var pitch := deg_to_rad(38)
var frame := Rect2(0,0,540,960)
var scenery_bounds := AABB(Vector3(-0.5,-1.2,-0.5),Vector3(2,2.8,2))
var bounds_by_key := {}
var water_material: ShaderMaterial
var fauna: Array[Node3D] = []
var clock := 0.0
var ivy_material:ShaderMaterial
var falls_material:ShaderMaterial
var water_signature := ""
var water_nodes:Node3D
var life:Node3D
var layout_signature := ""
var camera_signature:Array=[]
var remnants := {}
var ghost:Node3D
var ghost_signature := ""
var ghost_bounds := AABB()
func _ready() -> void:
 layer = -1
 viewport = SubViewport.new(); viewport.name="DioramaViewport"; viewport.own_world_3d=true
 viewport.transparent_bg=true;viewport.size=Vector2i(540,960)
 viewport.msaa_3d=Viewport.MSAA_2X
 viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 add_child(viewport)
 scene=Node3D.new();viewport.add_child(scene)
 image=TextureRect.new();image.texture=viewport.get_texture();image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 image.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(image)
 var world := WorldEnvironment.new();var env := Environment.new()
 env.background_mode=Environment.BG_CLEAR_COLOR
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("c2d8cf");env.ambient_light_energy=0.30
 env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
 world.environment=env;scene.add_child(world)
 sun=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-55,-28,0);sun.light_color=Color("fff0d0");sun.light_energy=0.65
 sun.shadow_enabled=true;sun.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL
 sun.shadow_bias=0.025;sun.shadow_normal_bias=0.05;scene.add_child(sun)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.near=0.05;camera.far=80
 scene.add_child(camera);camera.make_current()
 make_materials()
 ground=Node3D.new();ground.name="IslandFoundation";scene.add_child(ground)
 water_nodes=Node3D.new();scene.add_child(water_nodes)
 life=preload("res://scripts/DioramaLife.gd").new();life.host=host;scene.add_child(life)
 for i in range(3):
  var butterfly:=Node3D.new();var g=Geometry.new()
  g.lump(Vector3.ZERO,Vector3(0.025,0.045,0.02),Color("b5a66a"),i,"glow")
  for side in [-1,1]:
   var wing:=Node3D.new();wing.name="Wing"+str(side);wing.position.x=side*0.009;butterfly.add_child(wing)
   var w=Geometry.new();w.lump(Vector3(side*0.035,0,0),Vector3(0.045,0.005,0.035),Color("f4d69b") if i%2==0 else Color("bdcde4"),i,"cloth");w.finish(wing,materials)
  g.finish(butterfly,materials);scene.add_child(butterfly);fauna.append(butterfly)
 layout_world();sync();sync_camera()
func make_materials() -> void:
 var grass: Texture2D=preload("res://assets/terrain/continuous-grass.png")
 for category in ["solid","leaf","petal","glow","cloth","crystal"]:
  var m:=ShaderMaterial.new();m.shader=preload("res://assets/shaders/diorama-surface.gdshader")
  m.set_shader_parameter("grain",preload("res://assets/terrain/foliage-material.png") if category=="leaf" else grass);m.set_shader_parameter("wind",0.035 if category in ["leaf","petal"] else 0.006 if category=="cloth" else 0.0)
  m.set_shader_parameter("foliage",category=="leaf")
  m.set_shader_parameter("polish",0.2 if category=="crystal" else 0.86)
  m.set_shader_parameter("glow",0.65 if category=="glow" else 0.08 if category=="crystal" else 0.0)
  m.set_shader_parameter("texture_mix",0.85 if category=="leaf" else 0.10)
  materials[category]=m
 var floor_mat:=StandardMaterial3D.new();floor_mat.albedo_texture=grass;floor_mat.roughness=1.0;floor_mat.albedo_color=Color("a6ae92")
 floor_mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;floor_mat.vertex_color_use_as_albedo=true;floor_mat.cull_mode=BaseMaterial3D.CULL_DISABLED
 materials.floor=floor_mat
 var cliff:=StandardMaterial3D.new();cliff.albedo_texture=preload("res://assets/environment/cliff-rock.png");cliff.roughness=1.0;cliff.vertex_color_use_as_albedo=true;cliff.cull_mode=BaseMaterial3D.CULL_DISABLED
 materials.cliff=cliff
 ivy_material=ShaderMaterial.new();ivy_material.shader=preload("res://assets/shaders/diorama-ivy.gdshader");ivy_material.set_shader_parameter("ivy_texture",preload("res://assets/environment/hanging-roots.png"));materials.ivy=ivy_material
 water_material=ShaderMaterial.new();water_material.shader=preload("res://assets/shaders/diorama-water.gdshader");materials.water=water_material
 falls_material=ShaderMaterial.new();falls_material.shader=preload("res://assets/shaders/diorama-fall.gdshader");falls_material.set_shader_parameter("flow_texture",preload("res://assets/environment/waterfall.png"))
func layout_world() -> void:
 frame=host.get_viewport_rect()
 var signature:=str([frame,host.get_viewport().get_screen_transform().get_scale()])
 if signature==layout_signature:return
 layout_signature=signature
 var pixels:=host.get_viewport().get_screen_transform().get_scale()
 var density:=clampf(minf(pixels.x,pixels.y),1,1.5)
 viewport.size=Vector2i(maxi(1,ceili(frame.size.x*density)),maxi(1,ceili(frame.size.y*density)))
 image.position=frame.position;image.size=frame.size
func sync_camera() -> void:
 if not is_instance_valid(camera):return
 layout_world()
 var next:Array=[frame,viewport.size,host.zoom_level,host.world_anchor()+host.pan,yaw,pitch]
 if next==camera_signature:return
 camera_signature=next
 var units: float=93.338*host.zoom_level
 camera.size=frame.size.y/units
 var axis:=Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))
 camera.position=axis*24
 camera.look_at(Vector3.ZERO,Vector3.UP)
 var desired: Vector2=host.world_anchor()+host.pan
 camera.h_offset=-(desired.x-frame.size.x/2)/units
 camera.v_offset=(desired.y-frame.size.y/2)/units
func project(point: Vector3) -> Vector2:
 sync_camera()
 return frame.position+camera.unproject_position(point)*frame.size/Vector2(viewport.size)
func plane_point(position: Vector2) -> Variant:
 sync_camera()
 var pixel: Vector2=(position-frame.position)/frame.size*Vector2(viewport.size)
 var origin:=camera.project_ray_origin(pixel);var direction:=camera.project_ray_normal(pixel)
 return Plane(Vector3.UP,0).intersects_ray(origin,direction)
func cell_at(position: Vector2) -> String:
 var point=plane_point(position)
 if point==null:return ""
 return host.model.key(Vector2i(roundi(point.x),roundi(point.z)))
func pick(position: Vector2) -> String:
 sync_camera()
 var pixel: Vector2=(position-frame.position)/frame.size*Vector2(viewport.size)
 var origin:=camera.project_ray_origin(pixel);var direction:=camera.project_ray_normal(pixel)
 var best: String="";var distance:=INF
 for key in bounds_by_key:
  var node: Node3D=entities[key]
  var box: AABB=AABB(Vector3(-0.42,0,-0.42),Vector3(0.84,0.24,0.84)) if node.get_meta("depleted",false) else bounds_by_key[key]
  box=node.global_transform*box
  var hit_point=box.intersects_ray(origin,direction)
  if hit_point!=null:
   var d: float=origin.distance_squared_to(hit_point)
   if d<distance:distance=d;best=key
 return best if best!="" else cell_at(position)
func orbit(horizontal: float, vertical: float = 0.0) -> void:
 yaw=wrapf(yaw+horizontal,-PI,PI);pitch=clampf(pitch+vertical,deg_to_rad(22),deg_to_rad(68))
 sync_camera()
func sync() -> void:
 if not is_instance_valid(scene):return
 var tiles: Dictionary=host.model.state.tiles
 capture_transitions(tiles)
 var keys:=tiles.keys();keys.sort()
 var water_state:=PackedStringArray()
 for key in keys:water_state.append(str([key,tiles[key].get("type",""),tiles[key].get("evolution","")]))
 var water_next:=str(water_state)
 if water_next!=water_signature:
  water_signature=water_next;build_waterfalls(tiles)
 var signature:=str(keys)
 if topology!=signature:
  topology=signature;build_foundation(tiles)
 for key in entities.keys():
  if not tiles.has(key) or tiles[key].has("owner"):
   entities[key].queue_free();entities.erase(key);signatures.erase(key);bounds_by_key.erase(key)
 for key in tiles:
  var tile: Dictionary=tiles[key]
  if tile.has("owner"):continue
  var next:=str([tile.id,tile.type,tile.evolution,tile.size,tile.get("level",1)])
  if signatures.get(key,"")!=next:
   if entities.has(key):entities[key].queue_free()
   var node: Node3D=Props.build(tile,materials)
   var cell: Vector2i=host.model.coord(key)
   var span: float=2 if tile.size==4 else 1
   node.position=Vector3(cell.x+(0.5 if span==2 else 0.0),0,cell.y+(0.5 if span==2 else 0.0))
   node.scale=Vector3.ONE*span;scene.add_child(node);entities[key]=node;signatures[key]=next
   bounds_by_key[key]=measure(node)
  var node: Node3D=entities[key]
  var span: float=2 if tile.size==4 else 1
  var pose: Dictionary=host.presentation.pose(key)
  var reveal:float=lerpf(0.035,1.0,pose.mix) if not pose.parts.is_empty() else 1.0
  node.scale=Vector3.ONE*span*pose.scale*reveal
  node.position.y=-pose.rise/66.0
  var stump:Node3D=node.get_node_or_null("Depleted")
  if stump!=null:
   var depleted:bool=tile.ready>host.model.state.time
   var form:Node3D=node.get_node("HarvestForm")
   if node.get_meta("depleted",false) and not depleted:node.set_meta("regrowth",0.05)
   node.set_meta("depleted",depleted);stump.visible=depleted;form.visible=not depleted
  var rotor: Node3D=node.get_node_or_null("Rotor")
  if rotor!=null:rotor.rotation.z=-host.presentation.motor_times.get(key,0.0)*0.55
 update_transitions()
 update_ghost()
func build_foundation(tiles: Dictionary) -> void:
 for child in ground.get_children():child.queue_free()
 var g=Geometry.new()
 var center:=Vector3.ZERO
 for key in tiles:
  var c: Vector2i=host.model.coord(key);center+=Vector3(c.x,0,c.y)
 center/=maxi(1,tiles.size())
 var initialized:=false
 for key in tiles:
  var c: Vector2i=host.model.coord(key);var p:=Vector3(c.x,0,c.y)
  var corners: Array[Vector3]=[p+Vector3(-0.5,0,-0.5),p+Vector3(0.5,0,-0.5),p+Vector3(0.5,0,0.5),p+Vector3(-0.5,0,0.5)]
  var uv: Array[Vector2]=[]
  for v in corners:uv.append(Vector2(v.x,v.z)/2.5)
  g.triangle(corners[0],corners[2],corners[1],Color.WHITE,"floor",uv[0],uv[2],uv[1]);g.triangle(corners[0],corners[3],corners[2],Color.WHITE,"floor",uv[0],uv[3],uv[2])
  if not initialized:scenery_bounds=AABB(p-Vector3(0.5,1.4,0.5),Vector3(1,1.45,1));initialized=true
  else:scenery_bounds=scenery_bounds.merge(AABB(p-Vector3(0.5,1.4,0.5),Vector3(1,1.45,1)))
  var dirs: Array[Vector2i]=[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
  for side in range(4):
   if tiles.has(host.model.key(c+dirs[side])):continue
   var a: Vector3=corners[side];var b: Vector3=corners[(side+1)%4]
   var ba:=cliff_bottom(a,center);var bb:=cliff_bottom(b,center)
   var tint:=Color("b4b2a4")
   if posmod(c.x*7+c.y*11+side,3)!=1:
    var mid:Vector3=(a+b)/2
    var outward:=Vector3(dirs[side].x,0,dirs[side].y)*0.012
    var tangent:Vector3=(b-a).normalized()*0.12
    var tl:=mid-tangent+outward+Vector3(0,-0.015,0);var tr:=mid+tangent+outward+Vector3(0,-0.015,0)
    var bl:=tl+Vector3(0,-0.95,0);var br:=tr+Vector3(0,-0.95,0)
    var uv0:=Vector2(369,59)/Vector2(1774,887);var uv1:=Vector2(655,838)/Vector2(1774,887)
    g.triangle(tl,tr,br,Color.WHITE,"ivy",uv0,Vector2(uv1.x,uv0.y),uv1)
    g.triangle(tl,br,bl,Color.WHITE,"ivy",uv0,uv1,Vector2(uv0.x,uv1.y))
   var ma:=a.lerp(ba,0.30)+Vector3(a.x-center.x,0,a.z-center.z).normalized()*0.06
   var mb:=b.lerp(bb,0.30)+Vector3(b.x-center.x,0,b.z-center.z).normalized()*0.06
   # Each exposed segment is a split rock face, never an internal tile wall.
   g.triangle(a,mb,b,tint,"cliff",Vector2(0,0),Vector2(0.5,0.3),Vector2(0.5,0))
   g.triangle(a,ma,mb,tint,"cliff",Vector2(0,0),Vector2(0,0.3),Vector2(0.5,0.3))
   g.triangle(ma,bb,mb,tint.darkened(0.1),"cliff",Vector2(0,0.3),Vector2(0.5,1),Vector2(0.5,0.3))
   g.triangle(ma,ba,bb,tint.darkened(0.1),"cliff",Vector2(0,0.3),Vector2(0,1),Vector2(0.5,1))
 g.finish(ground,materials)
 # Water is rebuilt from types/evolutions below, independently of occupancy.
func cliff_bottom(point: Vector3, center: Vector3) -> Vector3:
 var x:=clampf((center.x-point.x)*0.32,-0.42,0.42);var z:=clampf((center.z-point.z)*0.32,-0.42,0.42)
 var seed:=posmod(roundi(point.x*2)*73856093 ^ roundi(point.z*2)*19349663,17)
 return point+Vector3(x,-0.83-seed*0.026,z)
func measure(node: Node3D) -> AABB:
 var result:=AABB(Vector3(-0.44,0,-0.44),Vector3(0.88,0.08,0.88))
 for child in node.get_children():
  if child is MeshInstance3D:result=result.merge(child.transform*child.mesh.get_aabb())
  elif child is Node3D:
   var child_box:AABB=measure(child)
   if child.name=="Rotor":child_box=child_box.merge(AABB(Vector3(-0.62,-0.62,-0.04),Vector3(1.24,1.24,0.08)))
   result=result.merge(child.transform*child_box)
 return result
func projected_bounds(include_frontier: bool = false) -> Rect2:
 sync();sync_camera()
 var world_box:=scenery_bounds
 for key in entities:
  var tile:Dictionary=host.model.state.tiles[key]
  var cell:Vector2i=host.model.coord(key)
  var span:float=2.0 if tile.size==4 else 1.0
  var at:=Vector3(cell.x+(0.5 if span==2 else 0),0,cell.y+(0.5 if span==2 else 0))
  # Fit the settled model, not a temporary placement/fusion animation scale.
  world_box=world_box.merge(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*span),at)*bounds_by_key[key])
 if is_instance_valid(ghost):world_box=world_box.merge(ghost.transform*ghost_bounds)
 var first:=true;var box:=Rect2()
 for i in range(8):
  var p:=project(world_box.get_endpoint(i))
  if first:box=Rect2(p,Vector2.ZERO);first=false
  else:box=box.expand(p)
 if include_frontier:
  for key in host.model.frontier():box=box.expand(project(Vector3(host.model.coord(key).x,0.02,host.model.coord(key).y))).grow(0)
  box=box.grow(22)
 return box.grow(12)
func fit(area: Rect2, include_frontier: bool = false) -> void:
 host.zoom_level=1;host.pan=Vector2.ZERO;sync_camera()
 var bounds:=projected_bounds(include_frontier)
 var ratio:=minf(area.size.x/maxf(1,bounds.size.x),area.size.y/maxf(1,bounds.size.y))*0.97
 var relative: Vector2=bounds.get_center()-host.world_anchor()
 host.zoom_level=clampf(ratio,0.04,2.0)
 host.pan=area.get_center()-host.world_anchor()-relative*host.zoom_level
 sync_camera()
func _process(_delta: float) -> void:
 if not is_instance_valid(host) or not host.orbit_enabled:return
 sync();sync_camera()
 viewport.render_target_update_mode=SubViewport.UPDATE_DISABLED if host.suspended else SubViewport.UPDATE_ALWAYS
 for key in entities:
  var node:Node3D=entities[key]
  var growth:float=node.get_meta("regrowth",1.0)
  if growth<1 and not host.photo_mode and not host.suspended and not host.model.state.settings.reduced_motion:
   growth=minf(1,growth+minf(_delta,0.1)*3.0);node.set_meta("regrowth",growth)
   node.get_node("HarvestForm").scale=Vector3.ONE*maxf(0.01,growth)
 clock=host.ambient_time
 for category in ["solid","leaf","petal","glow","cloth","crystal"]:materials[category].set_shader_parameter("clock",clock)
 water_material.set_shader_parameter("clock",clock)
 falls_material.set_shader_parameter("clock",clock)
 ivy_material.set_shader_parameter("clock",clock)
 var center:=scenery_bounds.get_center();center.y=0
 var alive: bool=not host.model.state.settings.reduced_motion and not host.photo_mode and not host.suspended
 for i in range(fauna.size()):
  var animal: Node3D=fauna[i];animal.visible=alive and host.visible_palette() in ["day","sakura"]
  var t: float=clock*0.33+i*2.1
  animal.position=center+Vector3(sin(t)*1.1,0.35+0.16*cos(t*2),cos(t*0.8)*0.8)
  animal.rotation.y=-t
  for side in [-1,1]:animal.get_node("Wing"+str(side)).rotation.z=side*sin(clock*12+i)*0.8
 sun.light_color=Color("dfc1c2") if host.visible_palette()=="dusk" else Color("b2d4ec") if host.visible_palette()=="moon" else Color("fff0d0")

func constrain() -> void:
 var center:=scenery_bounds.get_center();center.y=0
 var current:=project(center);var area:Rect2=host.world_rect().grow(-40)
 var kept:=Vector2(clampf(current.x,area.position.x,area.end.x),clampf(current.y,area.position.y,area.end.y))
 host.pan+=kept-current;sync_camera()
func build_waterfalls(tiles:Dictionary) -> void:
 for child in water_nodes.get_children():child.queue_free()
 var count:=0
 for key in tiles:
  var tile:Dictionary=tiles[key]
  if tile.has("owner") or tile.get("evolution","")=="frozen":continue
  if tile.get("type","")!="water" and tile.get("evolution","") not in ["lake","reedwater","lagoon"]:continue
  var c:Vector2i=host.model.coord(key)
  for item in [[Vector2i.UP,PI],[Vector2i.RIGHT,PI/2],[Vector2i.DOWN,0.0],[Vector2i.LEFT,-PI/2]]:
   var direction:Vector2i=item[0]
   if tiles.has(host.model.key(c+direction)) or count>=2:continue
   var mesh:=QuadMesh.new();mesh.size=Vector2(0.32,1.35)
   var fall:=MeshInstance3D.new();fall.mesh=mesh;fall.material_override=falls_material
   fall.position=Vector3(c.x+direction.x*0.506,-0.58,c.y+direction.y*0.506);fall.rotation.y=item[1]
   fall.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;water_nodes.add_child(fall);count+=1

func capture_transitions(tiles:Dictionary) -> void:
 # Retain the old four actual models before occupancy aliases retire them.
 for key in host.presentation.animations:
  var animation:Dictionary=host.presentation.animations[key]
  if remnants.has(key) or animation.kind not in ["fusion","evolve"]:continue
  if not tiles.has(key) or signatures.get(key,"")==str([tiles[key].id,tiles[key].type,tiles[key].evolution,tiles[key].size,tiles[key].get("level",1)]):continue
  var group:=[]
  var parts:Array=animation.parts if animation.kind=="fusion" else [{"key":key}]
  for part in parts:
   if not entities.has(part.key):continue
   var old:Node3D=entities[part.key].duplicate();scene.add_child(old)
   group.append({"node":old,"position":old.position,"scale":old.scale})
  remnants[key]=group
func update_transitions() -> void:
 for key in remnants.keys():
  var pose:Dictionary=host.presentation.pose(key)
  var progress:float=clampf(pose.progress/0.60,0,1)
  var center:Vector2i=host.model.coord(key)
  var target:=Vector3(center.x+0.5,0.08,center.y+0.5)
  for part in remnants[key]:
   var node:Node3D=part.node
   node.position=part.position.lerp(target,progress*0.7)+Vector3(0,sin(progress*PI)*0.16,0)
   node.scale=part.scale*(1.0-progress)
   node.visible=progress<1
  if pose.progress>=1 or not host.presentation.animations.has(key):
   for part in remnants[key]:part.node.queue_free()
   remnants.erase(key)
func update_ghost() -> void:
 if not is_instance_valid(host.modal):return
 var spec:Dictionary=host.build_preview()
 var next:=str(spec)
 if next==ghost_signature:return
 ghost_signature=next
 if is_instance_valid(ghost):ghost.queue_free();ghost=null
 if spec.is_empty():return
 ghost=Props.build({"type":spec.type,"evolution":"","id":1},materials)
 var paint:=StandardMaterial3D.new();paint.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 paint.albedo_color=Color(0.78,0.92,0.69,0.45);paint.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 paint.cull_mode=BaseMaterial3D.CULL_DISABLED
 tint_ghost(ghost,paint)
 var c:Vector2i=host.model.coord(spec.key);ghost.position=Vector3(c.x,0.03,c.y)
 scene.add_child(ghost);ghost_bounds=measure(ghost)
func tint_ghost(node:Node, paint:Material) -> void:
 if node is MeshInstance3D:
  node.material_override=paint;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for child in node.get_children():tint_ghost(child,paint)
