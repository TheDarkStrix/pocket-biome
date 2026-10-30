extends SceneTree
# Cache transparent UI portraits from the actual runtime geometry and materials.
func _init() -> void:call_deferred("run")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://preview-render-only.json"
 root.add_child(h);h.set_process(false);h.hide()
 await process_frame;await process_frame
 var view=h.orbit_world;view.set_process(false);view.life.set_process(false);view.life.hide()
 view.ground.hide();view.water_nodes.hide()
 for node in view.entities.values():node.hide()
 for node in view.fauna:node.hide()
 view.viewport.size=Vector2i(256,256)
 view.camera.h_offset=0;view.camera.v_offset=0
 DirAccess.make_dir_recursive_absolute("res://assets/diorama_previews")
 var specimens:=[]
 for type in h.model.config.tiles:specimens.append([type,""])
 for recipe in h.model.config.recipes+h.model.config.fusions:specimens.append([recipe.types[0],recipe.id])
 for specimen in specimens:
  var name:String=specimen[1] if specimen[1]!="" else specimen[0]
  var prop=preload("res://scripts/DioramaProps.gd").build({"type":specimen[0],"evolution":specimen[1],"id":7},view.materials)
  view.scene.add_child(prop)
  var box:AABB=visible_bounds(prop);var center:Vector3=box.get_center()
  view.camera.position=center+Vector3(4,3.8,4);view.camera.look_at(center)
  view.camera.size=1.0
  var bounds:=Rect2(view.camera.unproject_position(box.get_endpoint(0)),Vector2.ZERO)
  for corner in range(1,8):bounds=bounds.expand(view.camera.unproject_position(box.get_endpoint(corner)))
  view.camera.size=maxf(bounds.size.x,bounds.size.y)/218.0
  await process_frame;await RenderingServer.frame_post_draw
  var result:int=view.viewport.get_texture().get_image().save_png("res://assets/diorama_previews/"+name+".png")
  if result!=OK:printerr("Preview save failed: "+name);quit(1);return
  prop.queue_free();await process_frame
 print("DIORAMA PREVIEWS: ",specimens.size()," rendered from runtime geometry")
 h.queue_free();await process_frame;await create_timer(0.3).timeout;quit()

func visible_bounds(node:Node3D) -> AABB:
 var result:=AABB();var first:=true
 for child in node.get_children():
  if not child is Node3D or not child.visible:continue
  var box:AABB=child.mesh.get_aabb() if child is MeshInstance3D else visible_bounds(child)
  box=child.transform*box
  if first:result=box;first=false
  else:result=result.merge(box)
 return result
