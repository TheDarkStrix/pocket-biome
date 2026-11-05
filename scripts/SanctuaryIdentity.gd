extends RefCounted
const KINDS = ["path","sign","reeds","bench","lamp","flowers","firefly"]
const NAMES = {"path":"Pebble path","sign":"Sanctuary sign","reeds":"Pond-edge reeds","bench":"Woodland bench","lamp":"Warm garden light","flowers":"Flower ring","firefly":"Firefly lantern"}
static func name_of(m) -> String: return m.state.get("sanctuary",{}).get("name","My Sanctuary")
static func owned(m, kind: String) -> bool: return owned_state(m.state,kind)
static func owned_state(state: Dictionary, kind: String) -> bool:
 if kind in ["path","sign"]: return true
 var projects: Array = state.get("habitat_projects",[])
 var requests: Array = state.get("visitor_requests",[])
 return (kind == "reeds" and projects.has("shaded_pond")) or (kind == "bench" and (projects.has("living_workshop") or requests.has("woodland_visit"))) or (kind == "lamp" and projects.has("thermal_refuge")) or (kind == "flowers" and requests.has("sheltered_visit")) or (kind == "firefly" and (requests.has("evening_walk") or preload("res://scripts/ExpeditionRewards.gd").done_state(state,"river_link")))
static func ensure(m) -> void:
 if not m.state.has("sanctuary"): m.state.sanctuary = {"name":"My Sanctuary","decorations":{}}
static func snapshot(m) -> Array:
 var result := []
 for key in m.state.tiles:
  var tile: Dictionary = m.state.tiles[key]
  if tile.has("owner"): continue
  result.append({"at":key,"type":tile.type,"evolution":tile.evolution,"size":int(tile.size)})
 return result
static func remember_start(m) -> void:
 ensure(m)
 if m.state.tiles.size() == 4 and m.state.time == 0 and not m.state.sanctuary.has("before"): m.state.sanctuary.before = snapshot(m)
static func rename(m, text: String) -> bool:
 text = text.strip_edges()
 if text.is_empty() or text.length() > 32: return false
 for character in text:
  if character.unicode_at(0) < 32: return false
 ensure(m); m.state.sanctuary.name = text
 return true
static func decorate(m, at: String, kind: String) -> bool:
 if not m.state.tiles.has(at) or (kind != "" and (kind not in KINDS or not owned(m,kind))): return false
 ensure(m)
 if kind == "": m.state.sanctuary.decorations.erase(at)
 else: m.state.sanctuary.decorations[at] = kind
 return true
static func validate(store, s: Dictionary, config: Dictionary) -> bool:
 if not s.has("sanctuary"): return true
 var value = s.sanctuary
 if not value is Dictionary or value.size() not in [2,3] or not value.get("name") is String or value.name.strip_edges() != value.name or value.name.is_empty() or value.name.length() > 32: return false
 for field in value:
  if field not in ["name","decorations","before"]: return false
 for character in value.name:
  if character.unicode_at(0) < 32: return false
 if not value.get("decorations") is Dictionary or value.decorations.size() > 64: return false
 for at in value.decorations:
  if not store.coordinate(at) or not s.tiles.has(at) or value.decorations[at] not in KINDS or not owned_state(s,value.decorations[at]): return false
 if value.has("before"):
  if not value.before is Array or value.before.size() != 4: return false
  var seen := []
  for tile in value.before:
   if not tile is Dictionary or tile.size() != 4 or not store.coordinate(tile.get("at")) or seen.has(tile.at) or not config.tiles.has(tile.get("type")) or tile.get("evolution") != "" or tile.get("size") != 1: return false
   seen.append(tile.at)
 return true
static func draw(h) -> void:
 for at in h.model.state.get("sanctuary",{}).get("decorations",{}):
  var kind: String = h.model.state.sanctuary.decorations[at]
  var p: Vector2 = h.screen(h.model.coord(at))+Vector2(16,4)*h.zoom_level
  var s: float = h.zoom_level
  var still: bool = h.model.state.settings.reduced_motion or h.photo_mode or h.suspended
  if kind == "path":
   for i in range(4): h.draw_circle(p+Vector2(i*4-7,-i*2)*s,3*s,Color("bdbaa5"))
  elif kind == "sign":
   h.draw_line(p,p+Vector2(0,-20)*s,Color("796043"),3*s,true)
   h.draw_style_box(sign_style(),Rect2(p+Vector2(-10,-24)*s,Vector2(21,10)*s))
  elif kind == "reeds":
   for i in range(4):
    var sway := 0.0 if still else sin(h.ambient_time+i)*2
    h.draw_polyline(PackedVector2Array([p+Vector2(i*3,0)*s,p+Vector2(i*3-3+sway,-16-i%2*4)*s,p+Vector2(i*3+1+sway,-24)*s]),Color("9bb46c"),2*s,true)
  elif kind == "bench":
   for i in [-1,1]: h.draw_line(p+Vector2(i*8,-3)*s,p+Vector2(i*8,6)*s,Color("66523f"),3*s,true)
   h.draw_line(p+Vector2(-13,-5)*s,p+Vector2(13,-5)*s,Color("c5a16a"),5*s,true)
   h.draw_line(p+Vector2(-13,-13)*s,p+Vector2(13,-13)*s,Color("ae8957"),4*s,true)
  elif kind == "flowers":
   for i in range(7):
    var angle := TAU*i/7.0
    h.draw_circle(p+Vector2(cos(angle)*12,sin(angle)*6)*s,3*s,Color("dda7b7") if i%2 else Color("e7cc8e"))
  else:
   h.draw_line(p,p+Vector2(0,-21)*s,Color("726853"),2*s,true)
   h.draw_circle(p+Vector2(0,-22)*s,5*s,Color("e8c875"))
   if kind == "firefly":
    for i in range(4):
     var phase: float = i*1.7+(0 if still else h.ambient_time*0.7)
     h.draw_circle(p+Vector2(sin(phase)*18,-24+cos(phase)*9)*s,1.7*s,Color("eee5a1"))
static func sign_style() -> StyleBoxFlat:
 var style := StyleBoxFlat.new(); style.bg_color = Color("b59a6e"); style.set_corner_radius_all(2)
 return style
