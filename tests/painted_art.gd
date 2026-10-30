extends SceneTree
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+message)
func _init() -> void:call_deferred("run")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://painted-art-regression.json"
 root.add_child(h);h.set_process(false)
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.settings.tutorial_seen=true
 h.refresh();h.modal.hide();await process_frame
 check(not h.orbit_enabled and not is_instance_valid(h.orbit_world),"normal launch preserves the painted renderer without procedural3D scenery")
 check(not h.connected_land and h.island_environment.process_mode==Node.PROCESS_MODE_DISABLED and not h.island_environment.visible,"original painted land has no added cliff base or shared grass layer")
 var before:String=JSON.stringify(h.model.state)
 for turn in range(4):
  var valid:=true
  for key in h.model.state.tiles:valid=valid and h.hit(h.screen(h.model.coord(key)))==key
  check(valid,"painted art keeps correct grid picking at view "+str(turn))
  h.rotate_camera(1)
 check(JSON.stringify(h.model.state)==before,"restoring the painted view never alters progression, inventory or saves")
 h.model.begin_draft("-1,0");h.draft()
 var painted:=true
 for card in h.draft_cards:painted=painted and not card.art.uses_modeled_art()
 check(painted and h.draft_cards.size()==3,"every saved draft offer uses original painted artwork")
 var preview=preload("res://scripts/DioramaPreview.gd").new()
 check(not preview.uses_modeled_art(),"unhosted menu/shelf previews cannot silently substitute modeled portraits")
 preview.host=h;check(not preview.uses_modeled_art(),"hosted menu previews follow the painted default")
 preview.free()
 var art=preload("res://scripts/TileArtwork.gd")
 var original_assets:=true
 for type in h.model.config.tiles:
  var spec:Dictionary=art.appearance(type,"")
  original_assets=original_assets and not spec.is_empty() and not spec.texture.resource_path.contains("diorama_previews")
 for recipe in h.model.config.recipes+h.model.config.fusions:
  var spec:Dictionary=art.appearance(recipe.types[0],recipe.id)
  original_assets=original_assets and not spec.is_empty() and not spec.texture.resource_path.contains("diorama_previews")
 check(original_assets,"all base nodes, structures and twenty discoveries retain their original painted source assets")
 h.model.add_tile(Vector2i(2,0),"water")
 check(preload("res://scripts/IslandTopology.gd").build(h.model.state.tiles,0).waterfalls==0,"a pond beside a cliff does not manufacture an unattached waterfall")
 h.queue_free();await process_frame;await create_timer(0.15).timeout
 print("PAINTED ART RESULT: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
