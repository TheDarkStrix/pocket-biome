extends SceneTree
func _init() -> void:call_deferred("run")
func shot(id: String) -> void:
 await create_timer(0.7).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/"+id+".png")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://orbit-art-fixture.json"
 h.orbit_enabled=true # Internal experiment only; do not replace the default painted game.
 root.add_child(h);h.set_process(false)
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.settings.tutorial_seen=true
 h.refresh();h.modal.hide();await process_frame;h.apply_layout();h.frame_world()
 await shot("80-orbit-start")
 h.model.state.tiles.clear()
 var types: Array=["oak","water","grass","stone","forest","windmill","fiber","crystal","grass"]
 for x in range(3):
  for y in range(3):h.model.add_tile(Vector2i(x,y),types[x*3+y])
 h.refresh();h.presentation.advance(10);h.frame_world();await shot("81-living-diorama")
 h.orbit_world.orbit(0.57,0.11);h.frame_world();await shot("82-free-camera")
 for step in range(30):h.presentation.advance_motors(h.model.state.tiles,0.1)
 h.ambient_time=2.0;h.queue_redraw();await shot("83-living-motion")
 h.campaign_ui.workshop(h);await shot("84-orbit-build")
 h.modal.hide();h.model.state.pending={"at":"-1,0","cards":["forest","water","crystal"],"cost":12};h.draft();await shot("85-orbit-draft")
 h.queue_free();await process_frame;await create_timer(0.2).timeout;quit()
