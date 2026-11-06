extends Node
signal changed
var model
var ad_metrics = preload("res://scripts/AdMetrics.gd").new()
var telemetry = preload("res://scripts/Telemetry.gd").new()
var save_path := "user://biome.json"
var session_start := 0.0
var last_interstitial := -1000.0
var interstitial_count := 0
var interstitial_ready := false
var last_ad_chapter := 0
var restoration_break := false
const BREAKS = ["chapter","habitat","river","expedition","expedition_replay","mastery"]
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/services.json"))
var cadence = preload("res://scripts/AdCadence.gd").new()
var active_seconds := 0.0
var clock_override := -1.0
var opportunities := {}
var offered := {}
var break_sequence := 0
var known_chapters: Array = []
var chapter_result := 0
var observed_seed := -1
var failure_until := 0.0
var dispatch_pending := false
var dispatch_started := 0
var pending_context := ""
var opportunity_counts := {}
var blocked_counts := {}
var dispatch_counts := {}
var online_requested := false
var next_ad_retry := 0.0
var fullscreen_ad := false
var expedition_breaks: Array[String] = []
var bridge: Object
var ad_ready := false
var status := "Ad and store services are unavailable on this platform. Core play stays offline."
var products := []
var log_path := "user://diagnostics.jsonl"
const PRODUCTS = {"pocket_biome_remove_ads_test":"remove_ads","pocket_biome_moon_theme_test":"moon","pocket_biome_founders_test":"founders"}
func _ready() -> void:
 add_child(telemetry)
 if Engine.has_singleton("PocketServices"):
  bridge = Engine.get_singleton("PocketServices")
  if bridge.has_signal("ad_lifecycle"): bridge.connect("ad_lifecycle",_ad_lifecycle)
  bridge.connect("ad_ready",_ad_ready)
  bridge.connect("interstitial_ready",func(available): interstitial_ready = available)
  bridge.connect("ad_rewarded",_ad_rewarded)
  bridge.connect("ad_failed",_ad_failed)
  bridge.connect("purchase_completed",_purchase_completed)
  bridge.connect("purchase_failed",func(reason): event("purchase_failed",{"reason":reason.left(160)}))
  bridge.connect("service_error",_service_error)
  bridge.connect("products_updated",_products_updated)
  status = "Sandbox store and test advertisements. Rewarded extras and purchases are optional."
func event(name: String, data: Dictionary = {}) -> void:
 telemetry.model = model
 telemetry.path = log_path
 telemetry.record(name,data)

func begin_session() -> void:
 session_start = model.state.time
 last_ad_chapter = model.state.chapter_rewards.size()
 observed_seed = int(model.state.seed)
 known_chapters = model.state.chapter_rewards.duplicate()
 cadence.load_history(wall_time())
 telemetry.model = model
 if bridge != null:
  var crash: String = bridge.pendingCrash()
  if crash != "" and model.state.settings.analytics:
   var parsed = JSON.parse_string(crash)
   if parsed is Dictionary and telemetry.record("crash",parsed): bridge.clearCrash()
  var pending = JSON.parse_string(bridge.pendingRewards())
  if pending is Array:
   for id in pending: _ad_rewarded(id)
   for id in model.state.reward_requests.keys():
    if not pending.has(id): model.state.reward_requests.erase(id)
 event("session_started")

func flush_telemetry() -> void:
 telemetry.model = model
 telemetry.flush()

func wall_time() -> float:
 return Time.get_unix_time_from_system() if clock_override < 0 else clock_override
func advance_play_time(delta: float) -> void:
 if dispatch_pending and Time.get_ticks_msec()-dispatch_started > 2500:
  dispatch_pending = false; failure_until = active_seconds+config.ad_policy.failure_backoff_seconds
  event("interstitial_dispatch_timeout")
 if not fullscreen_ad: active_seconds += clampf(delta,0,1)
