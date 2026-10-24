extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Store = preload("res://scripts/SaveStore.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+text)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 var model = Model.new()
 var hub = preload("res://scripts/ServiceHub.gd").new()
 hub.model = model
 hub.save_path = "user://service-tests.json"
 hub.log_path = "user://service-diagnostics.jsonl"
 root.add_child(hub)
 var prior := FileAccess.get_file_as_string(hub.log_path) if FileAccess.file_exists(hub.log_path) else ""
 hub.event("privacy_test")
 var after := FileAccess.get_file_as_string(hub.log_path) if FileAccess.file_exists(hub.log_path) else ""
 check(after == prior,"disabled diagnostics never record an event")
 check(not hub.request_reward("coins"),"unavailable provider cannot grant a reward")
 var initial: int = model.state.coins
 hub._ad_rewarded("unknown")
 check(model.state.coins == initial,"unsolicited reward rejected")
 var id := "0123456789abcdef0123456789abcdef"
 model.state.reward_requests[id] = "coins"
 hub._ad_rewarded(id)
 check(model.state.coins == initial+25,"earned provider callback grants configured reward")
 hub._ad_rewarded(id)
 check(model.state.coins == initial+25,"duplicate reward callback cannot replay")
 check(model.state.transactions.has("ad:"+id),"reward receipt persisted in authoritative ledger")
 hub._purchase_completed("unknown","unit-receipt")
 check(model.state.entitlements.is_empty(),"unknown product cannot grant entitlement")
 hub._purchase_completed("pocket_biome_remove_ads_test","unit-receipt")
 check(model.state.entitlements.has("remove_ads"),"verified purchase callback grants known entitlement")
 var receipt_count: int = model.state.transactions.size()
 hub._purchase_completed("pocket_biome_remove_ads_test","unit-receipt")
 check(model.state.transactions.size() == receipt_count,"restored receipt idempotent")
 hub._purchase_completed("pocket_biome_founders_test","unit-founder-receipt")
 check(model.state.entitlements.has("founders") and model.state.entitlements.has("remove_ads"),"founder bundle entitlements")
 var store = Store.new()
 store.path = hub.save_path
 check(store.load_state().entitlements.has("founders"),"entitlements survive save restoration")
 model.state.reward_limits = {"day":int(Time.get_unix_time_from_system()/86400),"count":3}
 check(not hub.reward_available(),"daily optional reward cap")
 check(not hub.maybe_interstitial(),"offline game never requests forced ad")
 model.state.settings.analytics = true
 for i in range(140): hub.event("unit_test",{"n":i})
 check(hub.telemetry.rows().size() == 128,"diagnostics queue is bounded")
 model.state.settings.analytics = false
 var lines: int = hub.telemetry.rows().size()
 hub.event("opted_out")
 check(hub.telemetry.rows().size() == lines,"opt-out prevents event recording")
 model.state.reward_limits.count = 0
 model.state.event.until = model.state.time+30
 check(not hub.reward_available(),"rewarded ads cannot interrupt active Dusk")
 # A receipt must remain retryable when local persistence fails.
 model.state.event.until = 0
 model.state.reward_limits.count = 0
 var failed_id := "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
 model.state.reward_requests[failed_id] = {"kind":"coins"}
 var before_coins: int = model.state.coins
 hub.save_path = "res://missing-parent/reward.json"
 hub._ad_rewarded(failed_id)
 check(model.state.coins == before_coins and model.state.reward_requests.has(failed_id),"failed reward save rolls back currency and keeps durable request retryable")
 check(not model.state.transactions.has("ad:"+failed_id),"failed reward save cannot commit a receipt in memory")
 hub.save_path = "user://service-tests.json"
 hub._ad_rewarded(failed_id)
 check(model.state.coins == before_coins+25 and not model.state.reward_requests.has(failed_id),"retry commits previously earned reward once")
 model.state.reward_limits.count = 0
 model.begin_draft("-1,0")
 var quote: int = model.state.pending.cost
 var reroll_id := "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
 model.state.reward_requests[reroll_id] = {"kind":"reroll","at":"-1,0","expansions":model.state.expansions}
 hub._ad_rewarded(reroll_id)
 check(model.state.pending.get("ad_rerolled",false) and model.state.pending.cost == quote,"earned reroll preserves quoted expansion price")
 var frozen: Array = model.state.pending.cards.duplicate()
 hub._ad_rewarded(reroll_id)
 check(model.state.pending.cards == frozen,"duplicate rewarded reroll does not change the draft")
 var hint_id := "cccccccccccccccccccccccccccccccc"
 model.state.reward_requests[hint_id] = {"kind":"hint","discovery":"rainforest"}
 hub._ad_rewarded(hint_id)
 check(model.state.hints.get("rainforest",0) == 2,"verified optional hint unlocks detailed conditions")
 check(store.load_state().hints.get("rainforest",0) == 2,"hint survives save restoration")
 hub.save_path = "res://missing-parent/purchase.json"
 hub._purchase_completed("pocket_biome_moon_theme_test","retry-receipt")
 check(not model.state.entitlements.has("moon"),"failed purchase save remains retryable by store restore")
 hub.save_path = "user://service-tests.json"
 hub._purchase_completed("pocket_biome_moon_theme_test","retry-receipt")
 check(model.state.entitlements.has("moon"),"purchase restore retries after local save recovery")
 hub.queue_free()
 await process_frame
 print("SERVICES RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
