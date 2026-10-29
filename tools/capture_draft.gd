extends SceneTree
# Render fixtures, not earned progression or physical-device evidence.
func _init() -> void: call_deferred("run")
func shot(name: String) -> void:
 await create_timer(0.3).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/"+name+".png")
func run() -> void:
 var h = preload("res://tests/fixtures/MobileMain.gd").new()
 h.store.path = "user://draft-render-fixture.json"; h.show_menu_on_launch = false; h.display_dp = 1.0
 root.add_child(h)
 h.set_process(false)
 h.model = preload("res://scripts/WorldModel.gd").new()
 # An explicitly constructed bigger island for composition review.
 for x in range(3):
  for y in range(3):
   h.model.add_tile(Vector2i(x,y),["forest","water","grass","stone","fiber","forest","water","grass","crystal"][x*3+y])
 h.model.state.coins = 103; h.model.state.pending = {"at":"-1,0","cards":["forest","water","crystal"],"cost":12}
 h.selected = "0,0"; h.refresh(); h.frame_world(); h.draft()
 await shot("40-biome-card-hand")
 h.draft_cards[2].pressed.emit()
 await shot("41-biome-card-selected")
 root.size = Vector2i(320,640); h.display_dp = 1.6875
 h.model.state.text_scale = 1.2; h.apply_settings(); h.draft()
 await shot("42-biome-cards-large-text")
 h.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 quit()
