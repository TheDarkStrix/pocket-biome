extends SceneTree
const Presentation = preload("res://scripts/WorldPresentation.gd")
const Model = preload("res://scripts/WorldModel.gd")
var failures := 0
var checks := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 var model = Model.new()
 var p = Presentation.new()
 p.sync(model.state.tiles)
 check(p.animations.is_empty(),"loading does not replay discoveries")
 model.add_tile(Vector2i(-1,0),"water")
 p.sync(model.state.tiles)
 check(p.animations["-1,0"].kind == "place","placement cue")
 check(p.pose("-1,0").scale < 1,"placement starts small")
 var state_before := JSON.stringify(model.state)
 p.advance(1)
 check(p.animations.is_empty(),"placement animation terminates")
 check(JSON.stringify(model.state) == state_before,"cosmetics cannot mutate state")
 for i in range(4): model.tick()
 p.sync(model.state.tiles)
 check(p.animations["0,0"].kind == "evolve","discovery reveal cue")
 check(p.pose("0,0").previous.evolution == "" and p.pose("0,0").mix == 0,"crossfade preserves pre-evolution appearance")
 p.sync(model.state.tiles)
 check(p.cues.is_empty(),"refresh does not replay cue")
 p.advance(2)
 check(p.pose("0,0").scale == 1 and p.animations.is_empty(),"discovery restores stable pose")
 var fusion = Model.new()
 fusion.state.tiles.clear()
 for c in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: fusion.add_tile(c,"forest")
 var f = Presentation.new()
 f.sync(fusion.state.tiles)
 fusion.fuse("0,0")
 f.sync(fusion.state.tiles)
 check(f.animations.size() == 1 and f.cues == ["fusion"],"fusion produces one presentation entity")
 check(f.pose("0,0").parts.size() == 4 and f.pose("0,0").mix == 0,"fusion retains four cosmetic parts before reveal")
 check(fusion.state.tiles["1,1"].owner == "0,0","logical fusion commits before reveal")
 var art = preload("res://scripts/TileArtwork.gd")
 var atlas_edges_safe := true
 for type in ["oak","stone","fiber","clay","iron"]:
  var spec: Dictionary = art.appearance(type,"",true)
  var width: float = spec.region.size.x
  for edge in [Vector2(width-0.00003,30),Vector2(width,30),Vector2(-0.00001,30)]:
   var relative: Vector2 = (edge-spec.pivot)*(132.0/418.0)
   var result: bool = art.hit(type,"",relative,132.0/418.0,true)
   if edge.x < 0 or edge.x >= width: atlas_edges_safe = atlas_edges_safe and not result
 check(atlas_edges_safe,"depleted atlas edge samples stay within their assigned texture regions")
 p.pulse("rain","0,0",["0,0","-1,0"])
 p.advance(1.3)
 check(p.weather.size() == 1 and p.weather[0].targets.size() == 2,"rain persists beyond old one-second flash and retains affected tiles")
 p.advance(2.0)
 check(p.weather.is_empty(),"weather terminates after the bounded shower")
 var guide = preload("res://scripts/FusionGuide.gd")
 var square = Model.new(); square.state.tiles.clear()
 for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: square.add_tile(at,"forest")
 for key in square.state.tiles:
  var options: Array = guide.options(square,key)
  check(options[0].ready and options[0].at == "0,0","any corner finds the same ready fusion group")
 square.state.tiles["1,1"].boosts = [{"until":square.state.time+8}]
 check(not guide.options(square,"1,1")[0].ready and guide.options(square,"1,1")[0].reason.contains("8s"),"fusion guide explains temporary pulse blocker")
 square.state.tiles.clear()
 for x in range(4): square.add_tile(Vector2i(x,0),"forest")
 check(not guide.options(square,"2,0")[0].ready and guide.options(square,"2,0")[0].matches == 2,"four forests in a row are explained as an incomplete square")
 var living = preload("res://scripts/WorldAmbience.gd")
 var spec: Dictionary = art.appearance("oak","")
 var a: Dictionary = living.foliage_mesh(spec,0.32,0.1,3)
 var b: Dictionary = living.foliage_mesh(spec,0.32,1.1,3)
 check(not a.points[0].is_equal_approx(b.points[0]),"foliage artwork moves between idle frames")
 check(a.points[2] == b.points[2] and a.points[3] == b.points[3] and a.base == b.base,"foliage movement leaves ground and trunk seam fixed")
 check(absf(a.shift) <= 9*0.32 and absf(b.shift) <= 9*0.32,"canopy displacement remains inside camera padding and touch tolerance")
 check(living.foliage_mesh(spec,0.32,0.1,3,true) == living.foliage_mesh(spec,0.32,8.1,3,true),"reduced motion makes the foliage mesh time-independent")
 var safe_uvs := true
 for uv in a.uvs: safe_uvs = safe_uvs and uv.x >= 0 and uv.x <= 1 and uv.y >= 0 and uv.y <= 1
 check(safe_uvs,"moving canopy samples stay within the source texture")
 check(living.activity({"type":"water","evolution":"","id":1}) == "water","water receives ongoing surface animation")
 check(living.activity({"type":"furnace","evolution":"","id":2,"enabled":false}) == "","paused automation cannot show working effects")
 var untouched: String = JSON.stringify(model.state)
 for key in model.state.tiles:
  if not model.state.tiles[key].has("owner"): living.activity(model.state.tiles[key])
 check(JSON.stringify(model.state) == untouched,"ambient classification cannot change production or saves")
 var mill = Model.new(); mill.add_tile(Vector2i(1,1),"windmill"); mill.state.tiles["1,1"].enabled = true
 var clockwork = Presentation.new()
 var pristine := JSON.stringify(mill.state)
 for frame in range(20): clockwork.advance_motors(mill.state.tiles,0.1)
 var phase: float = clockwork.motor_times["1,1"]
 var rotor_a: Dictionary = art.rotor_mesh(132.0/418.0,0)
 var rotor_b: Dictionary = art.rotor_mesh(132.0/418.0,phase*0.55)
 check(not rotor_a.points[0].is_equal_approx(rotor_b.points[0]) and rotor_a.hub == rotor_b.hub,"authored windmill sails rotate around a fixed facade axle")
 var mill_spec: Dictionary = art.appearance("windmill","")
 var envelope: Rect2 = art.visual_bounds(mill_spec,132.0/418.0)
 var fits := true
 for step in range(32):
  var mesh: Dictionary = art.rotor_mesh(132.0/418.0,TAU*step/32.0)
  for point in mesh.points: fits = fits and envelope.grow(0.01).has_point(point)
 check(fits,"windmill visual bounds contain a full revolution, not just the original blade pose")
 check(art.rotor_hit(rotor_a.hub,132.0/418.0,phase*0.55),"the moving rotor's center is selectable through registered alpha coordinates")
 mill.state.tiles["1,1"].enabled = false
 clockwork.advance_motors(mill.state.tiles,0.1)
 check(is_equal_approx(clockwork.motor_times["1,1"],phase),"pausing automation freezes its existing rotor pose")
 mill.state.tiles["1,1"].enabled = true
 clockwork.advance_motors(mill.state.tiles,0.1,true)
 check(is_equal_approx(clockwork.motor_times["1,1"],phase),"photo/reduced/background freeze keeps the existing rotor pose")
 clockwork.advance_motors(mill.state.tiles,0.1)
 check(clockwork.motor_times["1,1"] > phase,"resuming continues the rotor without resetting it")
 check(JSON.stringify(mill.state) == pristine,"motor presentation leaves all simulation and saved fields untouched")
 mill.state.tiles.erase("1,1"); clockwork.advance_motors(mill.state.tiles,0.1)
 check(clockwork.motor_times.is_empty(),"retired machine visuals release their bounded presentation entry")
 var specimens := []
 for type in model.config.tiles: specimens.append([type,""])
 for recipe in model.config.recipes+model.config.fusions: specimens.append([recipe.types[0],recipe.id])
 var smooth := true
 for specimen in specimens:
  for depleted in [false,true]:
   var surface: Dictionary = art.appearance(specimen[0],specimen[1],depleted)
   if surface.is_empty(): continue
   for part in art.surface_parts(surface,132.0/418.0):
    smooth = smooth and Geometry2D.triangulate_polygon(part.points).size() > 0
    for opacity in part.alpha: smooth = smooth and opacity >= 0 and opacity <= 1
    for uv in part.uvs: smooth = smooth and Rect2(Vector2.ZERO,Vector2.ONE).grow(0.001).has_point(uv)
 check(smooth,"all terrain and discovery skirt blends triangulate with valid source UVs and bounded edge opacity")
 var floor_image: Image = preload("res://assets/terrain/continuous-grass.png").get_image()
 if floor_image.is_compressed(): floor_image.decompress()
 var opaque := true
 for y in range(0,floor_image.get_height(),16):
  for x in range(0,floor_image.get_width(),16): opaque = opaque and floor_image.get_pixel(x,y).a >= 0.999
 check(opaque,"the connecting island floor is opaque, including its texture edges")
 print("PRESENTATION RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
