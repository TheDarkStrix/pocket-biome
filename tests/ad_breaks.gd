extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Hub = preload("res://scripts/ServiceHub.gd")
class Bridge extends RefCounted:
 var shown := 0
 var retried := 0
 var initialized := 0
 var context := ""
 var acknowledged := []
 func pendingCrash() -> String:return ""
 func pendingRewards() -> String:return "[]"
 func initializeServices() -> void:initialized+=1
 func showInterstitialAt(kind: String) -> void:shown+=1;context=kind
 func showInterstitial() -> void:shown+=1
 func retryAds() -> void:retried+=1
 func acknowledgeReward(id: String) -> void:acknowledged.append(id)
var checks := 0
var failures := 0
var sequence := 0
func check(ok: bool, title: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+title)
func event(h, name: String, token: String, kind: String = "interstitial", context: String = "chapter") -> void:
 h._ad_lifecycle(JSON.stringify({"event":name,"kind":kind,"placement":token,"context":context}))
func fresh():
 sequence+=1
 var h=Hub.new();h.model=Model.new();h.model.state.learning={"completed":true};h.model.state.discoveries=["rainforest"];h.model.state.chapter_rewards=[1,2];h.model.state.chapter=3
 h.save_path="user://ads-policy-%d.json" % sequence;h.cadence.path="user://ads-cadence-test-%d.json" % Time.get_ticks_usec();h.clock_override=10000.0
 root.add_child(h);h.bridge=Bridge.new();h.begin_session();h.interstitial_ready=true
 return h
func ready(h, seconds: float = 180) -> void:
 h.active_seconds+=seconds;h.clock_override+=seconds;h.interstitial_ready=true
func shown(h, token: String) -> void:
 event(h,"show_requested",token);event(h,"impression",token);event(h,"dismissed",token)
