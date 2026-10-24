extends Node
var model
var path := "user://diagnostics.jsonl"
var endpoint: String = JSON.parse_string(FileAccess.get_file_as_string("res://data/services.json")).telemetry_url
var request: HTTPRequest
var in_flight := PackedStringArray()
func _ready() -> void:
 request = HTTPRequest.new()
 request.timeout = 8
 add_child(request)
 request.request_completed.connect(_completed)
func rows() -> PackedStringArray:
 if FileAccess.file_exists(path): return FileAccess.get_file_as_string(path).split("\n",false)
 return PackedStringArray()
func replace(lines: PackedStringArray) -> bool:
 var file = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file == null: return false
 file.store_string("\n".join(lines)+("\n" if not lines.is_empty() else ""))
 file.flush()
 var ok: bool = file.get_error() == OK
 file.close()
 return ok and DirAccess.rename_absolute(path+".tmp",path) == OK
func record(name: String, data: Dictionary = {}) -> bool:
 if model == null or not model.state.settings.analytics: return false
 var lines := rows()
 while lines.size() >= 128: lines.remove_at(0)
 # Bounded app events only. No purchase tokens, advertising IDs or device IDs.
 var record := {"id":Crypto.new().generate_random_bytes(8).hex_encode(),"event":name.left(64),"active_time":model.state.time,"data":data}
 var encoded := JSON.stringify(record)
 if encoded.length() > 16000:
  record.data = {"summary":"Diagnostic payload omitted: size limit"}
  encoded = JSON.stringify(record)
 lines.append(encoded)
 return replace(lines)
func flush() -> void:
 if request == null or model == null or not model.state.settings.analytics or not endpoint.begins_with("https://") or not in_flight.is_empty(): return
 var lines := rows()
 if lines.is_empty(): return
 var batch := []
 for line in lines.slice(0,mini(32,lines.size())):
  var parsed = JSON.parse_string(line)
  if parsed is Dictionary: batch.append(parsed); in_flight.append(parsed.id)
 var error := request.request(endpoint,PackedStringArray(["Content-Type: application/json"]),HTTPClient.METHOD_POST,JSON.stringify({"events":batch}))
 if error != OK: in_flight.clear()
func _completed(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
 if result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300:
  var keep := PackedStringArray()
  for line in rows():
   var event = JSON.parse_string(line)
   if event is Dictionary and not in_flight.has(event.get("id","")): keep.append(line)
  replace(keep)
 in_flight.clear()
