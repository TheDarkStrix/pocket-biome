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
 h.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 print("SCREENS RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