func _init() -> void:call_deferred("run")
func run() -> void:
 var h=fresh()
 h.model.state.time=99999;h.offer_break("chapter","new-1")
 check(not h.maybe_interstitial("chapter") and h.bridge.shown==0,"old world time cannot skip the first-play guard")
 ready(h,179);h.offer_break("chapter","new-2");check(not h.maybe_interstitial("chapter"),"automatic ads wait at least three active minutes")
 ready(h,1);check(not h.maybe_interstitial("chapter"),"a skipped result cannot pop an ad later")
 h.offer_break("chapter","new-3")
 check(not h.maybe_interstitial() and h.bridge.shown==0,"ordinary menu closure is never a placement")
 check(h.maybe_interstitial("chapter") and h.bridge.context=="chapter" and h.dispatch_pending,"a fresh result Continue dispatches an automatic ad without an opt-in reward")
 check(h.ad_metrics.counts.get("interstitial_impression",0)==0 and h.cadence.impressions.is_empty(),"dispatch does not count as an impression or consume the rolling exposure quota")
 event(h,"show_requested","i1");check(h.fullscreen_ad and not h.dispatch_pending,"native presentation owns the fullscreen lock")
 event(h,"impression","i1");event(h,"impression","i1");check(h.cadence.impressions.size()==1,"duplicate actual impression counts once")
 event(h,"dismissed","i1");check(not h.fullscreen_ad and h.cadence.last_fullscreen==h.wall_time(),"dismissal releases input and starts spacing from the ad's end")
 ready(h,179);h.offer_break("habitat","pond");check(not h.maybe_interstitial("habitat"),"spacing applies across different automatic placements")
 ready(h,1);h.offer_break("habitat","garden");check(h.maybe_interstitial("habitat"),"a new eligible habitat result can monetize after three minutes")
 shown(h,"i2")
 check(not h.offer_break("habitat","garden"),"reopening a saved result cannot register another opportunity")
 h.offer_break("chapter","c4");ready(h,91);check(not h.maybe_interstitial("chapter"),"expired results cannot create a delayed surprise")
 ready(h);h.interstitial_ready=false;h.offer_break("expedition","one");check(not h.maybe_interstitial("expedition"),"no-fill always continues gameplay without waiting")
 h.interstitial_ready=true;check(not h.maybe_interstitial("expedition"),"a later load never presents the missed ad automatically")
 h.offer_break("chapter","blocked-lesson");h.model.state.lessons={"active":"fusion","skipped":[],"completed":[]}
 check(not h.maybe_interstitial("chapter"),"advanced lessons are protected centrally")
 h.model.state.lessons.active="";h.model.state.chapter_rewards=[];h.model.state.learning={};h.offer_break("chapter","opening")
 check(not h.maybe_interstitial("chapter"),"opening guidance is protected centrally")
 h.model.state.learning={"completed":true};h.model.state.pending={"at":"-1,0"};h.offer_break("chapter","draft")
 check(not h.maybe_interstitial("chapter"),"saved drafts block automatic ads")
 h.model.state.pending={};h.model.state.event.until=30;h.offer_break("chapter","weather")
 check(not h.maybe_interstitial("chapter"),"active weather blocks automatic ads")
 h.model.state.event.until=0;h.model.state.entitlements=["remove_ads"];h.offer_break("chapter","paid")
 check(not h.maybe_interstitial("chapter"),"remove-ads purchases suppress all automatic placements")
 h.model.state.entitlements=[];h.model.state.reward_requests["ffffffffffffffffffffffffffffffff"]={"kind":"pulse"};h.offer_break("chapter","reward-pending")
 check(not h.maybe_interstitial("chapter"),"a pending reward cannot overlap a forced ad")
 h.model.state.reward_requests.clear();h.fullscreen_ad=true;h.ad_ready=true
 check(not h.request_reward("pulse"),"an active fullscreen ad cannot start another reward")
 h.fullscreen_ad=false;event(h,"show_requested","r1","rewarded");event(h,"dismissed","r1","rewarded")
 ready(h,179);h.offer_break("chapter","after-reward");check(not h.maybe_interstitial("chapter"),"rewarded ads also protect the player from a back-to-back automatic ad")
 ready(h,1);h.offer_break("chapter","race");check(h.maybe_interstitial("chapter"),"next genuine result can dispatch after the rewarded spacing interval")
 var before: int=h.cadence.impressions.size();event(h,"show_failed","fail1")
 check(not h.fullscreen_ad and not h.dispatch_pending and h.cadence.impressions.size()==before,"a show failure releases locks and never counts as exposure")
 h.interstitial_ready=true;h.offer_break("chapter","retry-early");check(not h.maybe_interstitial("chapter"),"failed presentations have a short retry backoff")
 ready(h,30);h.offer_break("chapter","retry-later");check(h.maybe_interstitial("chapter"),"failure does not waste a whole three-minute impression cooldown")
 event(h,"show_failed","fail2")
 var m=h.model
 h.prepare_ad_services();check(h.bridge.initialized==1,"provider initialization stays once-only")
 h.active_seconds+=59;h.prepare_ad_services();check(h.bridge.retried==0,"quiet recovery never spins per frame")
 h.active_seconds+=1
 for frame in range(10):h.prepare_ad_services()
 check(h.bridge.retried==1,"quiet retries are limited to once per active minute")
 var returning=fresh();returning.cadence.path=h.cadence.path;returning.clock_override=h.clock_override+181;returning.cadence.load_history(returning.wall_time());returning.active_seconds=59;returning.offer_break("chapter","return-early")
 check(not returning.maybe_interstitial("chapter"),"returning players still receive a full first active minute before any forced placement")
 returning.active_seconds=60;returning.offer_break("chapter","return-ready")
 check(returning.maybe_interstitial("chapter"),"known returning players can monetize a genuine result after one active minute")
 event(returning,"show_failed","return-fail")
 var side=fresh();ready(side);side.model.state.lessons={"active":"fusion","skipped":[],"completed":[]}
 side.prepare_ad_services();check(side.bridge.initialized==0,"active home teaching suppresses unrelated quiet consent/preparation")
 side.prepare_ad_services("mastery");check(side.bridge.initialized==1,"a completed side activity can prepare ads without requiring the home lesson to be abandoned")
 side.offer_break("mastery","side-attempt");check(side.maybe_interstitial("mastery"),"an unfinished home lesson cannot make all completed side activities permanently ad-free")
 event(side,"show_failed","side-fail","interstitial","mastery")
 # Saved app-wide history survives a different world/app instance.
 var capped=fresh();ready(capped)
 for index in range(6):
  if index>0:ready(capped)
  capped.offer_break("expedition_replay","attempt-"+str(index));check(capped.maybe_interstitial("expedition_replay"),"eligible completed attempt earns a rolling-window slot "+str(index));shown(capped,"cap-"+str(index))
 ready(capped);capped.offer_break("mastery","seventh");check(not capped.maybe_interstitial("mastery"),"rolling half-hour cap prevents unlimited replay ads")
 var resumed=fresh();resumed.cadence.path=capped.cadence.path;resumed.clock_override=capped.clock_override;resumed.cadence.load_history(resumed.wall_time());resumed.active_seconds=180;resumed.offer_break("chapter","new-world")
 check(not resumed.maybe_interstitial("chapter"),"restarting or creating a fresh world does not reset the rolling cap")
 resumed.clock_override+=1801;resumed.interstitial_ready=true;resumed.offer_break("chapter","later")
 check(resumed.maybe_interstitial("chapter"),"long sessions regain slots as old impressions age out")
 event(resumed,"show_failed","later-failed")
 var storage=fresh();ready(storage);storage.cadence.path="user://missing-ad-ledger/history.json";event(storage,"impression","disk");ready(storage);storage.offer_break("chapter","disk-result")
 check(not storage.maybe_interstitial("chapter") and storage.model.harvest("0,0"),"cadence write failure blocks more forced ads while ordinary play remains usable")
 var reward=Model.new();reward.add_tile(Vector2i(1,1),"workbench");reward.add_tile(Vector2i(2,1),"windmill");reward.state.expansions=reward.state.tiles.size()-4
 reward.state.event.targets=["1,1","2,1"];reward.state.event.applied={"1,1":0,"2,1":0};reward.state.event.until=30.0
 var id: String="dddddddddddddddddddddddddddddddd";reward.state.reward_requests[id]={"kind":"coins"};h.model=reward
 var coins: int=reward.state.coins;h._ad_rewarded(id);h._ad_rewarded(id)
 check(reward.state.coins==coins+25 and reward.state.transactions.has("ad:"+id),"earned reward survives weather starting during the ad and cannot replay")
 # SDK value is attributed to actual result context, never to dispatch estimates.
 h._ad_lifecycle('{"event":"paid","kind":"interstitial","placement":"paid1","context":"habitat","value_micros":125,"currency":"USD"}')
 check(h.ad_metrics.placements["interstitial:habitat"].paid_micros_by_currency.USD==125,"actual SDK value is grouped by placement and currency")
 var report={"passed":failures==0,"checks":checks,"policy":h.config.ad_policy,"scope":"Fake-provider policy/cadence/reward qualification. Not real SDK fill, revenue, consent or retention evidence."}
 var file=FileAccess.open("res://artifacts/ad-break-qualification.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 for node in [h,capped,resumed,storage,returning,side]:node.queue_free()
 await process_frame
 print("AD BREAKS RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
