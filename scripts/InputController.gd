extends RefCounted
signal tapped(position: Vector2)
signal inspected(position: Vector2)
signal panned(delta: Vector2)
signal zoomed(factor: float)
var pointers := {}
var start := Vector2.ZERO
var started := 0.0
var dragged := false
var pinched := false
const MOUSE := -1

func reset() -> void:
 pointers.clear()
 dragged = false
 pinched = false

func begin(id: int, position: Vector2, now: float) -> void:
 pointers[id] = position
 if pointers.size() == 1:
  start = position
  started = now
  dragged = false
  pinched = false
 else: pinched = true

func finish(id: int, position: Vector2, now: float, canceled: bool = false) -> void:
 if not pointers.has(id): return
 if pointers.size() == 1 and not dragged and not pinched and not canceled:
  if now-started >= 0.5: inspected.emit(position)
  else: tapped.emit(position)
 pointers.erase(id)

func move(id: int, position: Vector2) -> void:
 if not pointers.has(id): return
 if pointers.size() == 2:
  var ids = pointers.keys()
  var before: float = pointers[ids[0]].distance_to(pointers[ids[1]])
  pointers[id] = position
  var after: float = pointers[ids[0]].distance_to(pointers[ids[1]])
  if before > 1.0: zoomed.emit(after/before)
 elif pointers.size() == 1:
  if position.distance_to(start) > 12.0: dragged = true
  if dragged: panned.emit(position-pointers[id])
  pointers[id] = position

func feed(event: InputEvent, allowed: Rect2, now: float) -> void:
 # Controls need Godot's touch-to-mouse emulation. World gestures consume native
 # touches only, so the paired emulated mouse event must never create a second tap.
 if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION: return
 if event is InputEventScreenTouch:
  if event.pressed and allowed.has_point(event.position): begin(event.index,event.position,now)
  elif not event.pressed: finish(event.index,event.position,now,event.canceled)
 elif event is InputEventScreenDrag: move(event.index,event.position)
 elif event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_LEFT:
   if event.pressed and allowed.has_point(event.position): begin(MOUSE,event.position,now)
   elif not event.pressed: finish(MOUSE,event.position,now)
  elif event.pressed and allowed.has_point(event.position):
   if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoomed.emit(1.1)
   elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoomed.emit(0.9)
 elif event is InputEventMouseMotion: move(MOUSE,event.position)
