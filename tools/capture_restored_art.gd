extends SceneTree
func _init() -> void:call_deferred("run")
func shot(name:String) -> void:
 await create_timer(0.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/"+name+".png")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://painted-restoration-capture.json"
 root.add_child(h);h.set_process(false)
 h.model=preload("res://scripts/WorldModel.gd").new();h.model.state.settings.tutorial_seen=true
 h.model.state.tiles.clear()
 var types:Array=["oak","water","grass","stone","forest","windmill","fiber","crystal","furnace"]
 for x in range(3):
  for y in range(3):h.model.add_tile(Vector2i(x,y),types[x*3+y])
 h.model.state.inventory.merge({"wood":18,"stone":7,"fiber":12},true)
 h.refresh();h.modal.hide();await process_frame;h.apply_layout();h.presentation.advance(10);h.frame_world()
 await shot("87-restored-painted-world")
 h.campaign_ui.workshop(h);await shot("88-restored-painted-workshop")
 h.modal.hide();h.model.state.pending={"at":"-1,0","cards":["forest","water","crystal"],"cost":12};h.draft()
 await shot("89-restored-painted-draft")
 h.queue_free();await process_frame;await create_timer(0.2).timeout;quit()