func observe_saved_progress() -> void:
 if observed_seed != int(model.state.seed):
  observed_seed = int(model.state.seed); known_chapters = model.state.chapter_rewards.duplicate(); chapter_result = 0; opportunities.clear(); return
 for chapter in model.state.chapter_rewards:
  if known_chapters.has(chapter): continue
  known_chapters.append(chapter)
  chapter_result = maxi(chapter_result,int(chapter))
func offer_break(kind: String, token: String) -> bool:
 if kind not in BREAKS or token == "" or model == null: return false
 var identity: String = str(model.state.seed)+":"+kind+":"+token
 if offered.has(identity): return false
 offered[identity] = true
 while offered.size() > 128: offered.erase(offered.keys()[0])
 opportunities[kind] = {"at":active_seconds,"token":identity}
 opportunity_counts[kind] = int(opportunity_counts.get(kind,0))+1
 return true
func register_expedition_completion(id: String) -> void:
 if id not in preload("res://scripts/Expedition.gd").ISLANDS or expedition_breaks.has(id) or model == null: return
 if not model.state.get("expeditions",{}).get(id,{}).get("completed",false): return
 expedition_breaks.append(id); restoration_break = true
 offer_break("expedition",id)
func register_attempt_completion(kind: String, id: String) -> void:
 if kind not in ["expedition_replay","mastery"] or id not in preload("res://scripts/Expedition.gd").ISLANDS: return
 break_sequence += 1; offer_break(kind,id+":"+str(break_sequence))
func denial(kind: String) -> String:
 if not opportunities.has(kind): return "no_fresh_result"
 if active_seconds-float(opportunities[kind].at) > config.ad_policy.opportunity_lifetime_seconds: return "expired_result"
 if not config.interstitials_enabled: return "disabled"
 if model.state.entitlements.has("remove_ads"): return "remove_ads"
 if lesson_blocks(kind): return "lesson"
 if not model.state.pending.is_empty() or model.state.event.until > 0: return "active_task"
 if not model.state.reward_requests.is_empty() or fullscreen_ad or dispatch_pending: return "fullscreen_busy"
 var first_guard: int = config.ad_policy.first_interstitial_seconds if cadence.impressions.is_empty() else config.ad_policy.returning_interstitial_seconds
 if active_seconds < first_guard: return "first_play_guard"
 if active_seconds < failure_until: return "failure_backoff"
 var cap: String = cadence.blocked(wall_time(),config.ad_policy)
 if cap != "": return cap
 if bridge == null or not interstitial_ready: return "no_ad_ready"
 return ""
func maybe_interstitial(kind: String = "") -> bool:
 # Only the explicit Continue action on a newly saved result can call this.
 if kind not in BREAKS or model == null: return false
 var reason := denial(kind)
 if reason != "":
  blocked_counts[kind+":"+reason] = int(blocked_counts.get(kind+":"+reason,0))+1
  opportunities.erase(kind) # Never surprise the player later when an ad loads.
  if kind == "expedition": restoration_break = false
  return false
 opportunities.erase(kind)
 # Simultaneous chapter/habitat results form one break, not back-to-back ads.
 opportunities.clear(); restoration_break = false
 dispatch_pending = true; dispatch_started = Time.get_ticks_msec(); pending_context = kind
 interstitial_count += 1; interstitial_ready = false
 dispatch_counts[kind] = int(dispatch_counts.get(kind,0))+1
 if bridge.has_method("showInterstitialAt"): bridge.showInterstitialAt(kind)
 else: bridge.showInterstitial()
 event("interstitial_dispatch",{"placement":kind,"policy":config.ad_policy.id})
 return true
func ad_report() -> String:
 return JSON.stringify({"policy":config.ad_policy,"active_seconds":active_seconds,"opportunities":opportunity_counts,"blocked":blocked_counts,"dispatches":dispatch_counts,"sdk":JSON.parse_string(ad_metrics.report()),"scope":"Local app-session measurements. Dispatches are not impressions; SDK-reported value is not publisher payout. No retention or revenue lift has been established."},"  ")

