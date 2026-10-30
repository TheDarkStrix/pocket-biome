extends SceneTree
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+message)
func _init() -> void:call_deferred("run")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://orbit-camera-tests.json"
 root.add_child(h);h.set_process(false)
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.settings.tutorial_seen=true
 h.refresh();h.modal.hide();await process_frame;h.apply_layout();h.frame_world()
 var view=h.orbit_world
 check(h.orbit_enabled and view.camera is Camera3D and view.viewport.own_world_3d,"shipping default uses a real isolated 3D camera")
 check(h.island_environment.process_mode==Node.PROCESS_MODE_DISABLED and h.island_environment.slots.is_empty(),"legacy hidden renderer cannot consume CPU or create duplicate scenery")
 var original:String=JSON.stringify(h.model.state)
 for elevation in [22,38,68]:
  view.pitch=deg_to_rad(elevation)
  for step in range(24):
   view.yaw=step*TAU/24+0.037;view.sync_camera()
   var valid:=true
   for key in h.model.state.tiles:
    var cell:Vector2i=h.model.coord(key)
    valid=valid and view.cell_at(view.project(Vector3(cell.x,0,cell.y)))==key
   check(valid,"ground picking roundtrip at non-cardinal yaw %d pitch %d"%[step,elevation])
 check(JSON.stringify(h.model.state)==original,"72 camera poses leave gameplay and saves byte-identical")
 view.orbit(TAU+0.31,10)
 check(view.pitch<=deg_to_rad(68) and view.yaw>=-PI and view.yaw<=PI,"continuous camera wraps yaw and limits steep tilt")
 view.orbit(0,-20);check(is_equal_approx(view.pitch,deg_to_rad(22)),"camera cannot tilt below the island")
 view.pitch=deg_to_rad(38);view.yaw=PI/4
 for key in h.model.frontier():check(h.pick(h.screen(h.model.coord(key)))==key,"every visible expansion target resolves "+key)
 h.tap(h.screen(Vector2.ZERO))
 check(h.model.state.inventory.wood==1,"real-camera tap harvests the starting Oak")
 view.sync();check(view.entities["0,0"].get_meta("depleted",false) and view.entities["0,0"].get_node("Depleted").visible,"harvest visibly replaces the tree with its stump")
 h.tap(h.screen(Vector2(-1,0)));check(h.modal.visible and h.draft_cards.size()==3,"real-camera expansion opens the saved three-card draft")
 h.draft_cards[1].pressed.emit();h.confirm_card.pressed.emit()
 check(h.model.state.tiles["-1,0"].type=="water","normal draft confirmation places Water")
 for i in range(5):h.model.tick(1.0)
 h.refresh();view.sync()
 check(h.model.state.discoveries.has("rainforest") and view.entities.has("0,0") and view.signatures["0,0"]==str([h.model.state.tiles["0,0"].id,h.model.state.tiles["0,0"].type,h.model.state.tiles["0,0"].evolution,h.model.state.tiles["0,0"].size,h.model.state.tiles["0,0"].get("level",1)]),"public gameplay reaches the first evolution in the shipping renderer")
 h.persist();check(h.store.load_state().discoveries.has("rainforest"),"new presentation retains actual save/load progression")
 var props=preload("res://scripts/DioramaProps.gd")
 var profiles:Dictionary=props.PROFILES
 var all_profiles:=true;var distinct:=[]
 for recipe in h.model.config.recipes+h.model.config.fusions:
  all_profiles=all_profiles and profiles.has(recipe.id)
  var prop:Node3D=props.build({"type":recipe.types[0],"evolution":recipe.id,"id":7},view.materials)
  check(prop.get_node("HarvestForm").get_child_count()>0 and view.measure(prop).size.y>0.1,"actual modeled discovery "+recipe.id)
  distinct.append(recipe.id);prop.free()
 check(all_profiles and distinct.size()==20,"all twenty discoveries have explicit authored appearance profiles")
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.tiles.clear()
 for cell in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]:h.model.add_tile(cell,"forest")
 h.presentation=preload("res://scripts/WorldPresentation.gd").new();h.refresh();view.sync()
 h.model.fuse("0,0");h.refresh();view.sync()
 check(view.entities.size()==1 and view.remnants.get("0,0",[]).size()==4,"fusion retains four old models while one authoritative sanctuary replaces them")
 var growing_bounds:Rect2=view.projected_bounds(false)
 h.presentation.advance(0.9);view.sync()
 check(view.entities["0,0"].scale.x>1 and not view.remnants["0,0"][0].node.visible,"fusion converges into the larger visible model")
 h.presentation.advance(1);view.sync();await process_frame
 check(growing_bounds.is_equal_approx(view.projected_bounds(false)),"fusion framing reserves its full settled height throughout growth")
 check(view.remnants.is_empty(),"retired fusion geometry is freed after its bounded transition")
 for angle in [0.13,1.31,2.77,4.2,5.88]:
  view.yaw=angle;view.sync_camera()
  check(h.model.origin(view.pick(view.project(Vector3(0.5,0.7,0.5))))=="0,0","fused model picking resolves its origin at arbitrary angle")
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.settings.tutorial_seen=true
 h.presentation=preload("res://scripts/WorldPresentation.gd").new();h.refresh();h.modal.hide();view.sync()
 h.campaign_ui.workshop(h);view.sync()
 check(is_instance_valid(view.ghost) and view.ghost.get_parent()==view.scene,"selected structure has a real3D placement preview")
 var before:String=JSON.stringify(h.model.state)
 view.orbit(0.41,0.1);view.sync()
 check(JSON.stringify(h.model.state)==before,"orbiting the preview cannot reserve land, charge or collect")
 h.modal.hide();view.sync();check(not is_instance_valid(view.ghost),"closing Build removes the unplaced preview")
 h.model.add_tile(Vector2i(2,1),"windmill");h.model.add_tile(Vector2i(2,0),"water");h.refresh();view.sync()
 h.presentation.advance_motors(h.model.state.tiles,0.1);view.sync()
 check(view.bounds_by_key["2,1"].end.y>=1.3,"windmill camera bounds include the entire circular sail sweep")
 check(not is_zero_approx(view.entities["2,1"].get_node("Rotor").rotation.z),"windmill rotor uses retained simulation-independent motion")
 check(view.water_nodes.get_child_count()<=2 and view.fauna.size()==3 and view.life.smoke.size()==18,"world ambient effects obey fixed mobile object budgets")
 h.ambient_time=2.0;view._process(0)
 check(is_equal_approx(view.materials.leaf.get_shader_parameter("clock"),2.0),"foliage shader receives the visible world clock")
 h.model.state.settings.reduced_motion=true
 var clock:float=h.ambient_time;h._process(0.1);view._process(0.1)
 check(h.ambient_time==clock and not view.fauna[0].visible,"reduced motion freezes ambient animation and hides moving wildlife")
 h.model.state.settings.reduced_motion=false;h.photo_mode=true;view._process(0.1)
 check(not view.fauna[0].visible and view.life.emitters.size()==2,"photo mode hides transient wildlife with bounded weather emitters")
 h.photo_mode=false;h.suspended=true;view._process(0)
 check(view.viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED,"backgrounding stops offscreen rendering")
 h.suspended=false;h.model.state.energy=200;h.model.pulse("rain","0,0");h.presentation.pulse("rain","0,0",h.model.pulse_targets("0,0"))
 view.life.last_pulse=h.model.state.stats.pulses-1;view.life._process(0)
 check(view.life.emitters[h.model.state.stats.pulses%2].emitting,"Rain Pulse emits an actual 3D shower")
 # Native gesture path: a complete twist emits continuous angles, never a harvest.
 var controller=preload("res://scripts/InputController.gd").new();controller.continuous_orbit=true
 var totals:Dictionary={"angle":0.0,"taps":0}
 controller.orbited.connect(func(a):totals.angle+=a);controller.tapped.connect(func(_p):totals.taps+=1)
 controller.begin(0,Vector2(200,400),0);controller.begin(1,Vector2(300,400),0)
 for degree in range(10,361,10):controller.move(1,Vector2(200,400)+Vector2.from_angle(deg_to_rad(degree))*100)
 controller.finish(1,Vector2(300,400),1);controller.finish(0,Vector2(200,400),1)
 check(absf(totals.angle)>6 and totals.taps==0,"full native two-finger twist orbits continuously without triggering gameplay")
 # All live model cards resolve to the same authored UI portrait family.
 var portraits=preload("res://scripts/DioramaPortraits.gd")
 var complete:=true
 for type in h.model.config.tiles:complete=complete and portraits.texture(type)!=null
 for recipe in h.model.config.recipes+h.model.config.fusions:complete=complete and portraits.texture(recipe.types[0],recipe.id)!=null
 check(complete,"every base tile and discovery has an imported runtime-model UI portrait")
 for screen_size in [Vector2i(320,640),Vector2i(360,780),Vector2i(540,960)]:
  root.size=screen_size;await process_frame;h.apply_layout();h.frame_world();await process_frame
  var bounds:Rect2=view.projected_bounds(false)
  check(h.world_rect().grow(2).encloses(bounds),"actual3D island fits mobile gameplay at "+str(screen_size))
  var snapshot:String=JSON.stringify(h.model.state)
  var old_yaw:float=view.yaw
  var down:=InputEventMouseButton.new();down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true
  h.orbit_pad._gui_input(down)
  var drag:=InputEventMouseMotion.new();drag.relative=Vector2(60,12);h.orbit_pad._gui_input(drag)
  down.pressed=false;h.orbit_pad._gui_input(down)
  check(not is_equal_approx(old_yaw,view.yaw) and snapshot==JSON.stringify(h.model.state),"compass drag rotates without changing gameplay at "+str(screen_size))
 h.queue_free();await process_frame;await create_timer(0.15).timeout
 print("ORBIT WORLD RESULT: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
