extends SceneTree
# Documentation-only marketing render; no game state is earned or persisted.
func _init() -> void: call_deferred("run")
func run() -> void:
 root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
 root.content_scale_size = Vector2i(1024,500)
 root.size = Vector2i(1024,500)
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.show_menu_on_launch = false; h.store.path = "user://store-art-fixture.json"
 root.add_child(h); h.set_process(false)
 h.model = preload("res://scripts/WorldModel.gd").new(); h.model.state.tiles.clear()
 var types := ["oak","water","grass","stone","grass","windmill","dirt","forest","grass"]
 for x in range(3):
  for y in range(3): h.model.add_tile(Vector2i(x,y),types[x*3+y])
 h.selected = "0,0"; h.refresh(); h.presentation.advance(10)
 h.launch_menu = true; h.hud.hide(); h.bottom.hide(); h.modal.hide(); h.notice_toast.hide()
 for frame in range(5): await process_frame
 var bounds: Rect2 = h.world_art_bounds(false)
 var hero := Rect2(500,20,500,455)
 h.zoom_level = minf(hero.size.x/bounds.size.x,hero.size.y/bounds.size.y)
 h.pan = hero.get_center()-h.world_anchor()-bounds.get_center()*h.zoom_level
 var logo := TextureRect.new(); logo.texture = preload("res://assets/ui/material/logo.png")
 logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 logo.position = Vector2(30,15); logo.size = Vector2(450,315); h.ui_root.add_child(logo)
 var caption: Label = h.label("Build a tiny world.\nDiscover what it becomes.",22,h.ui_root)
 caption.position = Vector2(45,325); caption.size = Vector2(420,100)
 caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 h.queue_redraw()
 await create_timer(0.5).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/store/feature-graphic.png")
 h.queue_free(); await process_frame; await create_timer(0.2).timeout
 quit()
