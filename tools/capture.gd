extends SceneTree
func _init() -> void:
 call_deferred("capture")
func shot(name: String) -> void:
 await create_timer(0.22).timeout
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
 scene.modal.hide()
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.model.state.tiles.clear()
 for x in range(4):
  for y in range(4): scene.model.add_tile(Vector2i(x,y),"forest" if x < 2 and y < 2 else "water" if y == 2 else "grass")
 scene.model.state.chapter = 3; scene.model.state.coins = 200
 scene.model.state.objectives = [0,1,2]
 scene.presentation = preload("res://scripts/WorldPresentation.gd").new()
 scene.selected = "1,1"; scene.refresh()
 await process_frame
 await process_frame
 scene.frame_world()
 await shot("13-expansion-controls")
 scene.fusion_dialog()
 await create_timer(0.25).timeout
 await shot("14-fusion-guide")
 scene.modal.hide()
 scene.presentation.pulse("rain","1,1",scene.model.pulse_targets("1,1"))
 scene.presentation.advance(0.45); scene.queue_redraw()
 await shot("15-rain-pulse")
 scene.presentation.advance(0.4); scene.queue_redraw()
 await shot("16-rain-pulse-motion")
 scene.presentation.weather.clear()
 scene.model.state.tiles.clear()
 for index in range(6):
  scene.model.add_tile(Vector2i(index%3,index/3),["oak","water","windmill","furnace","golem","totem"][index])
 scene.presentation = preload("res://scripts/WorldPresentation.gd").new()
 scene.selected = "0,0"; scene.refresh(); scene.frame_world()
 var geometry := {"oak":[scene.screen(Vector2.ZERO).x,scene.screen(Vector2.ZERO).y],"water":[scene.screen(Vector2.RIGHT).x,scene.screen(Vector2.RIGHT).y],"zoom":scene.zoom_level,"note":"Constructed visual fixture; same simulation state in both frames."}
 var geometry_file := FileAccess.open("res://artifacts/ambient-sample-geometry.json",FileAccess.WRITE)
 geometry_file.store_string(JSON.stringify(geometry,"  ")); geometry_file.close()
 scene.ambient_time = 0.25; scene.queue_redraw()
 await shot("17-world-life-a")
 scene.ambient_time = 1.25; scene.queue_redraw()
 await shot("18-world-life-b")
 scene.campaign_ui.privacy(scene)
 await shot("19-privacy-controls")
 scene.modal.hide()
 for view in range(4):
  scene.view_turn = view; scene.frame_world(); scene.queue_redraw()
  await shot("%d-camera-view-%d" % [20+view,view*90])
 scene.model = preload("res://scripts/WorldModel.gd").new()
 for x in range(2,13): scene.model.add_tile(Vector2i(x,0),"grass")
 scene.model.state.expansions = scene.model.state.tiles.size()-4
 scene.model.state.chapter = 3; scene.model.state.harvests = 10
 scene.model.state.objectives = [0,1,2]
 scene.model.state.coins = 103; scene.model.state.inventory.wood = 165
 scene.model.state.inventory.stone = 12; scene.model.state.inventory.fiber = 31
 scene.view_turn = 0; scene.selected = "0,0"; scene.refresh()
 scene.open_ideas(); await shot("24-next-possibilities")
 scene.campaign_ui.trade(scene); await shot("25-material-trade")
 scene.modal.hide()
 scene.model.state.coins = 500
 scene.model.begin_draft("13,0")
 scene.refresh(); scene.draft(); await shot("26-local-draft-effects")
 scene.modal.hide()
 scene.model = preload("res://scripts/WorldModel.gd").new()
 scene.model.state.tiles.clear()
 for x in range(4):
  for y in range(4):
   scene.model.add_tile(Vector2i(x,y),"forest" if x < 2 else "water" if y == 1 else "stone" if y == 2 else "grass")
 scene.model.state.expansions = 12; scene.model.state.coins = 103; scene.model.state.chapter = 3
 scene.model.state.objectives = [0,1,2]; scene.model.state.energy = 150
 scene.model.state.inventory.wood = 165; scene.model.state.inventory.stone = 12; scene.model.state.inventory.fiber = 31
 scene.selected = "0,0"; scene.presentation = preload("res://scripts/WorldPresentation.gd").new()
 scene.refresh()
 await process_frame
 await process_frame
 scene.frame_world(); await shot("27-mobile-builder-hud")
 scene.campaign_ui.world(scene); await shot("28-world-hub")
 scene.queue_free()
 await process_frame
 root.size = Vector2i(320,640)
 var mobile = preload("res://tests/fixtures/MobileMain.gd").new()
 mobile.display_dp = 1.6875; mobile.store.path = "user://visual-mobile-hud.json"; mobile.show_menu_on_launch = false
 root.add_child(mobile)
 mobile.model = preload("res://scripts/WorldModel.gd").new()
 mobile.model.state.text_scale = 1.2; mobile.model.state.coins = 999999
 mobile.model.state.inventory.wood = 999999; mobile.model.state.inventory.stone = 999999; mobile.model.state.inventory.fiber = 999999
 mobile.model.state.energy = 200
 mobile.model.state.chapter = 2; mobile.model.state.objectives = [0,1,2]
 mobile.apply_settings(); mobile.refresh(); mobile.modal.hide()
 mobile.notice_time = 0
 for frame in range(5): await process_frame
 mobile.frame_world(); await shot("29-small-screen-large-text")
 mobile.queue_free()
 await process_frame
 # Audio playback references are released asynchronously by the mixer.
 await create_timer(0.15).timeout
 quit()
