extends RefCounted
# Short, interruptible, presentation-only responses. No simulation timers/rewards.
func bind_button(button: Button, reduced: Callable) -> void:
 button.button_down.connect(func():
  if not reduced.call(): animate(button,0.97,0.07))
 button.button_up.connect(func(): animate(button,1.0,0.14 if not reduced.call() else 0.0))
 button.visibility_changed.connect(func():
  if not button.visible:
   stop(button); button.scale = Vector2.ONE)

func stop(control: Control) -> void:
 var old = control.get_meta("response_tween") if control.has_meta("response_tween") else null
 if old is Tween and old.is_valid(): old.kill()

func animate(control: Control, factor: float, duration: float) -> void:
 stop(control)
 control.pivot_offset = control.size/2
 var tween := control.create_tween()
 control.set_meta("response_tween",tween)
 tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 tween.tween_property(control,"scale",Vector2.ONE*factor,duration)

func reveal(control: Control, reduced: bool) -> void:
 stop(control)
 control.modulate.a = 1.0
 if reduced: return
 control.modulate.a = 0.0
 var tween := control.create_tween()
 control.set_meta("response_tween",tween)
 tween.tween_property(control,"modulate:a",1.0,0.18)

func emphasize(control: Control, reduced: bool) -> void:
 if reduced: return
 stop(control)
 control.modulate = Color(1.18,1.15,1.3,1)
 var tween := control.create_tween()
 control.set_meta("response_tween",tween)
 tween.tween_property(control,"modulate",Color.WHITE,0.45)
