extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void:
 call_deferred("run")
func touch(position: Vector2, down: bool) -> void:
 var event := InputEventScreenTouch.new()
 event.index = 0; event.position = position; event.pressed = down
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func click(position: Vector2) -> void:
 touch(position,true)
 await process_frame
 touch(position,false)
 await process_frame
func find_trade(node: Node) -> Button:
 if node is Button and node.get_meta("trade_resource","") == "wood" and node.get_meta("trade_quantity",0) == 20 and not node.disabled: return node
 for child in node.get_children():
  var match_button: Button = find_trade(child)
  if match_button != null: return match_button
 return null
func run() -> void:
 root.size = Vector2i(540,960)
 var h = load("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://touch-ui-tests.json"
 root.add_child(h)
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.start_screen()
 await process_frame
 await process_frame
 check(Input.is_emulating_mouse_from_touch(),"native touch emulates mouse for Godot Controls")
 var start: Button
 for child in h.launch_screen.get_children():
  if child is Button and child.text == "Start exploring": start = child
 check(start != null,"launch action is present")
 await click(start.get_global_rect().get_center())
 check(not h.launch_menu and h.modal.visible,"real screen-touch events activate the launch button and welcome panel")
 if h.launch_menu:
  h.queue_free()
  print("TOUCH UI RESULT: %d checks, %d failures" % [checks,failures])
  quit(1)
  return
 var grow: Button
 for child in h.modal_box.get_children():
  if child is Button and child.text == "Let’s grow": grow = child
 if grow != null:
  await process_frame
  await click(grow.get_global_rect().get_center())
 check(not h.modal.visible,"real touch dismisses welcome through its button")
 await process_frame
 await click(h.objective.get_global_rect().get_center())
 check(h.modal.visible and h.modal_screen == "ideas","touching the objective opens useful player choices")
 var show_oak: Button
 for panel in h.modal_box.get_children():
  if panel is PanelContainer:
   for child in panel.get_child(0).get_children():
    if child is Button and child.text == "Show the Oak": show_oak = child
 if show_oak != null:
  await process_frame
  await click(show_oak.get_global_rect().get_center())
 check(not h.modal.visible and h.model.state.harvests == 0,"a suggested action guides the player without auto-harvesting or paying rewards")
 h.frame_world()
 await process_frame
 var harvests: int = h.model.state.harvests
 await click(h.screen(Vector2.ZERO)-Vector2(0,50))
 check(h.model.state.harvests == harvests+1,"one native touch harvests exactly once despite emulated mouse pair")
 check(h.input_controller.pointers.is_empty(),"touch and emulated release leave no phantom world pointer")
 var before: int = h.model.state.harvests
 var energy: int = h.model.state.energy
 touch(h.screen(Vector2.ZERO),true)
 var second := InputEventScreenTouch.new()
 second.index = 1; second.position = h.pulse_button.get_global_rect().get_center(); second.pressed = true
 Input.parse_input_event(second); Input.flush_buffered_events()
 await process_frame
 touch(h.screen(Vector2.ZERO),false)
 second.pressed = false
 Input.parse_input_event(second); Input.flush_buffered_events()
 await process_frame
 check(h.model.state.harvests == before and h.model.state.energy == energy,"mixed UI/world two-finger sequence cannot harvest or spend energy")
 check(h.input_controller.pointers.is_empty() and h.all_touches.is_empty(),"mixed sequence clears every pointer after release")
 var pack: Button
 for action in h.stacked_buttons:
  if action.get_meta("icon_caption").text == "Pack": pack = action
 await click(pack.get_global_rect().get_center())
 check(h.modal.visible and h.modal_title.text == "Your Pack","real touch opens Pack from the illustrated dock")
 var journal: Button
 for panel in h.modal_box.get_children():
  if panel is GridContainer:
   for action in panel.get_children():
    if action is Button and action.tooltip_text == "Journal": journal = action
 await process_frame
 await click(journal.get_global_rect().get_center())
 check(h.modal.visible and h.modal_title.text.begins_with("Field Journal"),"Pack retains Journal through its actual illustrated action")
 var close: Button = h.modal_title.get_parent().get_child(1)
 await process_frame
 await click(close.get_global_rect().get_center())
 check(not h.modal.visible and not h.modal_scrim.visible,"modal close touch removes both sheet and scrim")
 await click(h.pulse_button.get_global_rect().get_center())
 check(h.modal.visible and h.modal_title.text == "World Pulse","single HUD Pulse control opens all powers through touch")
 check(is_instance_valid(h.rain_button) and is_instance_valid(h.heat_button),"power selector exposes actual playable Rain and Heat controls")
 h.modal.hide()
 await click(h.ecology_monitor.get_global_rect().get_center())
 check(h.modal.visible and h.modal_title.text == "Settings & Accessibility","the painted top-right gear opens actual Settings")
 await process_frame
 await process_frame
 var condition_help: Button
 for child in h.modal_box.get_children():
  if child is Button and child.text == "Tile conditions": condition_help = child
 check(condition_help != null,"Settings retains the tile-condition explanation")
 if condition_help != null:
  h.modal_scroll.ensure_control_visible(condition_help)
  await process_frame
  await click(condition_help.get_global_rect().get_center())
 check(h.modal_title.text == "Tile conditions","the Settings help action opens the actual tile-condition explanation")
 h.modal.hide()
 await process_frame # The contextual callout returns after the modal hides.
 await click(h.game_hud.inspect_action.get_global_rect().get_center())
 check(h.modal.visible and not h.inspection_view.is_empty(),"illustrated selected-biome inspect control opens the real inspector through touch")
 h.modal.hide()
 h.campaign_ui.settings(h)
 await process_frame
 await process_frame
 Input.emulate_touch_from_mouse = true
 var before_options: Dictionary = h.model.state.settings.duplicate(true)
 var drag_start: Vector2 = h.modal_scroll.global_position+Vector2(100,210)
 touch(drag_start,true)
 await process_frame
 var previous := drag_start
 for step in range(1,9):
  var position := drag_start-Vector2(0,step*20)
  var motion := InputEventScreenDrag.new()
  motion.index = 0; motion.position = position; motion.relative = position-previous
  Input.parse_input_event(motion); Input.flush_buffered_events()
  previous = position
  await process_frame
 touch(previous,false)
 await process_frame
 check(h.modal_scroll.scroll_vertical > 0,"real touch drag over menu controls scrolls to below-fold actions")
 check(h.model.state.settings == before_options,"scrolling across settings cannot activate its buttons")
 check(h.input_controller.pointers.is_empty() and h.all_touches.is_empty(),"menu scrolling leaves no world-input pointers")
 Input.emulate_touch_from_mouse = false
 h.campaign_ui.privacy(h)
 await process_frame
 check(h.modal.visible and h.modal_title.text == "Privacy & your data","privacy disclosure is available without initializing online services")
 h.modal.hide()
 h.campaign_ui.workshop_details(h)
 await process_frame
 var increase: Button
 for row in h.modal_box.get_children():
  if row is HBoxContainer:
   for child in row.get_children():
    if child is Button and child.text == "+": increase = child
 await click(increase.get_global_rect().get_center())
 check(h.campaign_ui.craft_quantity == 2 and h.modal.visible,"touch-triggered workshop replacement preserves GUI event lifetime")
 h.modal.hide()
 h.campaign_ui.world(h)
 await process_frame
 await process_frame
 var rotate_right: Button
 for row in h.modal_box.get_children():
  if row is HBoxContainer:
   for child in row.get_children():
    if child is Button and child.text == "Rotate right": rotate_right = child
 check(rotate_right != null,"World exposes an explicit rotate action")
 if rotate_right != null:
  await click(rotate_right.get_global_rect().get_center())
  check(h.view_turn == 1 and not h.modal.visible,"native-style touch rotates and returns to the island")
 h.rotate_camera(-1)
 h.model.state.tiles.clear()
 for x in range(4):
  for y in range(4): h.model.add_tile(Vector2i(x,y),"forest" if x%2 == 0 else "water")
 h.model.state.coins = 10000
 h.model.state.chapter = 3
 h.model.state.pending = {}
 h.selected = "0,0"; h.targeting = ""
 h.refresh()
 await process_frame
 await process_frame
 h.frame_world()
 await process_frame
 var frontier: Array = h.model.frontier()
 var offers := []
 var all_open := true
 var all_targets := true
 for key in frontier:
  await click(h.screen(h.model.coord(key)))
  all_open = all_open and h.modal.visible
  all_targets = all_targets and h.model.state.pending.get("at","") == key
  if not h.model.state.pending.has("cards"):
   printerr("Cloud missed: ",key," at ",h.screen(h.model.coord(key))," world ",h.world_rect()," picked ",h.pick(h.screen(h.model.coord(key))))
   continue
  if offers.is_empty(): offers = h.model.state.pending.cards.duplicate()
  all_targets = all_targets and h.model.state.pending.cards == offers
  h.modal.hide()
 check(all_open,"every visible expansion marker opens through real touch on a dense island")
 check(all_targets,"closing and moving drafts retains offers and selects each touched cloud")
 check(h.model.state.coins == 10000 and h.model.state.tiles.size() == 16,"opening/relocating drafts cannot debit or place land")
 h.model.state.pending = {}; h.model.state.energy = 200
 h.refresh(); h.frame_world()
 var origin := "2,2"
 h.target("rain"); h.preview = origin
 await click(h.screen(h.model.coord(origin)))
 check(h.model.state.stats.pulses == 1 and h.presentation.weather.size() == 1,"real touch releases one Rain Pulse with visible weather state")
 check(h.presentation.weather[0].targets.size() == 5,"rain covers the entire affected cross, not only the center")
 h.model.state.settings.reduced_motion = true
 h.refresh()
 check(h.presentation.weather.size() == 1,"reduced motion preserves accessible pulse confirmation instead of deleting it")
 h.targeting = ""; h.model.state.pending = {}; h.model.state.settings.reduced_motion = false
 for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: h.model.add_tile(at,"forest")
 h.selected = "1,1"; h.reveal_queue.clear()
 h.fusion_dialog()
 await process_frame
 var fusion_action: Button
 for panel in h.modal_box.get_children():
  if panel is PanelContainer:
   for child in panel.get_child(0).get_children():
    if child is Button and child.text.begins_with("Fuse into") and not child.disabled: fusion_action = child; break
   if fusion_action != null: break
 check(fusion_action != null,"fusion dialog offers a detected group without selecting its origin")
 if fusion_action != null:
  await process_frame
  await click(fusion_action.get_global_rect().get_center())
  check(h.model.state.stats.fusions == 1 and not h.modal.visible,"real touch confirms the detected fusion through the actual dialog")
 h.model.state.settings.reduced_motion = false
 h.modal.hide()
 var pulse_position: Vector2 = h.pulse_button.get_global_rect().get_center()
 touch(pulse_position,true)
 await create_timer(0.09).timeout
 check(h.pulse_button.scale.x < 1.0,"holding a HUD button produces visible press feedback")
 touch(pulse_position,false)
 await create_timer(0.2).timeout
 check(h.pulse_button.scale.is_equal_approx(Vector2.ONE),"button response settles after release without changing its layout")
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.model.state.inventory.wood = 25
 h.refresh(); h.campaign_ui.trade(h)
 await process_frame
 await process_frame
 var trade_twenty: Button = find_trade(h.modal_box)
 check(trade_twenty != null,"illustrated trade screen offers the real affordable batch")
 if trade_twenty != null:
  await click(trade_twenty.get_global_rect().get_center())
  check(h.model.state.inventory.wood == 5 and h.model.state.coins == 45,"trade touch spends exactly the selected stock and grants the displayed coins")
  check(h.store.load_state().inventory.wood == 5,"voluntary trade persists through the actual UI path")
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.model.begin_draft("-1,0"); h.draft()
 await process_frame
 await process_frame
 var saved_offers: String = JSON.stringify(h.model.state.pending)
 var saved_coins: int = h.model.state.coins
 var expected_type: String = h.model.state.pending.cards[2]
 await click(h.draft_cards[2].get_global_rect().get_center())
 check(h.draft_selection == 2 and h.confirm_card.text == "Place "+expected_type.capitalize(),"the third visible card directly selects its actual placement action")
 check(h.draft_cards[2].chosen and not h.draft_cards[1].chosen,"card touch moves the selection highlight to exactly one offer")
 check(JSON.stringify(h.model.state.pending) == saved_offers and h.model.state.coins == saved_coins,"selecting a card retains the saved offers and quoted price without paying")
 await create_timer(0.2).timeout
 await click(h.draft_hand.info.get_global_rect().get_center())
 check(h.modal_title.text.begins_with(expected_type.capitalize()) and h.model.state.coins == saved_coins,"optional card information remains reachable without paying")
 h.draft()
 await process_frame
 await process_frame
 check(h.draft_selection == 2 and h.draft_cards[2].chosen,"returning from details retains the chosen card")
 await click(h.confirm_card.get_global_rect().get_center())
 check(h.model.state.tiles["-1,0"].type == expected_type and h.model.state.pending.is_empty() and not h.modal.visible,"the explicit placement button adds the chosen biome and closes the hand")
 check(h.model.state.coins == saved_coins-int(JSON.parse_string(saved_offers).cost)+10 and h.model.state.objectives.has(1),"card confirmation debits the exact saved quote and grants the first-expansion objective once")
 check(h.bottom.visible,"placement restores the island controls")
 h.queue_free()
 await process_frame
 print("TOUCH UI RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
