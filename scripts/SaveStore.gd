extends RefCounted
const CampaignSchema = preload("res://scripts/CampaignSchema.gd")
const Model = preload("res://scripts/WorldModel.gd")
var path := "user://biome.json"
var error := ""

# Validate types before arithmetic/indexing: corrupt JSON must never crash recovery.
func integer(v: Variant, low: int, high: int) -> bool:
 if not (v is int or v is float): return false
 return is_finite(float(v)) and float(v) == floor(float(v)) and v >= low and v <= high

func number(v: Variant, low: float, high: float) -> bool:
 return (v is int or v is float) and is_finite(float(v)) and v >= low and v <= high

func coordinate(v: Variant) -> bool:
 if not v is String: return false
 var parts = v.split(",")
 if parts.size() != 2: return false
 for part in parts:
  if not part.is_valid_int() or abs(int(part)) > 64: return false
 return v == "%d,%d" % [int(parts[0]), int(parts[1])]

func valid(s: Variant) -> bool:
 if not s is Dictionary: return false
 for k in ["version","seed","tiles","coins","inventory","expansions","pending","discoveries","energy","time","harvests","objectives","next_id"]:
  if not s.has(k): return false
 for field in ["version","seed","coins","expansions","energy","harvests","next_id"]:
  if not integer(s[field],0,1000000000): return false
 if int(s.version) not in [1,2,3] or s.energy > 200 or s.next_id < 1: return false
 if not number(s.time,0,1000000000): return false
 if not s.tiles is Dictionary or s.tiles.size() < 4 or s.tiles.size() > 64: return false
 if s.expansions != s.tiles.size()-4: return false
 if not s.pending is Dictionary or not s.inventory is Dictionary: return false
 if not s.discoveries is Array or not s.objectives is Array: return false
 var model = Model.new()
 var recipe_ids := []
 for fusion in model.config.fusions: recipe_ids.append(fusion.id)
 for recipe in model.config.recipes: recipe_ids.append(recipe.id)
 var unique := []
 for id in s.discoveries:
  if not id is String or not recipe_ids.has(id) or unique.has(id): return false
  unique.append(id)
 unique.clear()
 for id in s.objectives:
  if not integer(id,0,2) or unique.has(int(id)): return false
  unique.append(int(id))
 var entity_ids := []
 for k in s.tiles:
  if not coordinate(k): return false
  var t = s.tiles[k]
  if not t is Dictionary: return false
  if t.has("owner"):
   if t.size() != 1 or not coordinate(t.owner) or t.owner == k: return false
   if not s.tiles.has(t.owner): return false
   var owner = s.tiles[t.owner]
   if not owner is Dictionary or owner.get("size",0) != 4 or owner.has("owner"): return false
   var offset = model.coord(k)-model.coord(t.owner)
   if offset not in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: return false
   continue
  for f in ["type","dna","ready","last_tap","evolution","size","id"]:
   if not t.has(f): return false
  if not t.type is String or not model.config.tiles.has(t.type): return false
  if not integer(t.id,1,s.next_id-1) or entity_ids.has(int(t.id)): return false
  entity_ids.append(int(t.id))
  if not integer(t.size,1,4) or int(t.size) not in [1,4]: return false
  if not t.evolution is String or (t.evolution != "" and not recipe_ids.has(t.evolution)): return false
  if t.evolution != "" and not s.discoveries.has(t.evolution): return false
  for timer in ["next_effect","next_production"]:
   if s.version >= 2 and not number(t.get(timer),0,s.time+120): return false
  if t.has("last_pulse"):
   if not t.last_pulse is String or not model.config.powers.has(t.last_pulse) or not number(t.get("last_pulse_until"),0,s.time+12): return false
  if t.has("level") and not integer(t.level,1,3): return false
  if t.has("enabled") and not t.enabled is bool: return false
  if not number(t.ready,0,s.time+120) or not number(t.last_tap,-1,s.time): return false
  if not t.dna is Dictionary: return false
  for attribute in model.config.attributes:
   if not integer(t.dna.get(attribute),0,100): return false
  if t.size == 4:
   var matched := false
   for fusion in model.config.fusions:
    if t.type == fusion.type and t.evolution == fusion.id: matched = true
   if not matched: return false
   for offset in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]:
    var reservation = s.tiles.get(model.key(model.coord(k)+offset))
    if not reservation is Dictionary or reservation.get("owner") != k: return false
  else:
   for fusion in model.config.fusions:
    if t.evolution == fusion.id: return false
  var boosts = t.get("boosts",[])
  if not boosts is Array or boosts.size() > 64: return false
  for boost in boosts:
   if not boost is Dictionary: return false
   if not boost.get("power") is String or not model.config.powers.has(boost.power): return false
   if not number(boost.get("until"),0,s.time+12): return false
   if not boost.get("applied") is Dictionary: return false
   var expected: Dictionary = model.config.powers[boost.power]
   if boost.applied.size() != expected.size(): return false
   for attribute in expected:
    if not integer(boost.applied.get(attribute),mini(0,expected[attribute]),maxi(0,expected[attribute])): return false
 for resource in ["wood","stone","fiber","clay","iron"]:
  if not integer(s.inventory.get(resource),0,1000000000): return false
 # Ensure one connected landmass, including fusion reservations.
 var reached := [s.tiles.keys()[0]]
 var cursor := 0
 while cursor < reached.size():
  for direction in Model.DIRS:
   var neighbor = model.key(model.coord(reached[cursor])+direction)
   if s.tiles.has(neighbor) and not reached.has(neighbor): reached.append(neighbor)
  cursor += 1
 if reached.size() != s.tiles.size(): return false
 if not s.pending.is_empty():
  if s.pending.has("ad_rerolled") and not s.pending.ad_rerolled is bool: return false
  if not coordinate(s.pending.get("at")) or not integer(s.pending.get("cost"),1,1000000000): return false
  if not s.pending.get("cards") is Array or s.pending.cards.size() != 3: return false
  for card in s.pending.cards:
   if not card is String or not model.config.tiles.has(card): return false
  model.state = s
  if not model.frontier().has(s.pending.at) or s.coins < s.pending.cost: return false
  if s.pending.cost != model.cost(): return false
 if s.version >= 2 and not CampaignSchema.validate(self,s,model.config): return false
 return true

