extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void: call_deferred("run")
func settle(h) -> void:
 for frame in range(4): await process_frame
 h.apply_layout(); await process_frame
func touch(position: Vector2, down: bool) -> void:
 var event := InputEventScreenTouch.new(); event.index = 0; event.position = position; event.pressed = down
 Input.parse_input_event(event); Input.flush_buffered_events()
func click(action: Control) -> void:
 touch(action.get_global_rect().get_center(),true); await process_frame
 touch(action.get_global_rect().get_center(),false); await process_frame
func confirm(tray: Node) -> Button:
 for row in tray.selection.get_children():
  for child in row.get_children():
   if child is Button and child.has_meta("build_confirm"): return child
 return null
func run() -> void:
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(360,780),"dp":1.5},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size = display.size
   var h = preload("res://tests/fixtures/MobileMain.gd").new()
   h.display_dp = display.dp; h.show_menu_on_launch = false; h.store.path = "user://build-tray-tests.json"
   root.add_child(h); h.set_process(false)
   h.model = preload("res://scripts/WorldModel.gd").new(); h.model.state.text_scale = scale
   h.model.state.settings.tutorial_seen = true
   h.apply_settings(); h.refresh(); h.start_play(); h.modal.hide(); await settle(h); h.frame_world()
   var context := "%s text=%s" % [display.size,scale]
   check(h.stacked_buttons.size() == 3 and h.stacked_buttons[0].get_meta("icon_caption").text == "Pack","three physical tools replace the five-route dock at "+context)
   var saved := JSON.stringify(h.model.state)
   var view := {"zoom":h.zoom_level,"pan":h.pan}
   h.campaign_ui.workshop(h); await settle(h)
   check(h.modal_screen == "build" and not h.bottom.visible and h.world_rect().size.y >= 100 and h.world_rect().end.y <= h.modal.position.y+1,"lower Build tray reserves a clear island view at "+context)
   var recipes := {}
   for family in ["Structures","Land","Craft"]:
    h.campaign_ui.build_family = family; h.campaign_ui.workshop(h); await settle(h)
    var tray: Control = h.campaign_ui.build_tray
    for id in tray.buttons: recipes[id] = true
    var action: Button = confirm(tray)
    check(action != null and action.size.y >= h.touch_height() and h.modal_scroll.get_global_rect().grow(1).encloses(action.get_global_rect()),"selected recipe action stays visible with a mobile target in "+family+" at "+context)
   var tray_tabs_fit := true
   for tab in h.campaign_ui.build_tray.get_child(0).get_children():
    tray_tabs_fit = tray_tabs_fit and h.modal_scroll.get_global_rect().grow(1).encloses(tab.get_global_rect()) and tab.size.y >= h.touch_height()
   check(tray_tabs_fit,"all three illustrated categories and Close stay inside the lower tray at "+context)
   check(recipes.size() == h.model.config.crafting.size() and JSON.stringify(h.model.state) == saved,"all configured recipes remain reachable without spending while browsing at "+context)
   h.campaign_ui.build_family = "Structures"; h.campaign_ui.build_choice = "windmill"; h.campaign_ui.workshop(h); await settle(h)
   var tray: Control = h.campaign_ui.build_tray
   check(tray.catalog_scroll.get_global_rect().grow(1).encloses(tray.buttons.windmill.get_global_rect()),"reopened tray reveals its retained selected object at "+context)
   check(confirm(tray).disabled and confirm(tray).tooltip_text.contains("Needs Workbench"),"locked prerequisites are explained before payment at "+context)
   h.modal.hide(); await settle(h)
   check(h.bottom.visible and is_equal_approx(view.zoom,h.zoom_level) and view.pan.is_equal_approx(h.pan),"closing Build restores the exact gameplay camera and dock at "+context)
   h.queue_free(); await process_frame
 # Execute the actual touch / save / queue / placement flow once, without debug completion.
 root.size = Vector2i(540,960)
 var h = preload("res://tests/fixtures/MobileMain.gd").new()
 h.display_dp = 1.0; h.show_menu_on_launch = false; h.store.path = "user://build-flow-transactions.json"
 root.add_child(h); h.set_process(false)
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.model.state.settings.tutorial_seen = true; h.model.state.inventory.wood = 20; h.model.state.inventory.stone = 10
 h.refresh(); h.start_play(); h.modal.hide(); await settle(h)
 await click(h.game_hud.build_action); await settle(h)
 var tray: Control = h.campaign_ui.build_tray
 check(h.modal_screen == "build" and h.campaign_ui.build_choice == "workbench","the primary Build tool opens a selected affordable recipe")
 var old := {"wood":h.model.state.inventory.wood,"stone":h.model.state.inventory.stone,"coins":h.model.state.coins}
 var action: Button = confirm(tray)
 check(not action.disabled,"the selected workbench is buildable with exact required stock")
 await click(action); await settle(h)
 check(h.model.state.jobs.size() == 1 and h.model.state.jobs[0].recipe == "workbench" and h.model.state.inventory.wood == old.wood-4 and h.model.state.inventory.stone == old.stone-2,"one Build touch starts the displayed recipe and spends its quote once")
 check(h.store.load_state().jobs.size() == 1 and h.model.state.coins == old.coins,"Build persists the real queue without inventing a coin fee")
 h.model.tick(5); h.refresh(); await settle(h)
 tray = h.campaign_ui.build_tray
 check(h.model.state.jobs.is_empty() and h.model.state.blueprints.get("workbench",0) == 1 and confirm(tray).text == "PLACE","normal crafting completion changes the selected object into a placement action without reopening")
 var unchanged: String = JSON.stringify(h.model.state)
 var ghost: Dictionary = h.build_preview()
 check(ghost.get("type","") == "workbench" and ghost.get("key","") in h.available_meadows() and JSON.stringify(h.model.state) == unchanged,"selected object previews only on an eligible Meadow without placing or reserving it")
 h.model.state.pending = {"at":"-1,0","cards":["forest","water","crystal"],"cost":12}
 h.refresh(); await settle(h)
 check(confirm(tray).disabled and confirm(tray).tooltip_text.contains("saved land draft"),"finished blueprints explain the pending-draft placement conflict")
 h.model.state.pending = {}; h.refresh(); await settle(h)
 var stock: Dictionary = h.model.state.inventory.duplicate()
 await click(confirm(tray)); await settle(h)
 check(not h.modal.visible and h.placement_blueprint == "workbench" and h.model.state.inventory == stock,"Place returns to the actual island without charging a second time")
 await click(h.draft_button); await settle(h)
 check(h.placement_blueprint == "" and h.model.state.blueprints.workbench == 1,"canceling placement keeps the completed blueprint")
 h.campaign_ui.workshop(h); await settle(h)
 await click(confirm(h.campaign_ui.build_tray)); await settle(h)
 touch(h.screen(Vector2.ONE),true); await process_frame; touch(h.screen(Vector2.ONE),false); await process_frame
 check(h.model.state.tiles["1,1"].type == "workbench" and h.model.state.blueprints.workbench == 0,"touching an empty Grass plot deploys one real blueprint from the new tray")
 check(h.store.load_state().tiles["1,1"].type == "workbench","the complete Build-to-island touch flow survives save restoration")
 h.campaign_ui.workshop(h); await settle(h)
 tray = h.campaign_ui.build_tray
 tray.choose("windmill"); await settle(h)
 var selected: String = h.campaign_ui.build_choice
 var before := JSON.stringify(h.model.state)
 Input.emulate_touch_from_mouse = true
 var start: Vector2 = tray.catalog_scroll.get_global_rect().get_center()
 touch(start,true); await process_frame
 for step in range(1,9):
  var motion := InputEventScreenDrag.new(); motion.index = 0; motion.position = start-Vector2(step*20,0); motion.relative = Vector2(-20,0)
  Input.parse_input_event(motion); Input.flush_buffered_events(); await process_frame
 touch(start-Vector2(160,0),false); await process_frame
 Input.emulate_touch_from_mouse = false
 check(tray.catalog_scroll.scroll_horizontal > 0 and JSON.stringify(h.model.state) == before and h.campaign_ui.build_choice == selected,"horizontal shelf swipe browses objects without activating a recipe or changing saved gameplay")
 h.model.state.blueprints.windmill = 1
 for key in h.available_meadows(): h.model.state.tiles[key].evolution = "meadow"
 h.refresh(); await settle(h)
 check(confirm(tray).disabled and confirm(tray).tooltip_text.contains("Restore a plot") and h.build_preview().is_empty(),"a full island explains placement restoration and suppresses a misleading ghost")
 h.modal.hide(); h.campaign_ui.pack(h); await settle(h)
 var destinations := []
 for child in h.modal_box.get_children():
  if child is GridContainer:
   for item in child.get_children():
    if item is Button: destinations.append(item.tooltip_text)
 check(destinations == ["Journal","World","Projects","Trade"],"Pack retains discovery, fusion/rotation/photo, all project queues and trading routes")
 h.queue_free(); await process_frame
 # Every sprite family clips safely at the common terrain plane, including fusions/depletion.
 var art = preload("res://scripts/TileArtwork.gd")
 var model = preload("res://scripts/WorldModel.gd").new()
 var specimens := []
 for type in model.config.tiles: specimens.append([type,""])
 for recipe in model.config.recipes+model.config.fusions: specimens.append([recipe.types[0],recipe.id])
 var valid := true
 for specimen in specimens:
  for depleted in [false,true]:
   var spec: Dictionary = art.appearance(specimen[0],specimen[1],depleted)
   if spec.is_empty(): continue
   var mesh: Dictionary = art.joined_mesh(spec,132.0/418.0)
   valid = valid and Geometry2D.triangulate_polygon(mesh.points).size() > 0 and mesh.points.size() == mesh.uvs.size()
   for point in mesh.points: valid = valid and point.y+0.46*absf(point.x) <= 26.01
   for uv in mesh.uvs: valid = valid and Rect2(Vector2(-0.001,-0.001),Vector2(1.002,1.002)).has_point(uv)
 check(valid,"all terrain, structure, discovery, fusion and depleted meshes triangulate with valid UVs above the shared foundation plane")
 print("BUILD FLOW RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
