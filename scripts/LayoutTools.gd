extends RefCounted
# Spatial recovery changes occupancy contents, never land count, prices or rewards.
const PROTECTED = {"0,0":"oak","1,0":"stone","0,1":"fiber"}
static func can_dismantle(m, at: String) -> bool:
 at = m.origin(at)
 if at == "" or not m.state.pending.is_empty(): return false
 var tile: Dictionary = m.state.tiles[at]
 if tile.size != 4 or not tile.get("boosts",[]).is_empty(): return false
 for key in m.footprint(at):
  if m.state.event.targets.has(key): return false
 return true
static func dismantle(m, at: String) -> bool:
 at = m.origin(at)
 if not can_dismantle(m,at): return false
 var ready: float = m.state.tiles[at].ready
 var last_tap: float = m.state.tiles[at].last_tap
 var cells: Array = m.footprint(at)
 for key in cells:
  m.add_tile(m.coord(key),PROTECTED.get(key,"grass"))
  m.state.tiles[key].ready = ready
  m.state.tiles[key].last_tap = last_tap
 m.message = "Sanctuary dismantled. Four plots recovered; discoveries and earned rewards are kept."
 m.record_event("sanctuary_dismantled")
 return true
static func movable(m, source: String) -> bool:
 if source == "" or not m.state.tiles.has(source) or PROTECTED.has(source) or not m.state.pending.is_empty(): return false
 var tile: Dictionary = m.state.tiles[source]
 return not tile.has("owner") and tile.size == 1 and m.config.tiles[tile.type].category == "structure" and not m.state.event.targets.has(source) and tile.get("boosts",[]).is_empty()
static func can_move(m, source: String, target: String) -> bool:
 if not movable(m,source) or source == target or not m.state.tiles.has(target) or PROTECTED.has(target) or m.state.event.targets.has(target): return false
 var tile: Dictionary = m.state.tiles[target]
 return not tile.has("owner") and tile.type == "grass" and tile.evolution == "" and tile.size == 1 and tile.get("boosts",[]).is_empty()
static func move(m, source: String, target: String) -> bool:
 if not can_move(m,source,target): return false
 var structure: Dictionary = m.state.tiles[source].duplicate(true)
 m.add_tile(m.coord(source),"grass")
 m.state.tiles[target] = structure
 m.message = "Structure moved. Level, production timing and pause state are preserved."
 m.record_event("structure_moved",{"type":structure.type})
 return true