func save_state(s: Dictionary) -> bool:
 error = ""
 if not valid(s):
  error = "Invalid state; previous save preserved"
  return false
 var f = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if f == null:
  error = "Cannot open save"
  return false
 f.store_string(JSON.stringify(s))
 f.flush()
 var result = f.get_error()
 f.close()
 if result != OK:
  error = "Save write/flush failed (%d)" % result
  return false
 if FileAccess.file_exists(path):
  var parser := JSON.new()
  var parsed := parser.parse(FileAccess.get_file_as_string(path))
  if parsed == OK and valid(parser.data):
   if copy_previous() != OK:
    error = "Cannot preserve previous save backup"
    return false
 var renamed := commit_temporary()
 if renamed != OK: error = "Atomic save replacement failed (%d)" % renamed
 return renamed == OK

func load_state() -> Dictionary:
 error = ""
 for candidate in [path,path+".bak"]:
  if not FileAccess.file_exists(candidate): continue
  var parser := JSON.new()
  if parser.parse(FileAccess.get_file_as_string(candidate)) != OK: continue
  var s = parser.data
  if s is Dictionary and integer(s.get("version"),1,2):
   var base: Dictionary = s.duplicate(true)
   base.version = 1
   if not valid(base): continue
   s = CampaignSchema.upgrade(s)
  if valid(s):
   if candidate.ends_with(".bak"): error = "Recovered backup save"
   return canonicalize(s)
 error = "No valid save; starting a new island"
 return {}

func canonicalize(s: Dictionary) -> Dictionary:
 # JSON parses all numbers as floats. Restore integer identity before Array.has
 # and reward deduplication; validation has already rejected fractional values.
 for field in ["version","seed","coins","expansions","energy","harvests","next_id"]: s[field] = int(s[field])
 for field in ["chapter","next_job"]: s[field] = int(s[field])
 for id in s.hints: s.hints[id] = int(s.hints[id])
 for id in s.stats: s.stats[id] = int(s.stats[id])
 for id in s.blueprints: s.blueprints[id] = int(s.blueprints[id])
 for i in range(s.chapter_rewards.size()): s.chapter_rewards[i] = int(s.chapter_rewards[i])
 for job in s.jobs:
  job.id = int(job.id)
  job.quantity = int(job.get("quantity",1))
 s.reward_limits.day = int(s.reward_limits.day)
 s.reward_limits.count = int(s.reward_limits.count)
 s.event.completed = int(s.event.completed)
 for key in s.event.applied: s.event.applied[key] = int(s.event.applied[key])
 for i in range(s.objectives.size()): s.objectives[i] = int(s.objectives[i])
 for resource in s.inventory: s.inventory[resource] = int(s.inventory[resource])
 if not s.pending.is_empty(): s.pending.cost = int(s.pending.cost)
 for k in s.tiles:
  var tile: Dictionary = s.tiles[k]
  if tile.has("owner"): continue
  tile.id = int(tile.id)
  tile.size = int(tile.size)
  tile.level = int(tile.get("level",1))
  for attribute in tile.dna: tile.dna[attribute] = int(tile.dna[attribute])
  for boost in tile.get("boosts",[]):
   for attribute in boost.applied: boost.applied[attribute] = int(boost.applied[attribute])
 return s

# Narrow filesystem boundary permits deterministic I/O-failure tests.
func copy_previous() -> Error:
 return DirAccess.copy_absolute(path,path+".bak")

func commit_temporary() -> Error:
 return DirAccess.rename_absolute(path+".tmp",path)
