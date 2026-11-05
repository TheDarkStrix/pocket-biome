extends RefCounted
const Projects = preload("res://scripts/HabitatProjects.gd")
const NAMES = {"shaded_pond":"Clover the frog","pollinator_patch":"Sola the butterfly","living_workshop":"Juniper the woodland bird","thermal_refuge":"The shelter flock","sanctuary_network":"Evening fireflies"}
static func routes(m) -> Array:
 var result := []
 for visitor in Projects.visitors(m):
  var habitat := Projects.inspect(m,visitor.id)
  var stops := [habitat.anchor]
  for cell in habitat.cells:
   if not stops.has(cell) and (Projects.tree(m.state.tiles[cell]) or m.state.tiles[cell].type in ["water","fiber","workbench"]): stops.append(cell)
  result.append({"id":visitor.id,"name":NAMES[visitor.id],"stops":stops,"count":visitor.count})
 return result
static func position(route: Dictionary, canvas, clock: float, still: bool) -> Vector2:
 var stops: Array = route.stops
 if stops.is_empty(): return Vector2.ZERO
 var at: Vector2 = canvas.entity_screen(stops[0])
 if still or stops.size() == 1: return at
 var phase := fposmod(clock*0.12,stops.size())
 var index := int(phase); var next := (index+1)%stops.size()
 # Ease between actual habitat cells; changed layouts replace the route on refresh.
 var t := smoothstep(0.15,0.85,fmod(phase,1.0))
 return canvas.entity_screen(stops[index]).lerp(canvas.entity_screen(stops[next]),t)
static func notes(m) -> Array:
 var result := [{"title":"A thirsty beginning","body":"A small Oak waits among the clouds. Every restored place can become a home."}]
 for id in m.state.get("habitat_projects",[]):
  result.append({"title":NAMES[id],"body":preload("res://scripts/RestorationMoment.gd").STORIES[id]+(" Your habitat is suitable now." if Projects.inspect(m,id).ready else " The visitor will return when its habitat is suitable again.")})
 var river = preload("res://scripts/LivingCorridors.gd")
 for stage in river.record(m).get("ledger",[]):
  result.append({"title":{"grove":"The river reaches the roots","wings":"Sola finds a way through","bloom":"The Living Heart"}[stage],"body":{"grove":"You carried a limited spring to a remote grove. Living shelter changed how the Water could be shared.","wings":"Sola reached the flowers through your mature grove. Your choice of wetland or woodland shaped this route.","bloom":"A dormant corner bloomed through the habitats you connected. Your Living Heart remembers; new seedbeds can still be restored."}[stage]})
 return result
func show_notes(h) -> void:
 var box: VBoxContainer = h.modal_content("Visitors & field notes")
 h.modal_screen = "field_notes"
 for note in notes(h.model):
  var card: VBoxContainer = h.sheets.card(box)
  h.label(note.title,20,card); h.sheets.caption(h,note.body,card)
 h.button("Review visitor preferences",func(): h.habitat_ui.show_projects(h),box)
 h.campaign_ui.close_button(h,box)
