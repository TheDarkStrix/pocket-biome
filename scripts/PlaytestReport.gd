extends Node
# Optional bounded local reporting, deliberately independent of network diagnostics.
var model
var bound
var path := "user://private-playtest.json"
const LIMIT = 200
func attach(m) -> void:
 model = m
 if bound == m: return
 if is_instance_valid(bound) and bound.occurred.is_connected(record): bound.occurred.disconnect(record)
 bound = m; m.occurred.connect(record)
func enabled() -> bool: return model != null and model.state.get("private_playtest",false)
func rows() -> Array:
 if not FileAccess.file_exists(path): return []
 var value = JSON.parse_string(FileAccess.get_file_as_string(path))
 return value if value is Array else []
func record(event: String, data: Dictionary = {}) -> void:
 if not enabled(): return
 var events := rows()
 var safe := {}
 for key in ["id","chapter","screen","reason","type","quantity"]:
  if data.has(key): safe[key] = str(data[key]).left(80)
 events.append({"island":int(model.state.seed),"event":event.left(64),"active_seconds":snappedf(model.state.time,0.1),"data":safe})
 while events.size() > LIMIT: events.pop_front()
 var file = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file == null: return
 file.store_string(JSON.stringify(events)); file.flush(); file.close()
 DirAccess.rename_absolute(path+".tmp",path)
func report() -> String:
 var events: Array = rows().filter(func(row): return row is Dictionary and row.get("island",-1) == model.state.seed)
 var counts := {}; var first_discovery := -1.0; var first_project := -1.0; var longest := 0.0; var last := 0.0
 for event in events:
  if not event is Dictionary or not event.get("event") is String: continue
  var name: String = event.event
  counts[name] = int(counts.get(name,0))+1
  var time: float = float(event.get("active_seconds",0))
  if name == "biome_discovered" and first_discovery < 0: first_discovery = time
  if name == "restoration_saved" and first_project < 0: first_project = time
  if name in ["biome_discovered","restoration_saved","tile_placed","chapter_completed"]:
   longest = maxf(longest,time-last); last = time
 return JSON.stringify({"scope":"Last 200 local events; active time belongs to this island. Not a retention or enjoyment score.","first_discovery_active_seconds":first_discovery,"first_restoration_active_seconds":first_project,"longest_recorded_progress_gap_seconds":longest,"counts":counts,"events":events},"  ")
func erase() -> void:
 for suffix in ["",".tmp",".txt"]:
  if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
func show_report(h) -> void:
 var box: VBoxContainer = h.modal_content("Private playtest report")
 h.modal_screen = "playtest_report"
 h.sheets.caption(h,"Optional reporting stays on this device. It records bounded gameplay events and routes, with no names, device IDs or advertising identifiers. It never uploads. Turn it on before a private test.",box)
 h.button("Local reporting · "+("On" if enabled() else "Off"),func():
  var before: Dictionary = h.model.state.duplicate(true)
  h.model.state.private_playtest = not enabled()
  if not h.store.save_state(h.model.state): h.model.state = before
  show_report(h),box)
 h.label(report(),12,box)
 h.button("Export local report",func():
  var file = FileAccess.open(path+".txt",FileAccess.WRITE)
  if file != null: file.store_string(report()); file.close(); h.model.message = "Report saved locally: "+ProjectSettings.globalize_path(path+".txt")
  h.refresh(),box)
 h.label("Native ad delivery · session diagnostics",17,box)
 h.sheets.caption(h,h.services.ad_metrics.report(),box)
 h.button("Delete report",func(): erase(); show_report(h),box)
 h.campaign_ui.close_button(h,box)

func _exit_tree() -> void:
 if is_instance_valid(bound) and bound.occurred.is_connected(record): bound.occurred.disconnect(record)
 bound = null; model = null
