extends SceneTree
# Store-required rendition of the existing launcher identity, not new game art.
func _init() -> void: call_deferred("run")
func run() -> void:
 root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
 root.content_scale_size = Vector2i(512,512); root.size = Vector2i(512,512)
 var icon := TextureRect.new(); icon.texture = preload("res://assets/app_icon.png")
 icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.size = Vector2(512,512); root.add_child(icon)
 await create_timer(0.3).timeout; await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/store/store-icon.png")
 icon.queue_free(); await process_frame; quit()
