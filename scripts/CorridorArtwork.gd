extends RefCounted
const River = preload("res://scripts/LivingCorridors.gd")
static func draw(h) -> void:
 if h.launch_menu: return
 var s: Dictionary = River.record(h.model)
 var still: bool = h.model.state.settings.reduced_motion or h.photo_mode or h.suspended
 var clock: float = 0.0 if still else h.ambient_time
 if not s.is_empty():
  var flow := River.delivered(h.model)
  for role in River.ROLES:
   var route: Dictionary = s.routes.get(role,{})
   if route.is_empty(): continue
   var valid: bool = River.role_valid(h.model,role,route.path)
   var colour := Color("88cddd") if flow[role] > 0 and valid else Color("b89473")
   var points := PackedVector2Array()
   for cell in route.path: points.append(h.screen(h.model.coord(cell)))
   h.draw_polyline(points,Color(0.08,0.17,0.18,0.65),7*h.zoom_level,true)
   h.draw_polyline(points,colour,3*h.zoom_level,true)
   for point in points: h.draw_circle(point,3*h.zoom_level,colour)
   if flow[role] > 0 and valid and points.size() >= 2:
    for drop in range(int(flow[role])):
     var progress := fposmod(clock*0.55+drop*0.45,points.size()-1)
     var index := mini(int(progress),points.size()-2)
     h.draw_circle(points[index].lerp(points[index+1],fmod(progress,1.0)),3*h.zoom_level,Color("e1f4df"))
   var tip: Vector2 = points[-1]+Vector2(0,-18)*h.zoom_level
   h.draw_string(ThemeDB.fallback_font,tip-Vector2(9,0),"%d" % int(flow[role]),HORIZONTAL_ALIGNMENT_LEFT,-1,15,colour)
  var garden: String = River.end_of(h.model,"garden")
  var grove: String = River.end_of(h.model,"grove")
  if int(s.growth.grove) >= 2 and grove != "":
   var at: Vector2 = h.entity_screen(h.model.origin(grove))
   for bud in range(4):
    var phase: float = bud*TAU/4.0
    h.draw_circle(at+Vector2(cos(phase)*25,-16+sin(phase)*9)*h.zoom_level,3*h.zoom_level,Color("b5cd78"))
  if int(s.growth.garden) >= 1 and garden != "" and grove != "":
   var path: Array = s.routes.get("garden",{}).get("path",[])
   var stops := []
   var after_grove := false
   for cell in path:
    if h.model.origin(cell) == h.model.origin(grove): after_grove = true
    if after_grove: stops.append(h.screen(h.model.coord(cell)))
   if stops.size() >= 2:
    var progress := fposmod(clock*0.3,stops.size()-1)
    var index := mini(int(progress),stops.size()-2)
    var at: Vector2 = stops[index].lerp(stops[index+1],fmod(progress,1.0))
    preload("res://scripts/HabitatProjects.gd").draw_visitor(h,"pollinator_patch",at,h.zoom_level,clock,still)
  if s.seedbed != "":
   var at: Vector2 = h.screen(h.model.coord(s.seedbed))
   h.draw_plot_outline(at,h.zoom_level,Color("e7bd87"),2)
   if int(s.growth.bloom) > 0:
    for flower in range(6):
     var phase: float = flower*TAU/6
     h.draw_circle(at+Vector2(cos(phase)*21,sin(phase)*9)*h.zoom_level,3*h.zoom_level,Color("e6bdc9"))
  if s.ledger.size() > 0 and h.model.state.tiles.has("0,0"):
   var heart: Vector2 = h.entity_screen("0,0")+Vector2(0,-26)*h.zoom_level
   for leaf in range(s.ledger.size()*3):
    var phase: float = TAU*leaf/9+clock*0.06
    var at: Vector2 = heart+Vector2(cos(phase)*30,sin(phase)*12)*h.zoom_level
    h.draw_circle(at,3.5*h.zoom_level,Color("b9db9c") if s.branch == "woodland" else Color("96d4d3"))
    if s.ledger.has("bloom"): h.draw_circle(at,6*h.zoom_level,Color(0.9,0.85,0.6,0.13))
 if h.corridor_ui.active():
  for cell in h.model.state.tiles:
   if River.passable(h.model,cell): h.draw_plot_outline(h.screen(h.model.coord(cell)),h.zoom_level,Color(0.61,0.76,0.68,0.5),1)
  var points := PackedVector2Array()
  for cell in h.corridor_ui.draft: points.append(h.screen(h.model.coord(cell)))
  if points.size() > 1: h.draw_polyline(points,Color("f3dda1"),4*h.zoom_level,true)
  for at in points: h.draw_circle(at,5*h.zoom_level,Color("f3dda1"))
