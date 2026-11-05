extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Store = preload("res://scripts/SaveStore.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func completed_world():
 var m = Model.new()
 for x in range(5):
  for y in range(5):
   if not m.state.tiles.has(m.key(Vector2i(x,y))): m.add_tile(Vector2i(x,y),"grass")
 m.state.expansions = m.state.tiles.size()-4
 for recipe in m.config.recipes+m.config.fusions: m.state.discoveries.append(recipe.id)
 m.state.objectives = [0,1,2]; m.state.chapter = 5; m.state.chapter_rewards = [1,2,3,4,5]
 m.state["habitat_projects"] = ["sanctuary_network"]
 m.state.settings.tutorial_seen = true
 m.campaign.evaluate(m)
 return m
func button(node: Node, title: String) -> Button:
 for child in node.find_children("*","Button",true,false):
  if child.text == title: return child
 return null
func _init() -> void: call_deferred("run")
func run() -> void:
 var store = Store.new(); store.path = "user://finale-tests.json"
 var m = completed_world()
 check(store.valid(m.state),"an existing completed save without the new flag remains valid")
 var coins: int = m.state.coins
 m.campaign.evaluate(m)
 check(m.state.coins == coins,"campaign completion reward remains exactly once")
 var corrupt: Dictionary = m.state.duplicate(true); corrupt.finale_seen = "yes"
 check(not store.valid(corrupt),"non-boolean finale marker is rejected")
 corrupt = m.state.duplicate(true); corrupt.finale_seen = true; corrupt.chapter_rewards.erase(5)
 check(not store.valid(corrupt),"finale cannot be marked complete before earning the last chapter")
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://finale-ui-tests.json"; h.show_menu_on_launch = false
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = m; h.services.model = m
 h.refresh(); h.presentation.advance(10); h.reveal_queue.clear(); h.modal.hide()
 h.start_screen()
 check(not h.finale_ui.maybe_show(h),"finale never interrupts the title")
 h.start_play(); h.modal.hide(); h.presentation.advance(10); h.reveal_queue.clear()
 h.campaign_ui.settings(h)
 check(not h.finale_ui.maybe_show(h),"finale waits for an open screen to close")
 h.modal.hide(); h.targeting = "rain"
 check(not h.finale_ui.maybe_show(h),"finale does not interrupt targeting")
 h.targeting = ""
 var before := {"coins":m.state.coins,"inventory":m.state.inventory.duplicate(),"rewards":m.state.chapter_rewards.duplicate()}
 check(h.finale_ui.maybe_show(h) and h.modal_screen == "finale","completed campaign opens a dedicated celebration at a safe moment")
 check(h.store.load_state().get("finale_seen",false),"celebration acknowledgement survives save restoration")
 h.finale_ui.show(h)
 check(m.state.coins == before.coins and m.state.inventory == before.inventory and m.state.chapter_rewards == before.rewards,"replaying the celebration cannot award currency or chapter rewards")
 button(h.modal_box,"Keep creating").pressed.emit()
 check(not h.modal.visible and not h.finale_ui.maybe_show(h),"continue returns to play without reopening the finale")
 h.campaign_ui.journal(h)
 check(button(h.modal_box,"Celebrate your sanctuary") != null,"Journal lets completed players replay their milestone")
 button(h.modal_box,"Celebrate your sanctuary").pressed.emit()
 button(h.modal_box,"Frame an island portrait").pressed.emit()
 check(h.photo_mode and not h.modal.visible,"portrait action opens the real photo mode")
 h.end_photo()
 root.size = Vector2i(320,640); h.model.state.text_scale = 1.2; h.apply_settings(); h.finale_ui.show(h)
 for frame in range(5): await process_frame
 h.apply_layout(); await process_frame
 var keep: Button = button(h.modal_box,"Keep creating")
 check(h.modal_scroll.get_global_rect().grow(1).encloses(keep.get_global_rect()),"continued-play action remains reachable at small-phone enlarged text")
 h.modal_scroll.scroll_vertical = 10000
 await process_frame
 check(h.modal_scroll.get_global_rect().grow(1).encloses(button(h.modal_box,"Explore expeditions").get_global_rect()),"bottom finale action fits the small-phone scroll viewport")
 h.model.state.erase("finale_seen"); h.finale_ui.presented_this_session = false
 var path: String = h.store.path; h.store.path = "user://absent-finale-parent/fail.json"
 h.finale_ui.show(h)
 check(not h.model.state.has("finale_seen") and h.save_dirty,"failed save leaves the milestone retryable on a future launch")
 h.modal.hide()
 check(not h.finale_ui.maybe_show(h),"failed acknowledgement cannot cause a modal loop in the current session")
 h.store.path = path; h.persist()
 h.queue_free(); h = null; await process_frame
 print("FINALE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
