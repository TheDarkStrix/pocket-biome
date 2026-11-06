extends SceneTree
const Grid=preload("res://scripts/PaintedGrid.gd")
const Art=preload("res://scripts/TileArtwork.gd")
var checks:=0
var failures:=0
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+message)
func _init() -> void:call_deferred("run")
func run() -> void:
 for type in ["oak","fiber","stone","grass","forest","water"]:
  for depleted in [false,true]:
   var covered:=true
   for side in [-1,1]: covered=covered and Art.hit(type,"",Vector2(side*(Grid.HALF_WIDTH-3),Grid.SURFACE_Y),132.0/418.0,depleted)
   check(covered,"painted "+type+(" harvested" if depleted else " ready")+" covers both cap sides inside the logical footprint")
 for neighbor in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
  var a:=Grid.outline(Vector2.ZERO,1)
  var b:=Grid.outline(Grid.project(neighbor),1)
  var shared:=0
  for i in range(4):
   for j in range(4):
    if a[i].is_equal_approx(b[j]):shared+=1
  check(shared==2,"neighbor "+str(neighbor)+" has exactly one shared projected surface edge")
 var joins=preload("res://scripts/PaintedJoins.gd")
 var tiles={"0,0":{"type":"oak","size":1}}
 check(joins.front_mask(tiles,"0,0",0)==0 and joins.strips(tiles).is_empty(),"isolated painted blocks retain every original outer wall")
 tiles["1,0"]={"type":"stone","size":1};tiles["0,1"]={"type":"fiber","size":1}
 for turn in range(4):check(joins.front_mask(tiles,"0,0",turn)==[3,2,0,1][turn],"only occupied forward faces are clipped in view "+str(turn))
 check(joins.strips(tiles).size()==2,"texture joins are limited to the two actual shared edges")
 var fused={"0,0":{"type":"forest","size":4},"1,0":{"owner":"0,0"},"0,1":{"owner":"0,0"},"1,1":{"owner":"0,0"},"2,0":{"type":"grass","size":1}}
 check(joins.front_mask(fused,"0,0",0)==0,"a partially exposed fused edge keeps its original outer wall")
 check(joins.strips(fused).size()==1,"fusion-owned cells do not draw seams through their shared sanctuary")
 fused["2,1"]={"type":"water","size":1}
 check(joins.front_mask(fused,"0,0",0)==1,"a fully connected fused side can hide its interior wall")
 check(Art.hit("oak","",Vector2(0,30),132.0/418.0) and not Art.hit("oak","",Vector2(0,30),132.0/418.0,false,false,0,3),"hidden internal soil walls cannot intercept a touch")
 check(Art.hit("oak","",Vector2(0,10),132.0/418.0,false,false,0,3),"clipping walls keeps the visible cap selectable")
 var inverse:=true
 for x in range(-8,9):
  for y in range(-8,9):
   var cell:=Vector2(x+0.27,y-0.18)
   inverse=inverse and Grid.unproject(Grid.project(cell)).is_equal_approx(cell)
 check(inverse,"surface projection and inverse agree across all reachable coordinates")
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://painted-seams-%d.json" % Time.get_ticks_usec();root.add_child(h);await process_frame;h.set_process(false)
 h.model=preload("res://scripts/WorldModel.gd").new();h.services.model=h.model;h.model.state.settings.tutorial_seen=true
 h.model.add_tile(Vector2i(-1,0),"water");h.model.state.expansions=1;h.start_play();h.modal.hide();h.refresh();h.presentation.advance(10)
 var state_before:=JSON.stringify(h.model.state)
 for view in range(4):
  var picks:=true
  for key in h.model.state.tiles:picks=picks and h.hit(h.entity_screen(key))==key
  # At 180 degrees the foreground Oak canopy covers the rear Meadow center.
  # Alpha picking should select that visible tree, while hit() still maps the grid.
  if view==2:check(h.pick(h.entity_screen("1,1"))=="0,0","overlapping rotated canopy retains foreground-art selection")
  for key in h.model.frontier():picks=picks and h.pick(h.screen(h.model.coord(key)))==key
  check(picks,"tile mapping and visible frontier picking follow the fitted surface in view "+str(view))
  var border: Vector2=h.screen(Vector2(0.49,0.1));var beyond: Vector2=h.screen(Vector2(0.51,0.1))
  check(h.hit(border)=="0,0" and h.hit(beyond)=="1,0","grid boundary mapping remains correct in view "+str(view))
  h.rotate_camera(1)
 check(JSON.stringify(h.model.state)==state_before,"fitting painted caps changes no land ownership, inventory or progress")
 check(not h.orbit_enabled and not h.connected_land and not h.island_environment.visible,"connected painted caps retain the original art without the rejected replacement ground/cliffs")
 h.queue_free();h=null;await process_frame;await create_timer(0.2).timeout
 print("PAINTED SEAMS RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
