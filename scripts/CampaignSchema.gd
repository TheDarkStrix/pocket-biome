extends RefCounted
const Campaign = preload("res://scripts/CampaignSystem.gd")
static func validate(store, s: Dictionary, config: Dictionary) -> bool:
 var defaults := Campaign.defaults()
 if not s.get("audio_levels") is Dictionary: return false
 for field in ["music","sfx"]:
  if not store.number(s.audio_levels.get(field),0,1): return false
 if not store.number(s.get("text_scale"),1,1.2) or not s.get("hints") is Dictionary: return false
 for id in s.hints:
  if not id is String or not store.integer(s.hints[id],0,2): return false
 for field in defaults:
  if not s.has(field): return false
 if not store.integer(s.chapter,1,5) or not store.integer(s.next_job,1,1000000000): return false
 if not s.stats is Dictionary or not s.settings is Dictionary or not s.blueprints is Dictionary or not s.event is Dictionary: return false
 for id in defaults.stats:
  if not store.integer(s.stats.get(id),0,1000000000): return false
 for id in s.stats:
  if not id is String or not store.integer(s.stats[id],0,1000000000): return false
 for id in defaults.settings:
  if not s.settings.get(id) is bool: return false
 if not s.chapter_rewards is Array or s.chapter_rewards.size() > 5: return false
 var rewards := []
 for id in s.chapter_rewards:
  if not store.integer(id,1,5) or rewards.has(int(id)): return false
  rewards.append(int(id))
 for id in s.blueprints:
  if not id is String or not config.tiles.has(id): return false
  if not store.integer(s.blueprints[id],0,10000): return false
 if not s.jobs is Array or s.jobs.size() > 3: return false
 var job_ids := []
 var recipe_ids := []
 for recipe in config.crafting: recipe_ids.append(recipe.id)
 for job in s.jobs:
  if not job is Dictionary: return false
  if not store.integer(job.get("id"),1,s.next_job-1) or job_ids.has(int(job.id)): return false
  if not job.get("recipe") is String or not recipe_ids.has(job.recipe): return false
  if not store.number(job.get("until"),0,s.time+60) or not store.integer(job.get("quantity",1),1,3): return false
  job_ids.append(int(job.id))
 for resource in ["brick","star_dew"]:
  if not store.integer(s.inventory.get(resource),0,config.economy.inventory_limit): return false
 for field in defaults.event:
  if not s.event.has(field): return false
 var event: Dictionary = s.event
 if not store.number(event.next_at,0,s.time+3600) or not store.number(event.until,0,s.time+60): return false
 if not store.integer(event.completed,0,1000000000): return false
 if not event.targets is Array or event.targets.size() > 2 or not event.cleared is Array or not event.applied is Dictionary: return false
 var seen := []
 for key in event.targets:
  if not store.coordinate(key) or not s.tiles.has(key) or s.tiles[key].has("owner") or seen.has(key): return false
  if not store.integer(event.applied.get(key),0,20): return false
  seen.append(key)
 if event.until > 0 and event.targets.size() != 2: return false
 for key in event.cleared:
  if not event.targets.has(key): return false
 for field in ["entitlements","transactions"]:
  if not s[field] is Array or s[field].size() > 4096: return false
  for item in s[field]:
   if not item is String or item.length() > 512: return false
 if not s.reward_requests is Dictionary or s.reward_requests.size() > 1 or not s.reward_limits is Dictionary: return false
 if not store.integer(s.reward_limits.get("day"),0,1000000) or not store.integer(s.reward_limits.get("count"),0,3): return false
 for id in s.reward_requests:
  if not id is String or id.length() != 32: return false
  var context = s.reward_requests[id]
  if context is String:
   if context not in ["coins","pulse"]: return false
  elif context is Dictionary:
   if context.get("kind","") not in ["coins","pulse","reroll","hint"]: return false
   if context.kind == "reroll" and (not store.coordinate(context.get("at")) or not store.integer(context.get("expansions"),0,60)): return false
   if context.kind == "hint" and (not context.get("discovery") is String or context.discovery.length() > 64): return false
  else: return false
 if not s.cosmetic is String or s.cosmetic not in ["day","dusk","moon","sakura","celestial"]: return false
 return true

static func upgrade(s: Dictionary) -> Dictionary:
 if s.version == 1:
  for field in Campaign.defaults(): s[field] = Campaign.defaults()[field]
  s.inventory.brick = 0
  s.inventory.star_dew = 0
  for tile in s.tiles.values():
   if not tile.has("owner"):
    tile.next_effect = 0.0
    tile.next_production = 0.0
 elif s.version == 2:
  var defaults := Campaign.defaults()
  for field in ["audio_levels","text_scale","hints","reward_requests","reward_limits"]:
   if not s.has(field): s[field] = defaults[field]
  if s.get("settings") is Dictionary:
   for field in ["tutorial_seen","vibration"]:
    if not s.settings.has(field): s.settings[field] = defaults.settings[field]
 s.version = 3
 return s
