extends SceneTree
const Topology = preload("res://scripts/IslandTopology.gd")
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, detail: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+detail)
func _init() -> void: call_deferred("run")
func run() -> void:
 var model = Model.new()
 var original := JSON.stringify(model.state)
 var empty: Dictionary = Topology.build({},0)
 check(empty.walls.is_empty() and empty.caps.is_empty(),"empty land produces no phantom island")
 for rotation in range(4):
  var geometry: Dictionary = Topology.build(model.state.tiles,rotation)
  check(geometry.caps.size() == 4 and geometry.walls.size() == 4,"the four starting cells share a foundation with no interior walls at turn%d" % rotation)
  var corners := {}; var joints := true; var contained := true
  for wall in geometry.walls:
   for side in range(2):
    var key: Vector2 = wall.points[side]
    var lower: Vector2 = wall.points[3-side]
    if corners.has(key): joints = joints and corners[key].is_equal_approx(lower)
    corners[key] = lower
    contained = contained and geometry.bounds.has_point(key) and geometry.bounds.has_point(lower) and lower.y > key.y+50
  check(joints,"adjacent cliff segments meet at the same lower corner at turn%d" % rotation)
  check(contained,"deep cliff vertices fit finite camera bounds at turn%d" % rotation)
 check(JSON.stringify(model.state) == original,"geometry generation leaves the model and save unchanged")
 var signature: String = Topology.signature(model.state.tiles,0)
 for tile in model.state.tiles.values(): tile.ready += 4; tile.dna.moisture += 1
 check(Topology.signature(model.state.tiles,0) == signature,"cooldowns and DNA do not invalidate cached geometry")
 model.add_tile(Vector2i(2,0),"water")
 var expanded: Dictionary = Topology.build(model.state.tiles,0)
 check(expanded.caps.size() == 5 and expanded.walls.size() == 5,"expansion adds its actual ground and replaces the former border")
 check(expanded.waterfalls == 1,"an exposed water edge has a bounded cosmetic outlet")
 model.state.tiles["2,0"].evolution = "frozen"
 check(Topology.build(model.state.tiles,0).waterfalls == 0,"frozen water cannot show a flowing liquid waterfall")
 model.state.tiles.clear()
 for x in range(3):
  for y in range(3): model.add_tile(Vector2i(x,y),"water" if x == 1 and y == 1 else "grass")
 check(Topology.build(model.state.tiles,0).waterfalls == 0,"an interior pond cannot leak through occupied neighbors")
 model.state.tiles.erase("1,1")
 check(Topology.build(model.state.tiles,0).walls.size() == 8,"a hole adds its exposed inner boundaries")
 model.state.tiles.clear()
 for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: model.add_tile(at,"forest")
 model.fuse("0,0")
 for rotation in range(4):
  var fused: Dictionary = Topology.build(model.state.tiles,rotation)
  check(fused.caps.size() == 4 and fused.walls.size() == 4,"a fused sanctuary retains all four occupied cells without duplicate internal walls at turn%d" % rotation)
  var owners := true
  for wall in fused.walls: owners = owners and wall.origin == "0,0"
  check(owners,"sanctuary boundary decoration resolves its actual owner at turn%d" % rotation)
 model.state.tiles.clear()
 for x in range(8):
  for y in range(8): model.add_tile(Vector2i(x-4,y-4),"water")
 var large: Dictionary = Topology.build(model.state.tiles,3)
 check(large.caps.size() == 64 and large.walls.size() == 16,"large negative-coordinate islands scale with the exposed boundary")
 check(large.waterfalls <= 2,"water-heavy islands retain the two-outlet rendering budget")
 for shape in ["staircase","ring"]:
  var fixture := {}
  for x in range(16):
   for y in range(16):
    if (shape == "staircase" and (x == y or x == y+1)) or (shape == "ring" and (x == 0 or y == 0 or x == 15 or y == 15)):
     fixture["%d,%d" % [x-8,y-8]] = {"type":"grass","evolution":""}
  for rotation in range(4):
   var valid := true
   var shape_geometry: Dictionary = Topology.build(fixture,rotation)
   for wall in shape_geometry.walls:
    valid = valid and Geometry2D.triangulate_polygon(wall.mesh).size() == (wall.mesh.size()-2)*3
    for point in wall.mesh: valid = valid and shape_geometry.bounds.has_point(point)
   check(valid,"all%s cliff faces triangulate and fit bounds at turn%d" % [shape,rotation])
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://island-environment-tests.json"; h.show_menu_on_launch = false
 root.add_child(h)
 h.model = Model.new(); h.refresh(); h.modal.hide()
 for frame in range(4): await process_frame
 var count: int = h.island_environment.rebuilds
 h.model.state.time += 20; h.island_environment.bounds(h.model.state.tiles,h.view_turn)
 check(h.island_environment.rebuilds == count,"rendering a later clock reuses the existing geometry")
 h.model.add_tile(Vector2i(2,0),"water"); h.refresh()
 h.island_environment.bounds(h.model.state.tiles,h.view_turn)
 check(h.island_environment.rebuilds == count+1,"a real expansion invalidates geometry once")
 h.begin_photo(); h.frame_world()
 var geometry: Dictionary = h.island_environment.geometry
 var actual := Rect2(h.island_environment.project(geometry.bounds.position),geometry.bounds.size*h.zoom_level)
 check(h.world_rect().grow(1).encloses(actual),"photo framing includes cliff sides, roots and spray")
 h.end_photo(); h.model.state.settings.reduced_motion = true; h.apply_settings()
 h.island_environment._process(0)
 var frozen: String = h.island_environment.frame_signature
 h.ambient_time += 7; h.island_environment._process(0)
 check(h.island_environment.frame_signature == frozen,"reduced motion freezes all surrounding-environment animation")
 h.queue_free(); await process_frame
 print("ISLAND ENVIRONMENT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
