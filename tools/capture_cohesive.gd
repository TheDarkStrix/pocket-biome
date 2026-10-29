extends SceneTree
# Constructed art fixture; no earned progression or physical-device claim.
func _init() -> void: call_deferred("run")
func shot(name: String) -> void:
 await create_timer(0.4).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/"+name+".png")
func run() -> void:
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.show_menu_on_launch = false; h.store.path = "user://cohesive-render.json"
 root.add_child(h); h.set_process(false)
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.model.state.settings.tutorial_seen = true
 h.model.state.tiles.clear()
 var types := ["oak","water","grass","stone","grass","windmill","dirt","forest","grass"]
 for x in range(3):
  for y in range(3): h.model.add_tile(Vector2i(x,y),types[x*3+y])
 h.model.state.coins = 103; h.model.state.inventory.wood = 165; h.model.state.inventory.stone = 12
 h.model.add_tile(Vector2i(2,-1),"workbench")
 h.refresh(); h.presentation.advance(10); h.start_play(); h.modal.hide(); h.apply_layout(); h.frame_world()
 await shot("60-cohesive-play")
 h.campaign_ui.workshop(h)
 h.campaign_ui.build_tray.choose("windmill")
 await shot("61-cohesive-build")
 h.campaign_ui.pack(h)
 await shot("62-cohesive-pack")
 h.model.state.pending = {"at":"-1,0","cards":["forest","water","crystal"],"cost":12}
 h.draft()
 await shot("63-cohesive-draft")
 h.start_screen()
 await shot("64-cohesive-title")
 h.queue_free(); await process_frame
 await create_timer(0.2).timeout
 quit()
