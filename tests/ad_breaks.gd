extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
class Bridge extends RefCounted:
 var shown := 0
 var retried := 0
 var initialized := 0
 var acknowledged := []
 func pendingCrash() -> String:return ""
 func pendingRewards() -> String:return "[]"
 func initializeServices() -> void:initialized+=1
 func showInterstitial() -> void:shown+=1
 func retryAds() -> void:retried+=1
 func acknowledgeReward(id: String) -> void:acknowledged.append(id)
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+title)
func _init() -> void:call_deferred("run")
func run() -> void:
 var m=Model.new();m.state.learning={"completed":true};m.state.discoveries=["rainforest"];m.state.chapter_rewards=[1,2];m.state.chapter=3;m.state.time=1000
 var hub=preload("res://scripts/ServiceHub.gd").new();hub.model=m;hub.save_path="user://ad-break-tests.json";root.add_child(hub)
 var bridge=Bridge.new();hub.bridge=bridge;hub.begin_session();hub.interstitial_ready=true;m.state.time=1480
 check(not hub.maybe_interstitial() and bridge.shown==0,"restored historical chapters never count as a new ad break")
 m.state.chapter_rewards.append(3);m.state.chapter=4
 m.state.learning={};m.state.chapter_rewards=[1,3];hub.restoration_break=true
 check(not hub.maybe_interstitial(),"unfinished opening guidance also blocks interstitials centrally")
 m.state.learning={"completed":true};m.state.chapter_rewards=[1,2,3];hub.restoration_break=false
 m.state.reward_requests["ffffffffffffffffffffffffffffffff"]={"kind":"pulse"}
 check(not hub.maybe_interstitial(),"pending rewarded presentation prevents an overlapping interstitial")
 m.state.reward_requests.clear();hub.fullscreen_ad=true;hub.ad_ready=true
 check(not hub.request_reward("pulse"),"fullscreen presentation cannot start a second reward ad")
 hub.fullscreen_ad=false
 check(hub.maybe_interstitial() and bridge.shown==1 and hub.interstitial_count==1,"a newly earned chapter can dispatch at a natural break after eight active minutes")
 check(hub.ad_metrics.counts.get("interstitial_impression",0)==0,"dispatch is never counted as an actual impression")
 hub.interstitial_ready=true;hub.restoration_break=true;m.state.time=2079
 check(not hub.maybe_interstitial(),"interstitial cooldown remains ten active minutes")
 m.state.time=2080
 preload("res://scripts/JourneyLessons.gd").start(m,"fusion")
 check(not hub.maybe_interstitial(),"an active advanced lesson blocks interstitials centrally")
 preload("res://scripts/JourneyLessons.gd").skip(m)
 m.state.pending={"at":"-1,0"}
 check(not hub.maybe_interstitial(),"an unfinished land choice cannot be interrupted")
 m.state.pending={};m.state.event.until=m.state.time+30
 check(not hub.maybe_interstitial(),"a weather event cannot be interrupted")
 m.state.event.until=0;m.state.entitlements=["remove_ads"]
 check(not hub.maybe_interstitial(),"remove-ads entitlement prevents interstitial dispatch")
 m.state.entitlements=[]
 check(hub.maybe_interstitial() and bridge.shown==2,"a later eligible restoration break dispatches the second session ad")
 hub.interstitial_ready=true;hub.restoration_break=true;m.state.time+=600
 check(not hub.maybe_interstitial() and bridge.shown==2,"two-per-session cap holds across repeated completion breaks")
 hub._ad_lifecycle('{"event":"show_requested","kind":"interstitial","placement":"test:1"}')
 check(hub.fullscreen_ad,"native show request blocks world input until dismissal/failure")
 hub._ad_lifecycle('{"event":"show_failed","kind":"interstitial","placement":"test:1"}')
 check(not hub.fullscreen_ad,"failed native presentation releases input immediately")
 hub._ad_lifecycle('{"event":"show_requested","kind":"rewarded","placement":"test:2"}')
 hub._ad_lifecycle('{"event":"dismissed","kind":"rewarded","placement":"test:2"}')
 check(not hub.fullscreen_ad,"rewarded dismissal releases input without manufacturing a reward")
 hub._ad_lifecycle('{"event":"no_fill","kind":"rewarded","placement":"test:3"}')
 var coins: int=m.state.coins
 hub.prepare_ad_services();check(bridge.initialized==1,"quiet initialization is once-only")
 m.state.time+=59;hub.prepare_ad_services();check(bridge.retried==0,"no-fill recovery never spins per frame")
 m.state.time+=1
 for frame in range(10):hub.prepare_ad_services()
 check(bridge.retried==1 and m.state.coins==coins,"quiet retry is throttled and cannot grant rewards or spend gameplay currency")
 preload("res://scripts/JourneyLessons.gd").start(m,"fusion");m.state.time+=60;hub.prepare_ad_services()
 check(bridge.retried==1,"retry preparation also waits while an advanced lesson is active")
 preload("res://scripts/JourneyLessons.gd").skip(m);hub.prepare_ad_services();check(bridge.retried==2,"retries can resume safely after guidance")
 var reward=Model.new();reward.add_tile(Vector2i(1,1),"workbench");reward.add_tile(Vector2i(2,1),"windmill");reward.state.expansions=reward.state.tiles.size()-4
 reward.state.event.targets=["1,1","2,1"];reward.state.event.applied={"1,1":0,"2,1":0};reward.state.event.until=30.0
 var id: String="dddddddddddddddddddddddddddddddd";reward.state.reward_requests[id]={"kind":"coins"};hub.model=reward
 var before: int=reward.state.coins;hub._ad_rewarded(id)
 check(reward.state.coins==before+25 and reward.state.transactions.has("ad:"+id),"earned durable reward survives an event starting while the ad is on screen")
 hub._ad_rewarded(id);check(reward.state.coins==before+25,"earned reward during an event remains idempotent")
 var failed: String="eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";reward.state.reward_requests[failed]={"kind":"coins"};hub._ad_failed(failed,"test no-fill")
 check(not reward.state.reward_requests.has(failed) and reward.state.coins==before+25,"failed optional presentation releases its request without changing currency")
 reward.state.event.until=0
 check(reward.harvest("0,0"),"core offline play remains usable after provider failure")
 var report={"passed":failures==0,"checks":checks,"scope":"Fake-provider dispatch, retry and reward-ledger qualification; not real SDK delivery, consent, billing or revenue proof."}
 var file=FileAccess.open("res://artifacts/ad-break-qualification.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 hub.queue_free();await process_frame
 print("AD BREAKS RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
