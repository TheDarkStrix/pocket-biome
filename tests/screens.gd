extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void:
 call_deferred("run")
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
 check(h.modal.visible and h.modal_box.get_child_count() > 20,"crafting and trade interface populated")
 h.campaign_ui.settings(h)
 check(h.modal_box.get_child_count() >= 10,"settings and guide available")
 h.campaign_ui.world(h)
 check(h.modal.visible,"world controls open")
 h.services_ui()
 check(h.modal.visible,"offline services fallback usable")
 h.modal.hide()
 h.begin_photo()
 check(h.photo_mode and not h.hud.visible and h.photo_controls.visible,"photo mode suppresses gameplay HUD")
 h.end_photo()
 check(not h.photo_mode and h.hud.visible,"photo mode restores controls")
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
  check(h.inspection_view.title.text == h.tile_title(h.model.state.tiles["0,0"]),"inspector title follows the current biome")
  h.dismiss_inspection()
  check(not h.inspection_mode and not h.modal.visible,"inspector dismissal returns input to island")
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
