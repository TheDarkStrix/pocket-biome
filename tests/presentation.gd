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
 print("PRESENTATION RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
