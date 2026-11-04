extends RefCounted
const Care = preload("res://scripts/RestorationCare.gd")
var status := ""
func show_tools(h) -> void:
 var box: VBoxContainer = h.modal_content("Care for your island")
 h.modal_screen = "restoration_care"
 var at: String = h.model.origin(h.selected)
 h.sheets.caption(h,"Select land on your island, then place an earned care tool here. Reassigning and removing tools is free. Effects happen every four active seconds; they do not reset harvest or production timers.",box)
 if at != "": h.label("Selected · "+h.tile_title(h.model.state.tiles[at]),19,box)
 for mode in Care.MODES:
  var card: VBoxContainer = h.sheets.card(box)
  h.label(Care.NAMES[mode],20,card)
  h.sheets.caption(h,Care.HELP[mode],card)
  if not Care.unlocked(h.model,mode):
   h.sheets.caption(h,"Unlock by restoring "+preload("res://scripts/HabitatProjects.gd").NAMES[Care.REQUIRED[mode]]+".",card)
   continue
  var places: Array = Care.targets(h.model,mode)
  h.sheets.caption(h,"%d / %d placed" % [places.size(),Care.capacity(h.model)],card)
  for cell in places:
   var active: bool = h.model.origin(cell) != "" and Care.natural(h.model,cell) and (mode != "channel" or Care.water_source(h.model,cell) != "")
   h.sheets.caption(h,"Plot %s · %s" % [cell,"working" if active else "dormant; restore natural land and its water connection"],card)
   h.button("Remove %s at %s" % [Care.NAMES[mode],cell],func(): commit(h,mode,cell,-1),card)
  for slot in range(Care.capacity(h.model)):
   if slot > places.size(): break
   var action: Button = h.button(("Place" if slot >= places.size() else "Move")+" %s here · slot %d" % [Care.NAMES[mode],slot+1],func(): confirm(h,mode,at,slot),card)
   action.disabled = not Care.can_assign(h.model,mode,at) or places.has(at)
  if not Care.can_assign(h.model,mode,at): h.sheets.caption(h,"Choose natural land without active Pulse/Dusk effects. Water channels also need nearby Water. Finish a saved draft first.",card)
 if status != "": h.sheets.caption(h,status,box)
 h.button("Review restoration projects",func(): h.habitat_ui.show_projects(h),box)
 h.campaign_ui.close_button(h,box)
func confirm(h, mode: String, at: String, slot: int) -> void:
 var box: VBoxContainer = h.modal_content("Place "+Care.NAMES[mode]+"?")
 h.sheets.caption(h,Care.HELP[mode]+"\nThis uses slot %d and replaces its previous location. No materials or energy are charged. Past environmental changes are not reversed when you remove it." % (slot+1),box)
 h.sheets.primary(h,"Confirm placement",func(): commit(h,mode,at,slot),box)
 h.button("Keep current layout",func(): show_tools(h),box)
func commit(h, mode: String, at: String, slot: int) -> void:
 var before: Dictionary = h.model.state.duplicate(true)
 var changed: bool = Care.remove(h.model,mode,at) if slot < 0 else Care.assign(h.model,mode,at,slot)
 if not changed: status = "That layout changed. Select a suitable plot and try again."
 elif not h.store.save_state(h.model.state):
  h.model.state = before; status = "Save failed. Your previous care layout was kept."
 else: status = h.model.message
 h.refresh(); show_tools(h)
