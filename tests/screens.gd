extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void:
 call_deferred("run")
func named_button(node: Node, title: String) -> Button:
 if node is Button and node.text == title: return node
 for child in node.get_children():
  var found: Button = named_button(child,title)
  if found != null: return found
 return null
func run() -> void:
 var h = load("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://screen-tests.json"
 root.add_child(h)
 check(h.launch_menu and not h.hud.visible,"launch screen owns input before play")
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.refresh()
 h.start_play()
 check(not h.launch_menu and h.modal.visible,"first session shows playable welcome")
 h.modal.hide()
 h.campaign_ui.journal(h)
 check(h.modal.visible and h.modal_box.get_child_count() >= 6,"Codex includes all entries and chapter progress")
 h.campaign_ui.workshop(h)
 check(h.modal.visible and h.campaign_ui.craft_catalog.get_child_count() == h.model.config.crafting.size(),"illustrated catalogue contains every configured crafting recipe")
 var unchanged: String = JSON.stringify(h.model.state)
 named_button(h.modal_box,"Structures").pressed.emit()
 var structures_only := true
 var expected_structures := 0
 for recipe in h.model.config.crafting:
  if recipe.has("tile") and h.model.config.tiles[recipe.tile].category == "structure": expected_structures += 1
 for entry in h.campaign_ui.craft_catalog.get_children():
  structures_only = structures_only and h.model.config.tiles[entry.get_meta("recipe_id")].category == "structure"
 check(structures_only and h.campaign_ui.craft_catalog.get_child_count() == expected_structures,"category switch presents all structural recipes through the actual control")
 named_button(h.modal_box,"All").pressed.emit()
 check(h.campaign_ui.craft_catalog.get_child_count() == h.model.config.crafting.size() and JSON.stringify(h.model.state) == unchanged,"returning to the full catalogue preserves all recipes and does not spend or mutate progression")
 h.campaign_ui.settings(h)
 check(h.modal_box.get_child_count() >= 10,"settings and guide available")
 h.campaign_ui.world(h)
 check(h.modal.visible,"world controls open")
 check(h.chapter_dial.stage == h.model.state.chapter and h.chapter_dial.fraction >= 0 and h.chapter_dial.fraction <= 1,"chapter dial shows real bounded progression")
 var world_actions: GridContainer
 for child in h.modal_box.get_children():
  if child is GridContainer: world_actions = child
 check(world_actions != null and world_actions.get_child_count() == 4,"world hub provides inspect, center, fusion and photo actions")
 if world_actions != null:
  for action in world_actions.get_children():
   if action.text == "Fuse sanctuary": action.pressed.emit(); break
 check(h.modal_title.text.contains("sanctuary"),"fusion remains reachable from the redesigned world hub")
 h.services_ui()
 check(h.modal.visible,"offline services fallback usable")
 h.modal.hide()
 var prior_zoom: float = h.zoom_level
 var prior_pan: Vector2 = h.pan
 h.begin_photo()
 check(h.photo_mode and not h.hud.visible and not h.ecology_monitor.visible and h.photo_controls.visible,"photo mode suppresses gameplay HUD")
 h.end_photo()
 check(not h.photo_mode and h.hud.visible,"photo mode restores controls")
 check(is_equal_approx(h.zoom_level,prior_zoom) and h.pan.is_equal_approx(prior_pan),"leaving photo mode restores gameplay camera")
 for chapter in [1,2,3]:
  h.model.state.chapter = chapter
  for i in range(h.model.config.draft_pools[str(chapter)].size()):
   h.model.state.expansions = i
   h.model.state.coins = 100000
   h.model.state.pending = {}
   h.modal.hide()
   check(h.model.begin_draft("-1,0"),"draft available")
   h.draft()
   check(h.draft_cards.size() == 3,"draft displays every configured tile type")
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.refresh()
 h.modal.hide()
 h.apply_layout()
 await process_frame
 h.frame_world()
 h.inspect(h.screen(Vector2.ZERO)-Vector2(0,50))
 h.model.harvest("0,0")
 check(h.inspection_mode and h.inspection_view.bars.size() == 5,"inspector exposes all five live DNA bars")
 if h.inspection_mode:
  var original: float = h.inspection_view.bars.moisture.bar.value
  h.model.begin_draft("-1,0"); h.model.place(1)
  h.model.tick(1)
  h.refresh()
  check(h.inspection_view.bars.moisture.bar.value > original,"visible inspector follows environmental DNA updates")
  await create_timer(0.4).timeout
  check(h.ecology_monitor.selected_conditions.moisture == h.model.state.tiles["0,0"].dna.moisture,"conditions help retains the selected tile context through DNA changes")
  check(h.inspection_view.bars.moisture.caption.text.contains(str(int(h.model.state.tiles["0,0"].dna.moisture))),"inspector keeps actual readable moisture values off the gameplay HUD")
  check(h.inspection_view.title.text == h.tile_title(h.model.state.tiles["0,0"]),"inspector title follows the current biome")
  h.dismiss_inspection()
  check(not h.inspection_mode and not h.modal.visible,"inspector dismissal returns input to island")
 h.campaign_ui.journal(h)
 await process_frame
 check(h.modal.position == h.layout.modal.position and not h.inspection_mode,"opening Codex after inspector immediately restores full modal layout")
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.model.state.inventory.wood = 30; h.model.state.inventory.stone = 30
 h.refresh()
 check(h.model.craft("workbench",2),"batch crafting accepted with sufficient resources")
 h.campaign_ui.workshop(h)
 check(h.campaign_ui.workshop_jobs.size() == 1,"workshop shows pending project")
 h.model.tick(1); h.refresh()
 var progress_text: String = h.campaign_ui.workshop_jobs.values()[0].text
 check(progress_text.contains("× 2") and not progress_text.contains("0s"),"workshop displays batch quantity and live countdown")
 h.model.tick(10); h.refresh()
 check(h.campaign_ui.workshop_jobs.is_empty() and h.model.state.blueprints.get("workbench",0) == 2,"completed batch becomes ready without reopening workshop")
 h.campaign_ui.settings(h)
 var sliders := []
 for child in h.modal_box.get_children():
  if child is HSlider: sliders.append(child)
 check(sliders.size() == 3,"separate music/effects/text sliders")
 sliders[0].value = 0.35; sliders[1].value = 0.65; sliders[2].value = 1.15
 check(is_equal_approx(h.model.state.audio_levels.music,0.35) and is_equal_approx(h.model.state.audio_levels.sfx,0.65),"volume sliders update independent channels")
 check(is_equal_approx(h.store.load_state().text_scale,1.15),"accessibility scale persists through real settings callback")
 h.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 print("SCREENS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
