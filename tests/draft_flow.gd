extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, reason: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+reason)
func _init() -> void: call_deferred("run")
func settle() -> void:
 for frame in range(5): await process_frame
func run() -> void:
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.store.path = "user://draft-hand-test.json"; h.show_menu_on_launch = false
 root.add_child(h); h.set_process(false)
 h.model = preload("res://scripts/WorldModel.gd").new()
 h.refresh(); h.modal.hide(); h.frame_world()
 var camera := {"zoom":h.zoom_level,"pan":h.pan}
 h.model.begin_draft("-1,0")
 var pending: Dictionary = h.model.state.pending.duplicate(true)
 var coins: int = h.model.state.coins
 h.draft(); await settle()
 check(h.modal_screen == "draft" and h.draft_cards.size() == 3,"three saved offers form a single hand")
 check(h.draft_cards[1].chosen and not h.bottom.visible,"middle offer starts selected and dock makes room")
 check(h.confirm_card.text == "Place "+str(pending.cards[1]).capitalize(),"primary action names the selected terrain")
 check(h.draft_hand.quote.text == "%d Coins" % pending.cost,"hand displays the saved quote")
 h.model.state.settings.reduced_motion = true
 h.draft_cards[0].pressed.emit()
 check(h.draft_selection == 0 and h.draft_cards[0].chosen,"reduced-motion selection remains functional")
 check(not h.draft_cards[0].has_meta("response_tween"),"reduced motion does not create a card flight tween")
 check(h.model.state.pending == pending and h.model.state.coins == coins,"selection changes no offer, coordinate, quote or balance")
 h.persist(); h.modal.hide(); await settle()
 check(h.bottom.visible and not h.modal_scrim.visible,"Later/back restores dock and removes the shade")
 check(is_equal_approx(h.zoom_level,camera.zoom) and h.pan.is_equal_approx(camera.pan),"dismissal restores the previous gameplay camera")
 check(h.store.load_state().pending == pending,"saved offers and quote survive a real store round trip")
 h.draft(); await settle()
 check(h.draft_cards[0].chosen,"reopening the same hand retains selection")
 h.model.state.coins = 0; h.refresh()
 check(h.confirm_card.disabled and h.draft_hand.hint.text.begins_with("Need"),"insufficient funds disable placement and explain the shortage")
 h.confirm_card.pressed.emit()
 check(h.model.state.pending == pending and not h.model.state.tiles.has(pending.at),"even a forced signal cannot bypass model affordability checks")
 h.model.state.coins = coins; h.refresh()
 check(not h.confirm_card.disabled,"earning sufficient coins enables the existing quoted action")
 h.draft_hand.info.pressed.emit(); await settle()
 check(h.modal_title.text.begins_with(str(pending.cards[0]).capitalize()),"Info describes the selected offer")
 check(h.model.state.pending == pending and h.model.state.coins == coins,"reading detailed DNA and local effects spends nothing")
 var rerolled: bool = h.model.reroll_draft()
 h.services.changed.emit(); await settle()
 check(rerolled and h.modal_screen == "draft" and h.draft_cards[0].text == str(h.model.state.pending.cards[0]).capitalize(),"an asynchronous rewarded redraw from Info replaces stale card details with the actual new offers")
 check(h.model.state.pending.cost == pending.cost and h.store.load_state().pending == h.model.state.pending,"redraw keeps the quote and persists the replacement offers")
 pending = h.model.state.pending.duplicate(true)
 h.draft(); await settle()
 h.draft_cards[0].pressed.emit()
 h.confirm_card.pressed.emit(); await settle()
 check(h.model.state.pending.is_empty() and h.model.state.tiles[pending.at].type == pending.cards[0],"confirmation places precisely the selected offer at the saved coordinate")
 var settled_coins: int = h.model.state.coins
 h.draft_hand.confirm()
 check(h.model.state.coins == settled_coins,"repeated confirmation cannot debit again")
 check(h.store.load_state().tiles.has(pending.at),"placed biome persists through the real SaveStore")
 h.campaign_ui.settings(h); await settle()
 check(h.modal_scrim.material == null and h.bottom.visible,"the draft shade and hidden dock do not leak into other screens")
 h.queue_free(); await settle()
 print("DRAFT FLOW RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
