extends RefCounted
const Quest = preload("res://scripts/Expedition.gd")
const Board = preload("res://scripts/ExpeditionBoard.gd")
var selected := 4
var active_id := Quest.ID
var status := ""
var board: Control
var detail: Label
var actions: Array[Button] = []
func overview(h) -> void:
 var box: VBoxContainer = h.modal_content("Beyond your island")
 h.modal_screen = "expedition_map"
 h.sheets.caption(h,"Restore three islands with different environmental problems. Your home supplies stay safe; terrain changes are free and progress saves independently for each island.",box)
 var descriptions := {"dry_springs":"Reconnect thirsty trees to water and create shaded wetlands.","frost_hollow":"Use one heat source to warm two frozen Oaks. Too much warmth can spoil a grove.","ember_shore":"Cool overheated trees with water while volcanic air keeps warming them. Balance heat and moisture."}
 for id in Quest.ISLANDS:
  var card: VBoxContainer = h.sheets.card(box)
  h.label(Quest.NAMES[id],21,card)
  h.sheets.caption(h,descriptions[id],card)
  var saved: Dictionary = h.model.state.get("expeditions",{}).get(id,{})
  var title := "Revisit restored island" if saved.get("completed",false) else "Continue expedition" if not saved.is_empty() else "Begin expedition"
  var sail: Button = h.sheets.primary(h,title,func(): begin(h,id),card)
  sail.disabled = not Quest.unlocked(h.model,id)
  if sail.disabled:
   h.sheets.caption(h,"Discover your first home biome to unlock." if id == Quest.ID else "Restore %s to unlock." % Quest.NAMES[Quest.ISLANDS[Quest.ISLANDS.find(id)-1]],card)
  if saved.get("completed",false): h.sheets.caption(h,"RESTORED · Wildlife has returned",card)
 h.campaign_ui.close_button(h,box)
func begin(h, id: String = Quest.ID) -> void:
 if not Quest.unlocked(h.model,id): return
 active_id = id; selected = 4
 if not h.model.state.has("expeditions"): h.model.state.expeditions = {}
 if not h.model.state.expeditions.has(active_id): h.model.state.expeditions[active_id] = Quest.fresh(active_id)
 status = ""; save_progress(h); show_board(h)
func show_board(h) -> void:
 var s: Dictionary = h.model.state.expeditions[active_id]
 var box: VBoxContainer = h.modal_content("Expedition · "+Quest.NAMES[active_id])
 h.modal_screen = "expedition"
 h.label(Quest.goal(s),18,box)
 var p := Quest.progress(s)
 h.sheets.caption(h,"Water %d / %d · Groves %d / 2 · Habitats %d / 2 · Season %d" % [s.plots.count("water"),Quest.budget(s,"water"),p.groves,p.habitats,s.seasons],box)
 board = Board.new(); board.state = s; board.selected = selected; board.reduced = h.model.state.settings.reduced_motion
 box.add_child(board)
 board.plot_selected.connect(func(index): selected = index; update_selection(h))
 detail = h.label("",15,box)
 h.sheets.caption(h,Quest.instructions(s),box)
 actions.clear()
 if not s.completed:
  var controls := GridContainer.new(); controls.columns = 2; controls.add_theme_constant_override("h_separation",6); box.add_child(controls)
  var choices := ["water","flowers","meadow"]
  if active_id == "frost_hollow": choices.append("vent")
  for kind in choices:
   var action: Button = h.button(kind.capitalize(),func(): change(h,kind),controls)
   actions.append(action)
  h.button("Next season",func():
   Quest.advance(s); status = "The island responds to your layout."; save_progress(h); show_board(h),controls)
  if p.ready: h.sheets.primary(h,"Complete restoration",func(): complete(h),box)
 else:
  h.sheets.caption(h,"RESTORATION COMPLETE · Your layout supports two healthy groves and flowering wildlife habitats. Revisit this island from the Expeditions map.",box)
  h.sheets.primary(h,"Return to your home island",func(): leave(h),box)
 if status != "": h.sheets.caption(h,status,box)
 if not s.completed: h.button("Save & return home",func(): leave(h),box)
 update_selection(h)
func update_selection(h) -> void:
 var s: Dictionary = h.model.state.expeditions[active_id]
 if selected in Quest.trees(s):
  detail.text = "Oak · %d / 100 moisture · %d neighboring Water. %s" % [s.moisture[selected],Quest.count_near(s,selected,"water"),"A living grove." if Quest.healthy(s,selected) else "Bring water nearby, then advance seasons."]
 else:
  detail.text = "Plot %d · %s · %s" % [selected+1,str(s.plots[selected]).capitalize(),"A wildlife habitat!" if Quest.habitat(s,selected) else "Flowers need both Water and a living grove beside them."]
 if s.has("heat") and selected in Quest.trees(s):
  detail.text = "Oak · Moisture %d / 100 · Heat %d / 100. " % [s.moisture[selected],s.heat[selected]]
  detail.text += "A healthy grove." if Quest.healthy(s,selected) else "Needs 60–85 heat. Place a Vent nearby; Water can cool it." if active_id == "frost_hollow" else "Needs 35–65 heat and 70 moisture. Water cools and moistens; volcanic air warms each season."
 for action in actions: action.disabled = selected in Quest.trees(s) or (active_id == "ember_shore" and selected == 2)
 board.selected = selected; board.queue_redraw()
func change(h, kind: String) -> void:
 var s: Dictionary = h.model.state.expeditions[active_id]
 if not Quest.place(s,selected,kind): status = "Terrain limit reached or plot protected. Change an existing supply to Meadow to reuse it elsewhere."
 else: status = "Layout changed. Advance a season when you want to see the trees respond."
 save_progress(h); show_board(h)
func complete(h) -> void:
 var s: Dictionary = h.model.state.expeditions[active_id]
 if s.completed or not Quest.progress(s).ready: return
 s.completed = true
 if not h.store.save_state(h.model.state):
  s.completed = false; status = "Could not save restoration. Your layout is kept; try completing again."; show_board(h); return
 h.services.register_expedition_completion(active_id)
 h.services.event("expedition_completed",{"id":active_id,"seasons":s.seasons})
 status = Quest.NAMES[active_id]+" is alive again!"
 show_board(h)
func save_progress(h) -> bool:
 h.persist()
 if h.save_dirty:
  status = "Save failed. Your layout is kept in memory. Retry saving before closing the app."
  return false
 return true
func leave(h) -> void:
 if not save_progress(h):
  show_board(h)
  return
 h.modal.hide(); h.refresh(); h.check_transition_ad()
