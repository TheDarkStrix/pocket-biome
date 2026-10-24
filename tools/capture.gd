extends SceneTree
func _init() -> void:
 call_deferred("capture")
func shot(name: String) -> void:
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 var result = root.get_texture().get_image().save_png("res://artifacts/"+name+".png")
 if result != OK: printerr("Screenshot write failed: ",result)
func capture() -> void:
 var scene = load("res://scenes/Main.tscn").instantiate()
 scene.store.path = "user://visual-review.json"
 scene.show_menu_on_launch = false
 root.add_child(scene)
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.presentation = preload("res://scripts/WorldPresentation.gd").new()
 scene.refresh()
 await shot("01-launch")
 scene.tap(scene.screen(Vector2.ZERO))
 scene.tap(scene.screen(Vector2(-1,0)))
 await shot("02-draft")
 scene.draft_cards[1].pressed.emit()
 scene.confirm_card.pressed.emit()
 var deadline: int = Time.get_ticks_msec()+30000
 while not scene.model.state.discoveries.has("rainforest") and Time.get_ticks_msec() < deadline:
  await process_frame
 if not scene.model.state.discoveries.has("rainforest"):
  printerr("Normal-path visual capture did not reach first evolution")
  quit(1)
  return
 await shot("03-evolution")
 scene.inspect(scene.screen(Vector2.ZERO))
 await shot("04-inspector")
 scene.modal.hide()
 scene.campaign_ui.journal(scene)
 await shot("07-codex")
 scene.campaign_ui.detail(scene,"celestial")
 await shot("08-codex-detail")
 scene.campaign_ui.workshop(scene)
 await shot("09-workshop")
 scene.campaign_ui.settings(scene)
 await shot("10-settings")
 scene.modal.hide()
 scene.start_screen()
 await shot("11-launch-menu")
 scene.start_play()
 scene.modal.hide()
 scene.pulse_selector()
 await shot("12-pulse-selector")
 scene.modal.hide()
 scene.set_process(false)
 scene.model.state.tiles.clear()
 scene.model.state.discoveries = []
 var types := ["forest","fiber","water","forest","grass","grass"]
 var evolutions := ["rainforest","ember","lake","steam","frozen",""]
 for i in range(6):
  var at := Vector2i(i%3,i/3)
  scene.model.add_tile(at,types[i])
  scene.model.state.tiles[scene.model.key(at)].evolution = evolutions[i]
  if evolutions[i] != "": scene.model.state.discoveries.append(evolutions[i])
 scene.model.state.expansions = 2
 scene.model.message = "VISUAL FIXTURE · five evolved biomes (not progression evidence)"
 scene.presentation = preload("res://scripts/WorldPresentation.gd").new()
 scene.pan = Vector2(-30,-15)
 scene.zoom_level = 0.95
 scene.selected = "0,0"
 scene.refresh()
 await shot("05-biome-art-review")
 scene.model.state.tiles.clear()
 for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: scene.model.add_tile(at,"forest")
 scene.model.state.expansions = 0
 scene.model.fuse("0,0")
 scene.model.message = "VISUAL FIXTURE · Ancient Grove (not progression evidence)"
 scene.presentation = preload("res://scripts/WorldPresentation.gd").new()
 scene.pan = Vector2(-30,-15)
 scene.zoom_level = 1.0
 scene.refresh()
 await shot("06-fusion-art-review")
 scene.queue_free()
 await process_frame
 # Audio playback references are released asynchronously by the mixer.
 await create_timer(0.15).timeout
 quit()