func lesson_blocks(kind: String = "") -> bool:
 if not preload("res://scripts/LearningJourney.gd").current(model).is_empty(): return true
 return preload("res://scripts/JourneyLessons.gd").record(model).active != "" and kind not in ["expedition","expedition_replay","mastery"]
func prepare_ad_services(kind: String = "") -> void:
 # Called only at a quiet gameplay moment after the first discovery.
 # Native release builds still require UMP permission before requesting ads.
 if bridge == null or model == null or model.state.discoveries.is_empty() or fullscreen_ad: return
 if lesson_blocks(kind): return
 if not online_requested: initialize_online()
 elif active_seconds >= next_ad_retry and bridge.has_method("retryAds"):
  next_ad_retry = active_seconds+60
  bridge.retryAds()

func initialize_online() -> void:
 if bridge == null: return
 online_requested = true
 next_ad_retry = active_seconds+60
 bridge.initializeServices()
 status = "Connecting to "+("test" if test_services() else "ad")+" services…"
 changed.emit()
func request_reward(kind: String, details: Dictionary = {}) -> bool:
 if bridge == null or not ad_ready or fullscreen_ad or dispatch_pending or kind not in ["coins","pulse","reroll","hint"]: return false
 if kind == "coins" and model.state.objectives.is_empty(): return false
 if kind == "reroll" and (model.state.pending.is_empty() or model.state.pending.get("ad_rerolled",false)): return false
 if kind == "hint":
  var known := false
  for recipe in model.config.recipes+model.config.fusions:
   if recipe.id == details.get("discovery",""): known = true
  if not known: return false
 var request_id := Crypto.new().generate_random_bytes(16).hex_encode()
 if not model.state.reward_requests.is_empty(): return false
 if not reward_available(): return false
 var context := details.duplicate()
 context.kind = kind
 if kind == "reroll":
  context.at = model.state.pending.at
  context.expansions = model.state.expansions
 model.state.reward_requests[request_id] = context
 var store = preload("res://scripts/SaveStore.gd").new()
 store.path = save_path
 if not store.save_state(model.state): model.state.reward_requests.erase(request_id); return false
 ad_ready = false
 bridge.showRewarded(request_id)
 event("ad_started",{"kind":kind})
 changed.emit()
 return true
func reward_available() -> bool:
 if model.state.event.until > 0: return false
 var day := int(Time.get_unix_time_from_system()/86400)
 if model.state.reward_limits.day != day: return true
 return model.state.reward_limits.count < 3
func _ad_ready(available: bool) -> void:
 ad_ready = available
 if available: event("ad_opportunity")
 status = (("Test rewarded ad ready." if test_services() else "Rewarded ad ready.")+" Maximum three optional rewards per day.") if available else "No rewarded ad available. You can continue playing."
 changed.emit()
func _ad_rewarded(request_id: String) -> void:
 if model == null: return
 var transaction := "ad:"+request_id
 if model.state.transactions.has(transaction):
  model.state.reward_requests.erase(request_id)
  if bridge != null: bridge.acknowledgeReward(request_id)
  return
 if not model.state.reward_requests.has(request_id):
  if bridge != null: bridge.acknowledgeReward(request_id)
  return
 var before: Dictionary = model.state.duplicate(true)
 var context = model.state.reward_requests[request_id]
 var kind: String = context if context is String else context.kind
 model.state.reward_requests.erase(request_id)
 # A durable accepted request must honor an earned SDK callback even if an
 # event starts while the ad is showing. Caps gate new requests, not receipts.
 var day := int(Time.get_unix_time_from_system()/86400)
 if model.state.reward_limits.day != day: model.state.reward_limits = {"day":day,"count":0}
 model.state.reward_limits.count = mini(3,int(model.state.reward_limits.count)+1)
 model.state.transactions.append(transaction)
 if kind == "coins": model.state.coins += 25
 elif kind == "pulse": model.state.energy = mini(200,model.state.energy+100)
 elif kind == "reroll" and not model.state.pending.is_empty() and model.state.pending.at == context.get("at","") and model.state.expansions == context.get("expansions",-1): model.reroll_draft()
 elif kind == "hint": model.state.hints[context.discovery] = 2
 status = "Optional reward received. Thank you!"
 event("ad_completed",{"kind":kind})
 event("ad_reward_granted",{"kind":kind})
 var store = preload("res://scripts/SaveStore.gd").new()
 store.path = save_path
 if store.save_state(model.state):
  if bridge != null: bridge.acknowledgeReward(request_id)
 else:
  model.state = before
  status = "Reward is waiting for a successful save. It will retry safely on the next launch."
 changed.emit()
