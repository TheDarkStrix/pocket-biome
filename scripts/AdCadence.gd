extends RefCounted
# App-wide frequency history; contains only local timestamps, never player identity.
var path := "user://ad-cadence.json"
var impressions: Array = []
var last_fullscreen := 0.0
var writable := true
func load_history(now: float) -> void:
 if not FileAccess.file_exists(path): return
 var value = JSON.parse_string(FileAccess.get_file_as_string(path))
 if not value is Dictionary or value.get("version") != 1 or not value.get("impressions") is Array or value.impressions.size() > 64 or not number(value.get("last_fullscreen")):
  last_fullscreen = now; impressions = []; writable = false; return
 for stamp in value.impressions:
  if not number(stamp): last_fullscreen = now; impressions = []; writable = false; return
 impressions = value.impressions.duplicate(); last_fullscreen = float(value.last_fullscreen)
 # A backwards wall-clock change cannot remove the cooldown.
 if last_fullscreen > now: last_fullscreen = now
 for index in range(impressions.size()): impressions[index] = minf(float(impressions[index]),now)
func number(value: Variant) -> bool: return (value is int or value is float) and is_finite(float(value)) and value >= 0
func blocked(now: float, policy: Dictionary) -> String:
 if not writable: return "cadence_storage"
 if last_fullscreen > 0 and now-last_fullscreen < policy.min_fullscreen_gap_seconds: return "fullscreen_spacing"
 var count := 0
 for stamp in impressions:
  if stamp >= now-policy.rolling_window_seconds: count += 1
 return "rolling_cap" if count >= policy.max_interstitials_per_window else ""
func note_impression(now: float) -> void:
 impressions = impressions.filter(func(stamp): return stamp >= now-7200)
 impressions.append(now)
 while impressions.size() > 64: impressions.pop_front()
 save_history()
func note_dismissal(now: float) -> void:
 last_fullscreen = now; save_history()
func save_history() -> bool:
 var file = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file == null: writable = false; return false
 file.store_string(JSON.stringify({"version":1,"last_fullscreen":last_fullscreen,"impressions":impressions}));file.flush()
 var ok: bool = file.get_error() == OK;file.close()
 writable = ok and DirAccess.rename_absolute(path+".tmp",path) == OK
 return writable
