extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Quest = preload("res://scripts/Expedition.gd")
class Bridge extends RefCounted:
 var shown := 0
 var context := ""
 func pendingCrash() -> String:return ""
 func pendingRewards() -> String:return "[]"
 func showInterstitialAt(kind: String) -> void:shown+=1;context=kind
 func initializeServices() -> void:pass
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+title)
func button(node: Node, text: String) -> Button:
 for action in node.find_children("*","Button",true,false):
  if action.text==text:return action
 return null
func callback(h, name: String, token: String) -> void:
 h.services._ad_lifecycle(JSON.stringify({"event":name,"kind":"interstitial","placement":token,"context":h.services.bridge.context}))
func finish(h, token: String) -> void:
 callback(h,"show_requested",token);callback(h,"impression",token);callback(h,"dismissed",token)
func ready(h) -> void:
 h.services.active_seconds+=181;h.services.clock_override+=181;h.services.interstitial_ready=true;h.presentation.advance(10);h.reveal_queue.clear()
func solve(s: Dictionary) -> void:
 for index in [3,4,5]:Quest.place(s,index,"water")
 for index in [1,7]:Quest.place(s,index,"flowers")
 for season in range(3):Quest.advance(s)
func _init() -> void:call_deferred("run")
func run() -> void:
 var h=preload("res://scenes/Main.tscn").instantiate();h.show_menu_on_launch=false;h.store.path="user://ads-integration.json";root.add_child(h);await process_frame;h.set_process(false)
 h.model=Model.new();h.model.state.discoveries=["rainforest"];h.model.state.learning={"completed":true};h.model.state.settings.tutorial_seen=true;h.model.state.chapter=3;h.model.state.chapter_rewards=[1,2]
 for entry in [[Vector2i(-1,0),"water"],[Vector2i(-1,1),"water"],[Vector2i(1,1),"workbench"],[Vector2i(2,1),"windmill"],[Vector2i(1,2),"forest"],[Vector2i(0,2),"water"],[Vector2i(2,2),"glacier"]]:h.model.add_tile(entry[0],entry[1])
 h.model.state.tiles["0,0"].dna.moisture=75;h.model.state.tiles["1,2"].dna.moisture=75;h.model.state.expansions=h.model.state.tiles.size()-4
 h.services.model=h.model;h.services.bridge=Bridge.new();h.services.cadence.path="user://ads-integration-cadence-%d.json" % Time.get_ticks_usec();h.services.clock_override=10000;h.services.begin_session();h.services.active_seconds=400;h.services.interstitial_ready=true
 h.start_play();h.modal.hide();h.refresh();h.presentation.advance(10);h.reveal_queue.clear()
 h.store.path="user://missing-ads-integration/save.json";h.habitat_ui.claim(h,"shaded_pond")
 check(not h.services.opportunities.has("habitat") and h.services.bridge.shown==0,"a failed habitat save cannot create a monetizable result")
 h.store.path="user://ads-integration.json";h.habitat_ui.claim(h,"shaded_pond");h.presentation.advance(10);h.reveal_queue.clear()
 var earned: Dictionary=h.model.state.duplicate(true)
 check(h.modal_screen=="restoration_moment" and h.services.opportunities.has("habitat"),"a durable restoration creates its real result placement")
 button(h.modal_box,"Enjoy my island").pressed.emit()
 check(h.services.bridge.shown==1 and h.services.bridge.context=="habitat" and not h.modal.visible,"actual Continue button automatically dispatches the habitat ad")
 callback(h,"show_requested","habitat-1");var time:float=h.model.state.time;h._process(0.5)
 check(h.model.state.time==time,"full-screen ads freeze game simulation even when the OS does not pause the activity")
 callback(h,"impression","habitat-1");callback(h,"dismissed","habitat-1")
 check(h.model.state==earned,"ad presentation never spends or rolls back the earned restoration")
 h._process(0.5);check(h.model.state.time>time,"ordinary play resumes after dismissal")
 h.services.offer_break("chapter","menu-fixture");h.campaign_ui.pack(h);button(h.modal_box,"Back to island").pressed.emit()
 check(h.services.bridge.shown==1,"closing the Pack cannot trigger an automatic ad")
 h.model.state.chapter_rewards.append(3);h.model.state.chapter=4;h.persist()
 check(h.services.chapter_result==3,"a newly saved chapter schedules a celebration rather than an immediate ad")
 ready(h);h.ad_break_ui.chapter(h);h.presentation.advance(10);button(h.modal_box,"Continue my island").pressed.emit()
 check(h.services.bridge.shown==2 and h.services.bridge.context=="chapter","chapter Continue is wired to its distinct automatic placement")
 finish(h,"chapter-3")
 h.model.state.expeditions={Quest.ID:Quest.fresh()};solve(h.model.state.expeditions[Quest.ID]);h.model.state.expeditions[Quest.ID].completed=true
 h.expedition_ui.begin(h,Quest.ID,true,true);ready(h);solve(h.expedition_ui.record(h));h.expedition_ui.complete(h)
 var sequence:int=h.services.break_sequence;h.expedition_ui.complete(h)
 check(h.services.opportunities.has("expedition_replay") and h.services.break_sequence==sequence,"a completed fresh replay offers one break; reopening/completing again cannot duplicate it")
 h.expedition_ui.leave(h)
 check(h.services.bridge.shown==3 and h.services.bridge.context=="expedition_replay","returning from a completed replay can monetize without extra gameplay rewards")
 finish(h,"replay-1");h.expedition_ui.leave(h)
 check(h.services.bridge.shown==3,"returning twice from the same completed attempt cannot show another ad")
 h.expedition_ui.begin(h,Quest.ID,true,true,"swift");ready(h);solve(h.expedition_ui.record(h));h.expedition_ui.complete(h)
 check(h.services.opportunities.has("mastery"),"a saved authored challenge completion has its own result placement")
 h.expedition_ui.leave(h)
 check(h.services.bridge.shown==4 and h.services.bridge.context=="mastery","challenge result return reaches the automatic mastery placement")
 finish(h,"mastery-1")
 ready(h);h.model.state.chapter_rewards.append(4);h.model.state.chapter=5;h.persist();h.ad_break_ui.chapter(h);h.presentation.advance(10)
 button(h.modal_box,"×").pressed.emit()
 check(h.services.bridge.shown==5 and h.services.bridge.context=="chapter","the result Close button follows the same placement rules as Continue")
 finish(h,"chapter-4");h.campaign_ui.pack(h);button(h.modal_box,"×").pressed.emit()
 check(h.services.bridge.shown==5,"ordinary menu Close remains ad-free")
 ready(h);h.model.state.chapter_rewards.append(5);h.model.state.chapter=5;h.persist();h.ad_break_ui.chapter(h);h.presentation.advance(10)
 h._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
 check(h.services.bridge.shown==6 and h.services.bridge.context=="chapter","Android Back from a completed result follows the same placement rules")
 finish(h,"chapter-5");h.campaign_ui.pack(h);h._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
 check(h.services.bridge.shown==6 and not h.modal.visible,"Android Back from an ordinary menu stays ad-free")
 check(h.store.valid(h.model.state),"world, receipts and mastery stay saveable through all placements")
 h.model=Model.new();h.services.model=h.model;h.model.state.learning={"completed":true};h.model.state.settings.tutorial_seen=true;h.model.state.chapter=3;h.model.state.chapter_rewards=[1,2];h.model.state.habitat_projects=["shaded_pond"];h.model.state.discoveries=["rainforest"]
 for entry in [[Vector2i(2,1),"water"],[Vector2i(3,1),"grass"],[Vector2i(4,1),"forest"],[Vector2i(4,2),"fiber"],[Vector2i(5,2),"water"],[Vector2i(5,3),"grass"],[Vector2i(4,3),"grass"],[Vector2i(2,2),"grass"]]:h.model.add_tile(entry[0],entry[1])
 for at in ["4,1","4,2"]:h.model.state.tiles[at].dna.moisture=75;h.model.state.tiles[at].dna.fertility=80
 h.model.state.expansions=h.model.state.tiles.size()-4
 var river=preload("res://scripts/LivingCorridors.gd");river.choose_branch(h.model,"wetland");river.set_source(h.model,"2,1");river.set_route(h.model,"grove",["2,1","3,1","4,1"]);river.set_route(h.model,"garden",["2,1","3,1","4,1","4,2"]);river.allocate(h.model,"grove",2);river.allocate(h.model,"garden",1);river.set_seedbed(h.model,"5,3")
 h.services.clock_override+=1801;h.services.active_seconds+=1801;h.services.interstitial_ready=true
 for season in range(10):h.corridor_ui.observe(h)
 check(river.earned(h.model) and h.services.bridge.shown==6,"ordinary observed seasons never force an ad during the river lesson or its intermediate moments")
 h.presentation.advance(10);h.reveal_queue.clear();h.corridor_ui.cancel(h)
 check(h.services.bridge.shown==7 and h.services.bridge.context=="river","closing the genuinely restored River reaches its dedicated result placement")
 finish(h,"river-1")
 h.queue_free();h=null;await process_frame
 print("ADS INTEGRATION RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
