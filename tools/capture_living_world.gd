extends SceneTree
func _init() -> void:call_deferred("run")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://living-world-render-fixture.json"
 root.add_child(h);h.set_process(false)
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.settings.tutorial_seen=true;h.model.state.tiles.clear()
 var types: Array=["oak","water","grass","stone","forest","windmill","fiber","crystal","furnace"]
 for x in range(3):
  for y in range(3):h.model.add_tile(Vector2i(x,y),types[x*3+y])
 h.model.state.inventory.merge({"wood":18,"stone":7,"fiber":12},true);h.model.state.energy=200
 h.refresh();h.modal.hide();await process_frame;h.apply_layout();h.presentation.advance(10);h.frame_world()
 var saved:String=JSON.stringify(h.model.state)
 DirAccess.make_dir_recursive_absolute("/workspace/runtime/orbit-motion")
 var report:Dictionary={"fixture":true,"renderer":"Compatibility OpenGL, Mesa software; not phone performance","frames":24,"interval":0.12,"camera_yaw":h.orbit_world.yaw,"camera_pitch":h.orbit_world.pitch}
 for i in range(24):
  h.ambient_time=i*0.12;h.presentation.advance_motors(h.model.state.tiles,0.1);h.orbit_world._process(0.1);h.queue_redraw()
  await create_timer(0.05).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/workspace/runtime/orbit-motion/frame-%03d.png"%i)
 report["model_unchanged_during_ambient_animation"]=saved==JSON.stringify(h.model.state)
 report["mesh_instances"]=count_meshes(h.orbit_world.scene)
 report["triangles"]=count_triangles(h.orbit_world.scene)
 h.model.pulse("rain","0,1");h.presentation.pulse("rain","0,1",h.model.pulse_targets("0,1"));h.orbit_world.life._process(0)
 await create_timer(0.2).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/86-real3d-rain.png")
 var f:=FileAccess.open("res://artifacts/living-world-render-check.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  ")+"\n");f.close()
 h.queue_free();await process_frame;await create_timer(0.3).timeout;quit()
func count_meshes(node:Node) -> int:
 var total:int=1 if node is MeshInstance3D else 0
 for child in node.get_children():total+=count_meshes(child)
 return total
func count_triangles(node:Node) -> int:
 var total:int=0
 if node is MeshInstance3D:
  for surface in range(node.mesh.get_surface_count()):
   var arrays:Array=node.mesh.surface_get_arrays(surface)
   var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
   total+=(indices.size() if not indices.is_empty() else arrays[Mesh.ARRAY_VERTEX].size())/3
 for child in node.get_children():total+=count_triangles(child)
 return total
