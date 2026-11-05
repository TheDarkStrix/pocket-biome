extends RefCounted
# Bounded local equilibrium. Classic saves retain their original simulation rules.
const GAINS = {"moisture":6,"heat":6,"fertility":9,"stability":9,"magic":17}
const Care = preload("res://scripts/RestorationCare.gd")
static func balanced(m) -> bool: return m.state.get("ecology_rules","classic") == "balanced"
static func target(m, at: String) -> Dictionary:
 var tile: Dictionary = m.state.tiles[at]
 var result := {}
 for i in range(m.config.attributes.size()): result[m.config.attributes[i]] = int(m.config.tiles[tile.type].dna[i])
 for other in m.neighbors(at):
  var source: Dictionary = m.state.tiles[other]
  if not source.get("enabled",true): continue
  for attribute in m.config.effects.get(source.type,{}):
   result[attribute] += int(m.config.effects[source.type][attribute])*int(source.get("level",1))*GAINS[attribute]
 for attribute in result: result[attribute] = clampi(result[attribute],0,100)
 for mode in Care.MODES:
  if not Care.unlocked(m,mode): continue
  var applied := false
  for cell in Care.targets(m,mode):
   if m.origin(cell) == at: applied = true
  if not applied or (mode == "channel" and Care.water_source(m,at) == ""): continue
  for attribute in Care.EFFECTS[mode]: result[attribute] = clampi(result[attribute]+Care.EFFECTS[mode][attribute]*3,0,100)
 for boost in tile.get("boosts",[]):
  if boost.until <= m.state.time: continue
  for attribute in boost.applied: result[attribute] = clampi(result[attribute]+boost.applied[attribute],0,100)
 return result
static func next_values(m, at: String) -> Dictionary:
 var goal := target(m,at)
 var result: Dictionary = m.state.tiles[at].dna.duplicate()
 for attribute in result:
  var difference: int = goal[attribute]-result[attribute]
  var amount := mini(12,ceili(absf(difference)/4.0))
  result[attribute] += signi(difference)*amount
 return result
static func outlook(m, at: String) -> String:
 at = m.origin(at)
 if at == "": return "Choose land to inspect its climate."
 var tile: Dictionary = m.state.tiles[at]
 var goal := target(m,at)
 var words := PackedStringArray()
 for attribute in ["moisture","heat"]:
  var difference: int = goal[attribute]-tile.dna[attribute]
  words.append("%s %d · %s" % [attribute.capitalize(),tile.dna[attribute],"stable" if difference == 0 else "rising" if difference > 0 else "falling"] if balanced(m) else "%s %d" % [attribute.capitalize(),tile.dna[attribute]])
 return " · ".join(words)+( "\nWith these neighbors, approaches %d moisture / %d heat." % [goal.moisture,goal.heat] if balanced(m) else "\nClassic growth accumulates neighbor effects. Living climate uses a local balance.")
static func qualifies(m, tile: Dictionary, recipe: Dictionary) -> bool:
 if tile.type not in recipe.types: return false
 for attribute in recipe.min:
  if tile.dna[attribute] < recipe.min[attribute]: return false
 for attribute in recipe.max:
  if tile.dna[attribute] > recipe.max[attribute]: return false
 for structure in recipe.structures:
  if not m.campaign.has_structure(m,structure): return false
 return recipe.pulse == "" or (tile.get("last_pulse","") == recipe.pulse and tile.get("last_pulse_until",0) >= m.state.time)
static func cultivate(m, at: String, recipe_id: String) -> bool:
 at = m.origin(at)
 if at == "" or not m.state.pending.is_empty() or m.state.tiles[at].size != 1 or m.state.event.targets.has(at): return false
 for recipe in m.config.recipes:
  if recipe.id != recipe_id or not qualifies(m,m.state.tiles[at],recipe): continue
  m.state.tiles[at].evolution = recipe.id
  m.state.tiles[at].cultivated = true
  m.discover(recipe.id,recipe.name,recipe.reward)
  m.message = "Cultivating "+recipe.name+". Conditions and harvest timing are kept. Journal discoveries remain permanent."
  return true
 return false
static func release(m, at: String) -> bool:
 at = m.origin(at)
 if at == "" or not m.state.tiles[at].get("cultivated",false): return false
 m.state.tiles[at].erase("cultivated")
 m.message = "Natural discovery resumed. Your recorded discoveries are kept."
 return true
static func consequences(m, type: String, target_key: String, source: String = "") -> String:
 # Clone has no signals, services or save path; previews can never spend or commit.
 var copy = m.get_script().new(); copy.config = m.config; copy.state = m.state.duplicate(true)
 var projects = preload("res://scripts/HabitatProjects.gd")
 var before := {}; var after := {}; var now := []
 for id in projects.IDS: before[id] = projects.inspect(copy,id).ready
 if source != "":
  if not preload("res://scripts/LayoutTools.gd").move(copy,source,target_key): return "This destination cannot receive the selected land."
 else:
  if type == "" or not m.config.tiles.has(type): return ""
  copy.add_tile(copy.coord(target_key),type)
 for id in projects.IDS:
  after[id] = projects.inspect(copy,id).ready
  if before[id] and not after[id]: now.append("Breaks "+projects.NAMES[id])
  elif not before[id] and after[id]: now.append("Supports "+projects.NAMES[id])
 var neighbors: Array = m.neighbors(target_key) if m.state.tiles.has(target_key) else preload("res://scripts/GameplayAdvisor.gd").placement_neighbors(m,target_key)
 var caption := "%d edge-sharing neighbors affected." % neighbors.size()
 if not now.is_empty(): caption += "\n"+"\n".join(now)
 else: caption += "\nHabitat suitability also depends on conditions as time passes."
 return caption
