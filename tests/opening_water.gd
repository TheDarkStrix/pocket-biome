extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Opening = preload("res://scripts/OpeningWater.gd")
const Learn = preload("res://scripts/LearningJourney.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func blocked(seed: int = 7):
 var m = Model.new(); m.state.seed = seed; m.harvest("0,0")
 m.begin_draft("2,1"); m.place(m.state.pending.cards.find("water"))
 return m
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = blocked()
 check(m.state.tiles["2,1"].type == "water" and Learn.current(m).action == "expand","reproduce a pond beyond the Meadow while Oak still needs Water")
 var before := JSON.stringify(m.state)
 check(Opening.targets(m) == ["-1,0","0,-1"],"only the two empty edge-sharing Oak plots are highlighted")
 check(not Opening.valid_target(m,"2,0") and JSON.stringify(m.state) == before,"corner/remote plots are excluded and guidance is read-only")
 var no_water_seeds := 0
 var recovery := true
 for seed in range(64):
  var sample = blocked(seed)
  var raw: Array = preload("res://scripts/DraftDealer.gd").deal(sample.config,seed,1,1)
  if not raw.has("water"): no_water_seeds += 1
  var coins: int = sample.state.coins
  recovery = recovery and sample.begin_draft("-1,0") and sample.state.pending.cards.has("water") and sample.state.coins == coins and sample.state.pending.cards.size() == 3
  if not raw.has("water"): recovery = recovery and sample.state.pending.cards[0] == raw[0] and sample.state.pending.cards[2] == raw[2]
 check(no_water_seeds > 0 and recovery,"64 seeded openings recover without random redraw, changing the foundation or debiting Coins")
 m = blocked(); m.begin_draft("2,0")
 m.state.pending.cards = ["grass","stone","crystal"]
 var saved: Dictionary = m.state.pending.duplicate(true)
 var coins: int = m.state.coins
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://opening-water-legacy.json"
 check(store.save_state(m.state),"old missing-Water hand remains a valid save fixture")
 var loaded = Model.new(); loaded.state = store.load_state()
 check(loaded.ensure_opening_water_offer(),"existing saved hand repairs after update")
 check(loaded.state.pending.cards == ["grass","water","crystal"] and loaded.state.pending.cost == saved.cost and loaded.state.pending.at == saved.at and loaded.state.coins == coins,"repair preserves quote, destination, other offers and wallet")
 check(not loaded.state.pending.get("ad_rerolled",false),"repair does not consume an ad or rewarded redraw")
 var repaired: Dictionary = loaded.state.pending.duplicate(true)
 check(not loaded.ensure_opening_water_offer() and loaded.state.pending == repaired,"repair is idempotent across refresh/reopen")
 loaded.begin_draft("-1,0")
 check(loaded.state.pending.cards == repaired.cards and loaded.state.pending.cost == repaired.cost,"moving the repaired saved hand retains cards and quote")
 check(loaded.reroll_draft() and loaded.state.pending.cards.has("water"),"a late genuine rewarded-redraw callback cannot remove required Water")
 loaded.state.discoveries = ["rainforest"]
 loaded.state.pending.cards = ["grass","stone","crystal"]
 check(not loaded.ensure_opening_water_offer() and loaded.state.pending.cards == ["grass","stone","crystal"],"normal later drafts are unchanged after a discovery")
 m = blocked(); m.state.learning = {"dismissed":true}; m.begin_draft("-1,0");m.state.pending.cards=["grass","stone","crystal"]
 check(not m.ensure_opening_water_offer(),"skipping guidance restores ordinary draft choices")
 m = blocked(); m.add_tile(Vector2i(-1,0),"grass");m.add_tile(Vector2i(0,-1),"grass");m.state.expansions += 2
 check(Learn.current(m).action == "pulse" and Learn.current(m).body.contains("100"),"a surrounded Oak gets a Rain route rather than an impossible cloud instruction")
 var h = preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://opening-water-ui.json"
 root.add_child(h);await process_frame;h.set_process(false)
 h.model=blocked();h.services.model=h.model;h.model.begin_draft("-1,0");h.model.state.pending.cards=["grass","stone","crystal"]
 saved=h.model.state.pending.duplicate(true);coins=h.model.state.coins
 h.start_play();h.modal.hide();h.refresh();h.draft();await process_frame
 check(h.draft_cards[h.draft_selection].text == "Water" and h.confirm_card.text == "Place Water","reopening an old hand visibly selects the required Water card")
 check(not is_instance_valid(h.draft_hand.reroll) and h.draft_hand.hint.text.contains("nourish the Oak"),"correct placement is explained without an ad redraw button")
 check(h.store.load_state().pending.cards.has("water"),"repaired UI offer persists through real SaveStore")
 h.confirm_card.pressed.emit();await process_frame
 check(h.model.state.pending.is_empty() and h.model.state.tiles["-1,0"].type == "water" and h.model.state.tiles["2,1"].type == "water","confirm adds the neighbor while retaining the first pond")
 check(h.model.state.coins == coins-int(saved.cost) and Learn.current(h.model).action == "inspect","one saved quote is charged and the objective advances immediately")
 for second in range(4):h.model.tick(1)
 check(not h.model.state.discoveries.is_empty() and h.store.save_state(h.model.state),"ordinary simulation reaches the first discovery and saves without fabricated progress")
 h.model=blocked();h.services.model=h.model;h.model.begin_draft("2,0");h.draft();await process_frame
 check(h.draft_hand.hint.text.contains("too far"),"remote Water choice explicitly explains why it will not satisfy the Oak")
 var show_button: Button
 for action in h.modal_box.find_children("*","Button",true,false):
  if action.text == "Show Water plots beside the Oak": show_button = action
 check(show_button != null,"wrong destination has a free route back to the highlighted valid plots")
 show_button.pressed.emit();await process_frame
 check(not h.modal.visible and h.selected == "0,0" and h.model.state.pending.cards.has("water"),"show valid plots keeps the pending Water hand and highlights the actual Oak")
 h.queue_free();h=null;await process_frame;await create_timer(0.2).timeout
 print("OPENING WATER RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
