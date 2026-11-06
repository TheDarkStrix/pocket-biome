extends SceneTree
const Model=preload("res://scripts/WorldModel.gd")
const River=preload("res://scripts/LivingCorridors.gd")
var checks:=0
var failures:=0
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+message)
func starter():
 var m=Model.new();m.harvest("0,0");m.begin_draft("-1,0");m.place(m.state.pending.cards.find("water"))
 for second in range(4):m.tick(1)
 preload("res://scripts/HabitatProjects.gd").claim(m,"shaded_pond")
 m.state.settings.tutorial_seen=true
 return m
func button(h, title: String) -> Button:
 for action in h.modal_box.find_children("*","Button",true,false):
  if action.text==title:return action
 return null
func _init() -> void:call_deferred("run")
func run() -> void:
 var m=starter();check(River.unlocked(m),"normal Water discovery and first project unlock the river")
 m.begin_draft("2,1");var pending: Dictionary=m.state.pending.duplicate(true)
 var coins: int=m.state.coins
 check(River.choose_branch(m,"wetland") and River.set_source(m,"-1,0"),"approach and spring can be chosen while a land hand is saved")
 check(m.state.pending==pending and m.state.coins==coins,"choosing an approach/source keeps every card, quote and Coin")
 check(River.grove_options(m).is_empty(),"the real first-restoration island has no eligible distant grove")
 m.add_tile(Vector2i(1,1),"forest")
 var state_before:=JSON.stringify(m.state)
 var options: Array=River.grove_options(m)
 check(options.size()==1 and options[0].target=="1,1" and options[0].path==["-1,0","0,0","0,1","1,1"],"reachable grove suggestions use actual natural-land connectivity")
 check(JSON.stringify(m.state)==state_before,"suggesting a river spends and completes nothing")
 check(River.set_route(m,"grove",options[0].path) and River.allocate(m,"grove",2),"route and supply edits work with pending land cards")
 check(River.advance(m) and m.state.pending==pending,"seasons advance without discarding a saved land choice")
 var store=preload("res://scripts/SaveStore.gd").new();store.path="user://river-entry-model.json"
 check(store.save_state(m.state) and store.load_state().pending==pending,"river plus pending hand round-trip as a valid save")
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://river-entry-ui-%d.json" % Time.get_ticks_usec();root.add_child(h);await process_frame;h.set_process(false)
 h.model=starter();h.services.model=h.model;h.model.begin_draft("2,1");pending=h.model.state.pending.duplicate(true);coins=h.model.state.coins
 h.start_play();h.modal.hide();h.refresh();h.corridor_ui.show(h)
 button(h,"Choose Clover's wetland").pressed.emit();await process_frame
 check(h.corridor_ui.mode=="source" and not h.modal.visible,"the actual approach button opens source picking instead of silently doing nothing")
 check(h.corridor_ui.caption.text.contains("blue Water"),"source picking gives an explicit next action")
 h.corridor_ui.append_cell(h,"-1,0");button(h,"Confirm selection").pressed.emit();await process_frame
 check(h.modal_screen=="corridor_setup" and button(h,"Build a Workbench")!=null and button(h,"Use my saved land cards")!=null,"a small real island gets actionable setup instead of an empty impossible planner")
 check(River.record(h.model).source=="-1,0" and h.model.state.pending==pending and h.model.state.coins==coins,"source is genuinely saved and pending supplies remain untouched")
 check(button(h,"Use the Forest in my saved cards")!=null,"setup uses an already-offered Forest before requesting more construction")
 button(h,"Use the Forest in my saved cards").pressed.emit();await process_frame
 check(h.draft_cards[h.draft_selection].text=="Forest","saved Forest assistance selects the real offered card")
 check(h.modal_screen=="draft" and not h.corridor_ui.active() and h.model.state.pending==pending,"setup can resume the exact saved hand")
 h.model.add_tile(Vector2i(1,1),"forest");h.modal.hide();h.corridor_ui.begin(h,"grove");h.apply_layout()
 for frame in range(6):await process_frame
 h.corridor_ui.append_cell(h,"1,1")
 check(h.corridor_ui.draft==["-1,0","0,0","0,1","1,1"] and River.record(h.model).routes.is_empty(),"tapping a highlighted tree builds only a channel preview")
 check(not h.corridor_ui.preview.disabled,"valid visible preview enables its confirmation")
 h.corridor_ui.confirm_route(h);button(h,"Save this route").pressed.emit();await process_frame
 check(River.record(h.model).routes.grove.water==2 and River.delivered(h.model).grove==2,"saved first channel receives the flow disclosed before confirmation")
 check(h.store.load_state().living_corridors.routes.grove.water==2 and h.model.state.pending==pending,"channel and saved hand persist together")
 check(h.model.message.begins_with("River plan saved"),"saving the channel replaces the previous tracing instruction with confirmation")
 h.corridor_ui.commit(h,func():return River.allocate(h.model,"grove",0))
 h.corridor_ui.begin(h,"grove");h.corridor_ui.append_cell(h,"1,1");h.corridor_ui.confirm_route(h);button(h,"Save this route").pressed.emit();await process_frame
 check(River.record(h.model).routes.grove.water==0,"editing a deliberately paused route does not secretly restart it")
 state_before=JSON.stringify(h.model.state)
 var failed: bool=h.corridor_ui.commit(h,func():h.model.state.living_corridors.source="0,0";return false)
 check(not failed and JSON.stringify(h.model.state)==state_before,"failed compound edits roll back atomically")
 var labels: Array=h.modal_box.find_children("*","Label",true,false).map(func(l):return l.text)
 check(" ".join(labels).contains("plan no longer fits"),"rejected edits have feedback inside the visible river panel")
 var path: String=h.store.path;h.store.path="user://missing-river-entry-parent/state.json"
 check(not h.corridor_ui.commit(h,func():return River.allocate(h.model,"grove",1)) and River.record(h.model).routes.grove.water==0,"failed persistence preserves the prior channel")
 labels=h.modal_box.find_children("*","Label",true,false).map(func(l):return l.text)
 check(" ".join(labels).contains("Save failed"),"save failure is visible inside the panel")
 h.store.path=path;h.corridor_ui.begin(h,"grove");h.apply_layout()
 for frame in range(8):await process_frame
 check(h.world_rect().end.y<=h.corridor_ui.bar.position.y,"planner framing reserves room for its toolbar")
 check(h.model.state.pending==pending and h.model.state.coins==coins,"all entry/recovery actions preserve saved cards and balance")
 h.queue_free();h=null;await process_frame;await create_timer(0.2).timeout
 print("RIVER ENTRY RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
