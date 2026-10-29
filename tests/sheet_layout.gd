extends SceneTree
const Toggle = preload("res://scripts/ToggleMark.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+text)
func _init() -> void: call_deferred("run")
func settle(h) -> void:
 for frame in range(5): await process_frame
 h.apply_layout()
 await process_frame
func run() -> void:
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(360,780),"dp":1.5},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size = display.size
   var h = preload("res://tests/fixtures/MobileMain.gd").new()
   h.display_dp = display.dp; h.show_menu_on_launch = false; h.store.path = "user://sheet-layout.json"
   root.add_child(h)
   h.model = preload("res://scripts/WorldModel.gd").new()
   h.model.state.text_scale = scale; h.model.state.energy = 200
   h.apply_settings(); h.start_play(); h.modal.hide(); h.set_process(false)
   h.model.begin_draft("-1,0"); h.draft()
   await settle(h)
   var context := "%s text=%s" % [display.size,scale]
   var hand: Control = h.draft_hand.stage
   var cards_fit := true
   var text_fits := true
   for action in h.draft_cards:
    for corner in [Vector2.ZERO,Vector2(action.size.x,0),action.size,Vector2(0,action.size.y)]:
     var point: Vector2 = hand.get_global_transform().affine_inverse()*(action.get_global_transform()*corner)
     cards_fit = cards_fit and Rect2(Vector2(-2,-2),hand.size+Vector2(4,4)).has_point(point)
    cards_fit = cards_fit and action.size.x >= h.touch_height() and action.size.y >= h.touch_height()
    text_fits = text_fits and action.title.size.x >= action.title.get_minimum_size().x and action.trait_label.size.x >= action.trait_label.get_minimum_size().x
   check(cards_fit,"all three selectable cards remain fully inside the hand with mobile touch targets at "+context)
   check(text_fits and h.confirm_card.get_global_rect().end.y <= h.modal_scroll.get_global_rect().end.y+1,"card names, traits and placement control remain visible at "+context)
   h.campaign_ui.workshop(h)
   await settle(h)
   check(h.campaign_ui.craft_catalog.get_global_rect().end.x <= h.modal_scroll.get_global_rect().end.x+1,"two-column recipe catalogue stays inside the sheet at "+context)
   h.campaign_ui.world(h)
   await settle(h)
   var actions_fit := true
   for child in h.modal_box.get_children():
    if child is GridContainer:
     for action in child.get_children():
      var content: Control = action.get_child(0)
      actions_fit = actions_fit and content.get_combined_minimum_size().y+16 <= action.size.y+1
   check(actions_fit,"illustrated World actions retain their titles and descriptions at "+context)
   h.pulse_selector()
   await settle(h)
   check(h.rain_button.size.y >= h.touch_height() and h.heat_button.size.y >= h.touch_height() and h.rain_button.get_global_rect().end.x <= h.modal_scroll.get_global_rect().end.x+1,"power previews keep usable confirmation controls inside the sheet at "+context)
   h.campaign_ui.settings(h)
   await settle(h)
   var toggles_fit := true
   for child in h.modal_box.get_children():
    if child is Button and child.get_child_count() > 0 and child.get_child(0) is Toggle:
     toggles_fit = toggles_fit and child.get_global_rect().encloses(child.get_child(0).get_global_rect()) and child.size.y >= h.touch_height()
   check(toggles_fit,"setting switches remain inside their full-size touch rows at "+context)
   h.queue_free()
   await process_frame
 print("SHEET LAYOUT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
