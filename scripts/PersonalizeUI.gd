extends RefCounted
const Identity = preload("res://scripts/SanctuaryIdentity.gd")
const Portrait = preload("res://scripts/SanctuaryPortrait.gd")
func show(h) -> void:
 var box: VBoxContainer = h.modal_content("Make this place yours")
 h.modal_screen = "personalize"
 var name := LineEdit.new(); name.text = Identity.name_of(h.model); name.max_length = 32; name.placeholder_text = "Sanctuary name"; name.custom_minimum_size.y = h.touch_height(); box.add_child(name)
 h.button("Save sanctuary name",func():
  var before: Dictionary = h.model.state.duplicate(true)
  if not Identity.rename(h.model,name.text): h.model.message = "Use a name of 1–32 visible characters."; h.refresh(); return
  if not h.store.save_state(h.model.state): h.model.state = before; h.model.message = "Save failed. Your previous name was kept."
  else: h.model.message = "Welcome to "+Identity.name_of(h.model)+"."
  h.refresh(),box)
 h.sheets.caption(h,"Decorations are free, earned, and separate from terrain. They use no land or care slots and never change yields or conditions. Select a plot on the island first; one decoration fits each plot.",box)
 var at: String = h.model.origin(h.selected)
 for kind in Identity.KINDS:
  var action: Button = h.button("Place "+Identity.NAMES[kind]+" on selected plot",func(): decorate(h,at,kind),box)
  action.disabled = not Identity.owned(h.model,kind)
  if action.disabled: h.sheets.caption(h,{"reeds":"Restore the spring.","bench":"Shelter the workshop or welcome Juniper's woodland visit.","lamp":"Restore the climate refuge.","flowers":"Welcome Sola's sheltered-garden visit.","firefly":"Restore River Link or welcome Clover's evening walk."}.get(kind,"Earn this decoration through restoration."),box)
 h.button("Remove selected decoration",func(): decorate(h,at,""),box)
 h.button("Before & after portraits",func(): portraits(h),box)
 h.button("Optional visitor requests",func(): h.visitor_requests.show_requests(h),box)
 h.campaign_ui.close_button(h,box)
func decorate(h, at: String, kind: String) -> void:
 var before: Dictionary = h.model.state.duplicate(true)
 if not Identity.decorate(h.model,at,kind): h.model.message = "Select a plot and earn that decoration first."; h.refresh(); return
 if not h.store.save_state(h.model.state): h.model.state = before; h.model.message = "Save failed. Your decoration layout was kept."
 else: h.model.message = "Decoration removed." if kind == "" else Identity.NAMES[kind]+" placed. Your habitat space is unchanged."
 h.modal.hide(); h.frame_world(); h.refresh()
func portraits(h) -> void:
 var box: VBoxContainer = h.modal_content(Identity.name_of(h.model))
 h.modal_screen = "sanctuary_portraits"
 var original: Array = h.model.state.get("sanctuary",{}).get("before",[])
 if original.is_empty(): h.sheets.caption(h,"A starting portrait was not recorded for this older island. Your current landscape is shown below.",box)
 else:
  h.label("Where your island began",19,box)
  var before := Portrait.new(); before.tiles = original; box.add_child(before)
 h.label("The world you shaped",19,box)
 var after := Portrait.new(); after.tiles = Identity.snapshot(h.model); box.add_child(after)
 h.button("Frame a shareable island photo",func(): h.modal.hide(); h.begin_photo(),box)
 h.campaign_ui.close_button(h,box)
