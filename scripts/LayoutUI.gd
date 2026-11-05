extends RefCounted
const Tools = preload("res://scripts/LayoutTools.gd")
var source := ""
var opening_confirmation := false
var source_id := -1
var destination := ""
func cancel(h) -> void:
 source = ""; destination = ""; source_id = -1
 h.model.message = "Move canceled. The structure has not changed."
 h.refresh()
func begin(h, at: String) -> void:
 if not Tools.movable(h.model,at):
  h.model.message = "Finish your saved draft or wait for active effects before moving this structure."; h.refresh(); return
 source = at; source_id = h.model.state.tiles[at].id; destination = ""
 h.placement_blueprint = ""; h.targeting = ""; h.fusion_preview.clear()
 h.modal.hide(); h.frame_world()
 h.model.message = "Choose empty Meadow for this tile. You will confirm before it moves."
 h.refresh()
func choose(h, at: String) -> void:
 if not Tools.can_move(h.model,source,at):
  h.model.message = "Choose empty Grass outside active effects. Your tile stays in place."; h.refresh(); return
 destination = at
 opening_confirmation = true
 var box: VBoxContainer = h.modal_content("Move this tile?")
 opening_confirmation = false
 h.modal_screen = "move_confirm"
 h.sheets.art(h,box,h.model.state.tiles[source].type,h.model.state.tiles[source].evolution,140)
 h.label("Conditions, level, cooldowns, production schedule and pause state stay unchanged. The original plot becomes Meadow. No materials or Coins are charged.",16,box)
 h.sheets.caption(h,"Nearby production and habitats will follow the new location.",box)
 h.label(preload("res://scripts/EcologyDirector.gd").consequences(h.model,"",at,source),15,box)
 h.sheets.primary(h,"Confirm move",func(): confirm(h),box)
 h.button("Choose another plot",func(): h.modal.hide(),box)
 h.button("Cancel move",func(): h.modal.hide(); cancel(h),box)
func confirm(h) -> void:
 if h.model.state.tiles.get(source,{}).get("id",-1) != source_id:
  h.modal.hide(); cancel(h); return
 var before: Dictionary = h.model.state.duplicate(true)
 if not Tools.move(h.model,source,destination):
  h.model.message = "The destination changed. Choose empty Grass again."; h.modal.hide(); h.refresh(); return
 if not h.store.save_state(h.model.state):
  h.model.state = before; h.model.message = "Save failed. The structure was not moved. Retry when saving works."; h.refresh(); return
 if h.presentation.motor_times.has(source):
  h.presentation.motor_times[destination] = h.presentation.motor_times[source]
  h.presentation.motor_times.erase(source)
 var moved_to := destination
 source = ""; destination = ""; source_id = -1
 h.selected = moved_to; h.modal.hide(); h.refresh()
func dismantle_prompt(h, at: String) -> void:
 var box: VBoxContainer = h.modal_content("Dismantle this sanctuary?")
 h.modal_screen = "dismantle_confirm"
 h.label("This replaces the sanctuary with four Meadow plots. Any original harvest nodes in its footprint are restored instead. Discoveries and earned rewards remain; no materials are refunded. You can craft new terrain on the recovered land.",16,box)
 var identity: int = h.model.state.tiles[at].id
 var commit: Button = h.sheets.primary(h,"Dismantle and recover plots",func():
  var before: Dictionary = h.model.state.duplicate(true)
  if h.model.state.tiles.get(at,{}).get("id",-1) != identity or not Tools.dismantle(h.model,at):
   h.model.message = "This sanctuary changed or is affected by an active event. Review it again."; h.modal.hide(); h.refresh(); return
  if not h.store.save_state(h.model.state):
   h.model.state = before; h.model.message = "Save failed. The sanctuary was kept."; h.refresh(); return
  h.modal.hide(); h.refresh(),box)
 commit.disabled = not Tools.can_dismantle(h.model,at)
 if commit.disabled: h.sheets.caption(h,"Finish your saved land draft or wait for Pulse/Dusk effects before dismantling.",box)
 h.button("Keep sanctuary",func(): h.modal.hide(),box)