func _ad_failed(request_id: String, reason: String) -> void:
 if model != null: model.state.reward_requests.erase(request_id)
 status = "Ad unavailable: "+reason+". No progress was lost."
 changed.emit()
func test_services() -> bool: return config.mode != "production" or OS.has_feature("debug")
func purchase(id: String) -> void:
 if not config.get("billing_enabled",true): return
 if bridge == null or not PRODUCTS.has(id): return
 bridge.purchase(id)
 event("purchase_started",{"product":id})
func restore() -> void:
 if bridge != null and config.get("billing_enabled",true): bridge.restorePurchases()
func _purchase_completed(id: String, token: String) -> void:
 if not PRODUCTS.has(id) or token.is_empty() or model == null: return
 var transaction := "purchase:"+token.sha256_text()
 if model.state.transactions.has(transaction): return
 var before: Dictionary = model.state.duplicate(true)
 var entitlement: String = PRODUCTS[id]
 model.state.transactions.append(transaction)
 var first_unlock: bool = not model.state.entitlements.has(entitlement)
 if first_unlock: model.state.entitlements.append(entitlement)
 if entitlement == "founders" and first_unlock: model.state.blueprints["lantern"] = int(model.state.blueprints.get("lantern",0))+1
 if entitlement == "founders" and not model.state.entitlements.has("remove_ads"): model.state.entitlements.append("remove_ads")
 status = "Purchase restored/confirmed · "+entitlement
 event("purchase_completed",{"product":id})
 var store = preload("res://scripts/SaveStore.gd").new()
 store.path = save_path
 if not store.save_state(model.state):
  model.state = before
  status = "Purchase confirmed by store; local save failed. Restore purchases to retry safely."
 changed.emit()
func _products_updated(json: String) -> void:
 var parsed = JSON.parse_string(json)
 if parsed is Array: products = parsed
 status = "Sandbox product catalog loaded." if not products.is_empty() else "No sandbox products available. Play Console tester configuration may be required."
 changed.emit()
func _service_error(message: String) -> void:
 status = message
 event("service_error",{"message":message.left(160)})
 changed.emit()

func privacy_options_available() -> bool:
 return bridge != null and bridge.privacyOptionsRequired()

func show_privacy_options() -> void:
 if privacy_options_available(): bridge.showPrivacyOptions()

func delete_diagnostics() -> bool:
 var removed: bool = telemetry.erase()
 if bridge != null: bridge.deleteDiagnostics()
 status = "Local diagnostics deleted." if removed else "Could not delete every diagnostic file. Try again."
 changed.emit()
 return removed

func _ad_lifecycle(payload: String) -> void:
 var safe: Dictionary = ad_metrics.ingest(payload)
 if safe.is_empty(): return
 if safe.event == "show_requested":
  fullscreen_ad = true; dispatch_pending = false
 elif safe.event == "impression" and safe.kind == "interstitial":
  cadence.note_impression(wall_time())
 elif safe.event == "dismissed":
  fullscreen_ad = false; dispatch_pending = false; cadence.note_dismissal(wall_time())
 elif safe.event == "show_failed":
  fullscreen_ad = false; dispatch_pending = false
  failure_until = active_seconds+config.ad_policy.failure_backoff_seconds
 event("ad_"+safe.event,safe)
