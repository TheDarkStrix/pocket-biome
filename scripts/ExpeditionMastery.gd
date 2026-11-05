extends RefCounted
const Quest = preload("res://scripts/Expedition.gd")
const VARIANTS = ["swift","careful"]
const NAMES = {"swift":"Season challenge","careful":"Careful restoration"}
const RULES = {"swift":"Restore in four seasons or fewer. You can finish a longer practice attempt; only a qualifying result earns a personal best.","careful":"Place terrain only on empty Meadow. Existing supplies cannot be replaced or removed. A fresh attempt is always available; home resources stay safe."}
static func key(id: String, variant: String) -> String: return id+":"+variant
static func fresh(id: String, variant: String) -> Dictionary:
 return {"board":Quest.fresh(id),"variant":variant,"moves":0} if id in Quest.ISLANDS and variant in VARIANTS else {}
static func place(trial: Dictionary, index: int, kind: String) -> bool:
 if trial.board.completed or index < 0 or index >= 9 or trial.moves >= 10000: return false
 if trial.board.plots[index] == kind: return false
 if trial.variant == "careful" and trial.board.plots[index] != "meadow": return false
 if not Quest.place(trial.board,index,kind): return false
 trial.moves += 1
 return true
static func qualified(trial: Dictionary) -> bool:
 return Quest.progress(trial.board).ready and (trial.variant != "swift" or trial.board.seasons <= 4)
static func finish(m, id: String, variant: String) -> bool:
 var entry: String = key(id,variant)
 if not m.state.get("expedition_trials",{}).has(entry): return false
 var trial: Dictionary = m.state.expedition_trials[entry]
 if trial.board.completed or not Quest.progress(trial.board).ready: return false
 trial.board.completed = true
 if qualified(trial):
  if not m.state.has("expedition_bests"): m.state.expedition_bests = {}
  var result := {"seasons":int(trial.board.seasons),"moves":int(trial.moves)}
  var best: Dictionary = m.state.expedition_bests.get(entry,{})
  if best.is_empty() or result.seasons < best.seasons or (result.seasons == best.seasons and result.moves < best.moves): m.state.expedition_bests[entry] = result
 return true
static func validate(store, s: Dictionary) -> bool:
 for field in ["expedition_trials","expedition_bests"]:
  if not s.has(field): continue
  var records = s[field]
  if not records is Dictionary or records.size() > 8: return false
  for entry in records:
   if not entry is String: return false
   var pieces: PackedStringArray = entry.split(":")
   if pieces.size() != 2 or pieces[0] not in Quest.ISLANDS or pieces[1] not in VARIANTS: return false
   var record = records[entry]
   if not record is Dictionary: return false
   if field == "expedition_trials":
    if record.size() != 3 or record.get("variant") != pieces[1] or not store.integer(record.get("moves"),0,10000): return false
    if not Quest.validate({pieces[0]:record.get("board")},store): return false
    if pieces[1] == "careful":
     var initial := Quest.fresh(pieces[0]); var occupied := 0
     for index in range(9):
      if initial.plots[index] == "meadow" and record.board.plots[index] != "meadow": occupied += 1
     if occupied != record.moves: return false
   else:
    if record.size() != 2 or not store.integer(record.get("seasons"),0,10000) or not store.integer(record.get("moves"),0,10000): return false
    if pieces[1] == "swift" and record.seasons > 4: return false
 return true
