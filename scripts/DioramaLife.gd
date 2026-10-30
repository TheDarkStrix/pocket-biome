extends Node3D
# Bounded scene effects. They never produce resources, receipts or saved fields.
var host: Node
var materials := {}
var mist: Array[MeshInstance3D] = []
var smoke: Array[MeshInstance3D] = []
var emitters: Array[CPUParticles3D] = []
var last_pulse := -1
var active_until:Array[float]=[0.0,0.0]
var mist_material: StandardMaterial3D
var particle_texture: GradientTexture2D
func _ready() -> void:
 var gradient:=Gradient.new();gradient.colors=PackedColorArray([Color(1,1,1,0.55),Color(1,1,1,0)])
 particle_texture=GradientTexture2D.new();particle_texture.width=64;particle_texture.height=64;particle_texture.gradient=gradient
 particle_texture.fill=GradientTexture2D.FILL_RADIAL;particle_texture.fill_from=Vector2(0.5,0.5);particle_texture.fill_to=Vector2(1,0.5)
 mist_material=StandardMaterial3D.new();mist_material.albedo_texture=particle_texture
 mist_material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;mist_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 mist_material.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED;mist_material.depth_draw_mode=BaseMaterial3D.DEPTH_DRAW_DISABLED
 for i in range(6):mist.append(puff())
 for i in range(18):smoke.append(puff())
 for i in range(2):
  var particles:=CPUParticles3D.new();particles.amount=70;particles.lifetime=0.65;particles.one_shot=false
  particles.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX;particles.emission_box_extents=Vector3(1.1,0.08,1.1)
  particles.mesh=QuadMesh.new();particles.mesh.size=Vector2(0.035,0.22)
  var material:=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;material.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED
  material.albedo_texture=particle_texture
  material.albedo_color=Color("b3e7ee");particles.material_override=material;particles.emitting=false
  add_child(particles);emitters.append(particles)
func puff() -> MeshInstance3D:
 var p:=MeshInstance3D.new();var mesh:=QuadMesh.new();mesh.size=Vector2.ONE
 p.mesh=mesh;p.material_override=mist_material;p.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(p);return p
func _process(_delta: float) -> void:
 if not is_instance_valid(host):return
 var view=host.orbit_world
 var frozen:bool=host.photo_mode or host.suspended or host.model.state.settings.reduced_motion
 var clock:float=host.ambient_time
 var center:Vector3=view.scenery_bounds.get_center()
 for i in range(mist.size()):
  var p:=mist[i];var a:float=i*TAU/6+clock*0.016
  var radius:float=maxf(view.scenery_bounds.size.x,view.scenery_bounds.size.z)*0.5+0.7
  p.position=Vector3(center.x+sin(a)*radius,-1.25+sin(clock*0.2+i)*0.12,center.z+cos(a)*radius)
  p.scale=Vector3(2.2,0.62,1);p.transparency=0.68
 var sources:=[]
 for key in host.model.state.tiles:
  var tile:Dictionary=host.model.state.tiles[key]
  if tile.has("owner") or not tile.get("enabled",true):continue
  if tile.type in ["furnace","vent"] or tile.evolution in ["steam","mistforest"]:sources.append(key)
 for i in range(smoke.size()):
  var p:=smoke[i];var source:int=i/3
  p.visible=source<sources.size() and not frozen
  if not p.visible:continue
  var tile:Dictionary=host.model.state.tiles[sources[source]]
  var cell:Vector2i=host.model.coord(sources[source]);var phase:float=fposmod(clock*0.36+(i%3)/3.0,1)
  var chimney:float=0.8 if tile.type=="furnace" else 0.35
  p.position=Vector3(cell.x+sin(phase*3+i)*0.07,chimney+phase*0.55,cell.y+phase*0.14)
  p.scale=Vector3.ONE*(0.08+phase*0.25);p.transparency=0.2+phase*0.8
 for index in range(emitters.size()):
  var emitter:=emitters[index]
  emitter.speed_scale=0 if frozen else 1;emitter.visible=not frozen
  emitter.emitting=not frozen and clock<active_until[index]
 var count:int=host.model.state.stats.pulses
 if last_pulse<0:last_pulse=count
 if count!=last_pulse:
  last_pulse=count
  if frozen or host.presentation.weather.is_empty():return
  var effect:Dictionary=host.presentation.weather[-1]
  var origin:String=host.model.origin(effect.key)
  var cell:Vector2=Vector2(host.model.coord(origin))
  if host.model.state.tiles[origin].size==4:cell+=Vector2(0.5,0.5)
  var p:CPUParticles3D=emitters[count%2]
  p.position=Vector3(cell.x,1.9 if effect.power=="rain" else 0.12,cell.y)
  p.direction=Vector3.DOWN if effect.power=="rain" else Vector3.UP
  p.gravity=Vector3(0,-4,0) if effect.power=="rain" else Vector3(0,0.04,0)
  p.initial_velocity_min=2.8 if effect.power=="rain" else 0.35;p.initial_velocity_max=3.8 if effect.power=="rain" else 0.8
  p.material_override.albedo_color={"rain":Color("a6dfe9"),"heat":Color("efbc7f"),"frost":Color("d6eff5")}[effect.power]
  p.mesh.size=Vector2(0.03,0.21) if effect.power=="rain" else Vector2(0.035,0.035)
  active_until[count%2]=clock+3.2
  p.restart();p.emitting=true
