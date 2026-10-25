extends RefCounted
signal tapped(position: Vector2)
signal inspected(position: Vector2)
signal panned(delta: Vector2)
signal zoomed(factor: float)
signal rotated(steps: int)
var twist := 0.0
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
 twist = 0.0

func begin(id: int, position: Vector2, now: float) -> void:
 pointers[id] = position
 if pointers.size() == 1:
  start = position
  started = now
  dragged = false
  pinched = false
 else:
  pinched = true
  twist = 0.0

func finish(id: int, position: Vector2, now: float, canceled: bool = false) -> void:
 if not pointers.has(id): return
 if pointers.size() == 1 and not dragged and not pinched and not canceled:
  if now-started >= 0.5: inspected.emit(position)
  else: tapped.emit(position)
 pointers.erase(id)

func move(id: int, position: Vector2) -> void:
 if not pointers.has(id): return
 if pointers.size() > 2:
  pointers[id] = position
  twist = 0.0
  return
 if pointers.size() == 2:
  var ids = pointers.keys()
  var before_vector: Vector2 = pointers[ids[1]]-pointers[ids[0]]
  var before: float = before_vector.length()
  pointers[id] = position
  var after_vector: Vector2 = pointers[ids[1]]-pointers[ids[0]]
  var after: float = after_vector.length()
  if before > 24 and after > 24:
   twist += wrapf(after_vector.angle()-before_vector.angle(),-PI,PI)
   if absf(twist) >= PI/3:
    var step := 1 if twist > 0 else -1
    twist -= step*PI/2
    rotated.emit(step)
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
