extends SceneTree
# Constructed art fixtures; no earned progression or device-performance claim.
func _init() -> void: call_deferred("run")
func shot(name: String) -> void:
 await create_timer(0.35).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/"+name+".png")
func run() -> void:
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.show_menu_on_launch = false; h.store.path = "user://environment-render.json"
 root.add_child(h); h.set_process(false)
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.refresh(); h.modal.hide(); h.apply_layout(); h.frame_world()
 await shot("51-starting-island-foundation")
 h.model.state.tiles.clear()
 var types := ["forest","water","grass","stone","fiber","forest","water","grass","crystal"]
 for x in range(3):
  for y in range(3): h.model.add_tile(Vector2i(x,y),types[x*3+y])
 h.refresh(); h.frame_world()
 await shot("52-attached-island-environment")
 h.ambient_time += 0.7
 await shot("53-waterfall-motion")
 h.rotate_camera(1)
 await shot("54-environment-quarter-turn")
 h.rotate_camera(-1)
 h.model.state.pending = {"at":"-1,0","cards":["forest","water","crystal"],"cost":12}
 h.draft()
 await shot("55-environment-draft")
 h.campaign_ui.world(h)
 await shot("59-environment-world-preview")
 h.start_screen()
 await shot("56-deep-island-title")
 h.start_play(); h.modal.hide(); h.begin_photo(); h.frame_world()
 await shot("57-environment-photo")
 h.end_photo(); h.model = preload("res://scripts/WorldModel.gd").new(); h.model.state.tiles.clear()
 for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: h.model.add_tile(at,"forest")
 h.model.fuse("0,0"); h.refresh(); h.presentation.advance(10); h.frame_world()
 await shot("58-sanctuary-foundation")
 h.queue_free(); await process_frame
 await create_timer(0.2).timeout
 quit()
