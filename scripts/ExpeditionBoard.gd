extends Control
const Quest = preload("res://scripts/Expedition.gd")
const Art = preload("res://scripts/WorldAmbience.gd")
signal plot_selected(index: int)
var state: Dictionary
var selected := 4
var reduced := false
var clock := 0.0
var redraw_clock := 0.0
func _ready() -> void:
 custom_minimum_size = Vector2(0,285)
 mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 focus_mode = Control.FOCUS_ALL
 tooltip_text = "Choose a plot. Arrow keys move selection; terrain buttons change it."
func _process(delta: float) -> void:
 if reduced or not is_visible_in_tree(): return
 clock += minf(delta,0.1); redraw_clock += delta
 if redraw_clock >= 1.0/30:
  redraw_clock = 0; queue_redraw()
func unit() -> float: return clampf((size.x-28)/300.0,0.1,1.0)
func center(index: int) -> Vector2:
 var u := unit()
 return Vector2(size.x/2+(index%3-index/3)*49*u,145+(index%3+index/3)*24*u)
func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  var best := -1; var distance := INF
  for i in range(9):
   var offset: Vector2 = event.position-center(i)
   var diamond := absf(offset.x)/(49*unit())+absf(offset.y)/(24*unit())
   if diamond <= 1.1 and diamond < distance: best = i; distance = diamond
  if best >= 0: selected = best; plot_selected.emit(best); queue_redraw(); accept_event()
 if event is InputEventKey and event.pressed:
  var next := selected
  if event.keycode == KEY_LEFT: next = maxi(0,selected-1)
  elif event.keycode == KEY_RIGHT: next = mini(8,selected+1)
  elif event.keycode == KEY_UP: next = maxi(0,selected-3)
  elif event.keycode == KEY_DOWN: next = mini(8,selected+3)
  else: return
  selected = next; plot_selected.emit(next); queue_redraw(); accept_event()
func _draw() -> void:
 if state.is_empty(): return
 var u := unit()
 for diagonal in range(5):
  for i in range(9):
   if i%3+i/3 != diagonal: continue
   var kind: String = state.plots[i]
   var type := "oak" if kind == "oak" else "water" if kind == "water" else "grass" if kind == "flowers" else "vent" if kind == "vent" else "dirt"
   var evolution := "rainforest" if kind == "oak" and Quest.healthy(state,i) else ""
   var tint := Color("d3e7ff") if Quest.island(state) == "frost_hollow" and kind != "vent" else Color("ffdcbd") if Quest.island(state) == "ember_shore" else Color.WHITE
   if kind == "oak" and not Quest.healthy(state,i) and state.has("heat"): evolution = "frozen" if Quest.island(state) == "frost_hollow" else "ember"
   Art.draw_tile(self,type,center(i),98.0/418*u,tint,evolution,false,clock,i,reduced)
   if kind == "vent": Art.draw_effects(self,{"type":"vent","evolution":"","id":i},center(i),u*0.7,clock,reduced)
   if kind == "water": Art.draw_effects(self,{"type":"water","evolution":"","id":i},center(i),u*0.7,clock,reduced)
   if kind == "flowers": Art.draw_meadow(self,center(i),u*0.85,0 if reduced else clock,i)
   if state.completed and Quest.habitat(state,i):
    var at := center(i)+Vector2(12,-6)*u
    if not reduced: at.y -= maxf(0,sin(clock*1.8+i))*3*u
    draw_circle(at,4*u,Color("72a955"))
    for side in [-1,1]:
     draw_circle(at+Vector2(side*2,-3)*u,2*u,Color("b5d47a"))
     draw_circle(at+Vector2(side*2,-3)*u,0.8*u,Color("213729"))
 var outline := PackedVector2Array()
 for point in [Vector2(0,-24),Vector2(49,0),Vector2(0,24),Vector2(-49,0),Vector2(0,-24)]: outline.append(center(selected)+point*u)
 draw_polyline(outline,Color("fff0a3"),2,true)
