extends Node
signal changed
var model
var telemetry = preload("res://scripts/Telemetry.gd").new()
var save_path := "user://biome.json"
var session_start := 0.0
var last_interstitial := -1000.0
var interstitial_count := 0
var interstitial_ready := false
var last_ad_chapter := 0
var bridge: Object
var ad_ready := false
var status := "Optional online services are unavailable on this platform. Core play stays offline."
var products := []
var log_path := "user://diagnostics.jsonl"
const PRODUCTS = {"pocket_biome_remove_ads_test":"remove_ads","pocket_biome_moon_theme_test":"moon","pocket_biome_founders_test":"founders"}
func _ready() -> void:
 add_child(telemetry)
 if Engine.has_singleton("PocketServices"):
  bridge = Engine.get_singleton("PocketServices")
  bridge.connect("ad_ready",_ad_ready)
  bridge.connect("interstitial_ready",func(available): interstitial_ready = available)
  bridge.connect("ad_rewarded",_ad_rewarded)
  bridge.connect("ad_failed",_ad_failed)
  bridge.connect("purchase_completed",_purchase_completed)
  bridge.connect("purchase_failed",func(reason): event("purchase_failed",{"reason":reason.left(160)}))
  bridge.connect("service_error",_service_error)
  bridge.connect("products_updated",_products_updated)
  status = "Sandbox store and test advertisements. Connect only if you want optional services."
func event(name: String, data: Dictionary = {}) -> void:
 telemetry.model = model
 telemetry.path = log_path
 telemetry.record(name,data)

func begin_session() -> void:
 session_start = model.state.time
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

func maybe_interstitial() -> bool:
 if bridge == null or not interstitial_ready or model == null: return false
 if not JSON.parse_string(FileAccess.get_file_as_string("res://data/services.json")).interstitials_enabled: return false
 if model.state.entitlements.has("remove_ads") or model.state.event.until > 0 or not model.state.pending.is_empty(): return false
 if model.state.time-session_start < 480 or model.state.time-last_interstitial < 600 or interstitial_count >= 2: return false
 if model.state.chapter_rewards.size() <= last_ad_chapter: return false
 interstitial_count += 1
 last_interstitial = model.state.time
 last_ad_chapter = model.state.chapter_rewards.size()
 interstitial_ready = false
 bridge.showInterstitial()
 event("interstitial_shown")
 return true

func initialize_online() -> void:
 if bridge == null: return
 bridge.initializeServices()
 status = "Connecting to optional sandbox services…"
 changed.emit()
func request_reward(kind: String, details: Dictionary = {}) -> bool:
 if bridge == null or not ad_ready or kind not in ["coins","pulse","reroll","hint"]: return false
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
 status = "Test rewarded ad ready. Maximum three optional rewards per day." if available else "No rewarded ad available. You can continue playing."
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
 if not reward_available(): return
 var day := int(Time.get_unix_time_from_system()/86400)
 if model.state.reward_limits.day != day: model.state.reward_limits = {"day":day,"count":0}
 model.state.reward_limits.count += 1
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
func purchase(id: String) -> void:
 if bridge == null or not PRODUCTS.has(id): return
 bridge.purchase(id)
 event("purchase_started",{"product":id})
func restore() -> void:
 if bridge != null: bridge.restorePurchases()
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
