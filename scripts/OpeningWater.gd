extends RefCounted
# Read-only opening context. The model owns offer repair; no goal progress is fabricated.
static func needed(m) -> bool:
 var learning: Dictionary = m.state.get("learning",{})
 if m.state.harvests < 1 or m.state.chapter != 1 or not m.state.discoveries.is_empty() or learning.get("dismissed",false) or learning.get("completed",false): return false
 if not m.state.tiles.has("0,0") or m.state.tiles["0,0"].type != "oak": return false
 for key in m.neighbors("0,0"):
  if m.state.tiles[key].type == "water": return false
 return true
static func targets(m) -> Array[String]:
 var result: Array[String] = []
 if not needed(m): return result
 for key in m.frontier():
  var at: Vector2i = m.coord(key)
  if absi(at.x)+absi(at.y) == 1: result.append(key)
 return result
static func valid_target(m, key: String) -> bool:
 return targets(m).has(key)
