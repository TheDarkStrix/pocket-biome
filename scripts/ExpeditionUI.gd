extends RefCounted
const Quest = preload("res://scripts/Expedition.gd")
const Mastery = preload("res://scripts/ExpeditionMastery.gd")
const Rewards = preload("res://scripts/ExpeditionRewards.gd")
var variant := "relaxed"
const Board = preload("res://scripts/ExpeditionBoard.gd")
var selected := 4
var active_id := Quest.ID
var replaying := false
var status := ""
var board: Control
var detail: Label
var actions: Array[Button] = []
func overview(h) -> void:
 var box: VBoxContainer = h.modal_content("Beyond your island")
 h.modal_screen = "expedition_map"
 h.sheets.caption(h,"Restore islands with different environmental problems, then replay them with fresh attempts. Your home supplies stay safe; terrain changes are free and progress saves independently for each island.",box)
 var descriptions := {"dry_springs":"Reconnect thirsty trees to water and create shaded wetlands.","frost_hollow":"Use one heat source to warm two frozen Oaks. Too much warmth can spoil a grove.","ember_shore":"Cool overheated trees with water while volcanic air keeps warming them. Balance heat and moisture.","river_link":"Connect a spring to an outlet with a continuous river, then restore the surrounding habitats."}
 for id in Quest.ISLANDS:
  var card: VBoxContainer = h.sheets.card(box)
  h.label(Quest.NAMES[id],21,card)
  h.sheets.caption(h,descriptions[id],card)
  h.sheets.caption(h,("Earned home reward · " if Rewards.done(h.model,id) else "First restoration reward · ")+Rewards.DESCRIPTIONS[id],card)
  var saved: Dictionary = h.model.state.get("expeditions",{}).get(id,{})
  var title := "Revisit restored island" if saved.get("completed",false) else "Continue expedition" if not saved.is_empty() else "Begin expedition"
  var sail: Button = h.sheets.primary(h,title,func(): begin(h,id),card)
  sail.disabled = not Quest.unlocked(h.model,id)
  if sail.disabled:
   h.sheets.caption(h,"Discover your first home biome to unlock." if id == Quest.ID else "Restore %s to unlock." % Quest.NAMES[Quest.ISLANDS[Quest.ISLANDS.find(id)-1]],card)
  if saved.get("completed",false):
   h.sheets.caption(h,"RESTORED · Wildlife has returned",card)
   h.button("Replay challenge…",func(): replay_prompt(h,id),card)
   for challenge in Mastery.VARIANTS:
    var best: Dictionary = h.model.state.get("expedition_bests",{}).get(Mastery.key(id,challenge),{})
    h.button(Mastery.NAMES[challenge],func(): trial_prompt(h,id,challenge),card)
    if not best.is_empty(): h.sheets.caption(h,"Personal best · %d seasons · %d placements" % [best.seasons,best.moves],card)
    var trial: Dictionary = h.model.state.get("expedition_trials",{}).get(Mastery.key(id,challenge),{})
    if not trial.is_empty() and not trial.board.completed: h.button("Continue "+Mastery.NAMES[challenge],func(): begin(h,id,true,false,challenge),card)
   var attempt: Dictionary = h.model.state.get("expedition_attempts",{}).get(id,{})
   if not attempt.is_empty():
    h.sheets.caption(h,"Last replay completed in %d seasons" % attempt.seasons if attempt.completed else "A replay attempt is in progress.",card)
    if not attempt.completed: h.button("Continue replay",func(): begin(h,id,true),card)
 h.campaign_ui.close_button(h,box)
func record(h) -> Dictionary:
 if variant != "relaxed": return h.model.state.expedition_trials[Mastery.key(active_id,variant)].board
 return h.model.state["expedition_attempts" if replaying else "expeditions"][active_id]
func replay_prompt(h, id: String) -> void:
 var box: VBoxContainer = h.modal_content("Start a fresh replay?")
 h.sheets.caption(h,"Your original restoration record stays safe. This replaces any previous replay attempt for this island. Replays give no additional completion rewards or ad milestones.",box)
 h.sheets.primary(h,"Start replay",func(): begin(h,id,true,true),box)
 h.button("Keep current progress",func(): overview(h),box)
func trial_prompt(h, id: String, challenge: String) -> void:
 var box: VBoxContainer = h.modal_content(Mastery.NAMES[challenge])
 h.label(Mastery.RULES[challenge],17,box)
 h.sheets.caption(h,"Starting replaces this challenge's current attempt. Original restoration, other trials and personal bests stay safe. No extra home reward or ad milestone is granted.",box)
 h.sheets.primary(h,"Start fresh challenge",func(): begin(h,id,true,true,challenge),box)
 h.button("Keep current attempt",func(): overview(h),box)

func begin(h, id: String = Quest.ID, replay: bool = false, reset: bool = false, challenge: String = "relaxed") -> void:
 if not Quest.unlocked(h.model,id): return
 if replay and not h.model.state.get("expeditions",{}).get(id,{}).get("completed",false): return
 if challenge != "relaxed" and (challenge not in Mastery.VARIANTS or not replay): return
 active_id = id; selected = 4; replaying = replay; variant = challenge
 if variant != "relaxed":
  if not h.model.state.has("expedition_trials"): h.model.state.expedition_trials = {}
  var entry := Mastery.key(id,variant)
  if reset or not h.model.state.expedition_trials.has(entry): h.model.state.expedition_trials[entry] = Mastery.fresh(id,variant)
  status = ""; save_progress(h); show_board(h); return
 var field := "expedition_attempts" if replaying else "expeditions"
 if not h.model.state.has(field): h.model.state[field] = {}
 if reset or not h.model.state[field].has(active_id): h.model.state[field][active_id] = Quest.fresh(active_id)
 status = ""; save_progress(h); show_board(h)
func show_board(h) -> void:
 var s: Dictionary = record(h)
 var box: VBoxContainer = h.modal_content(("Replay · " if replaying else "Expedition · ")+Quest.NAMES[active_id])
 h.modal_screen = "expedition"
 if variant != "relaxed": h.sheets.caption(h,Mastery.NAMES[variant]+" · "+Mastery.RULES[variant],box)
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
 var s: Dictionary = record(h)
 if selected in Quest.trees(s):
  detail.text = "Oak · %d / 100 moisture · %d neighboring Water. %s" % [s.moisture[selected],Quest.count_near(s,selected,"water"),"A living grove." if Quest.healthy(s,selected) else "Bring water nearby, then advance seasons."]
 else:
  detail.text = "Plot %d · %s · %s" % [selected+1,str(s.plots[selected]).capitalize(),"A wildlife habitat!" if Quest.habitat(s,selected) else "Flowers need both Water and a living grove beside them."]
 if s.has("heat") and selected in Quest.trees(s):
  detail.text = "Oak · Moisture %d / 100 · Heat %d / 100. " % [s.moisture[selected],s.heat[selected]]
  detail.text += "A healthy grove." if Quest.healthy(s,selected) else "Needs 60–85 heat. Place a Vent nearby; Water can cool it." if active_id == "frost_hollow" else "Needs 35–65 heat and 70 moisture. Water cools and moistens; volcanic air warms each season."
 for action in actions: action.disabled = selected in Quest.trees(s) or (active_id == "ember_shore" and selected == 2) or (active_id == "river_link" and selected in [2,6])
 board.selected = selected; board.queue_redraw()
func change(h, kind: String) -> void:
 var s: Dictionary = record(h)
 var changed: bool = Quest.place(s,selected,kind) if variant == "relaxed" else Mastery.place(h.model.state.expedition_trials[Mastery.key(active_id,variant)],selected,kind)
 if not changed: status = "Terrain limit reached or plot protected. Change an existing supply to Meadow to reuse it elsewhere."
 else: status = "Layout changed. Advance a season when you want to see the trees respond."
 save_progress(h); show_board(h)
func complete(h) -> void:
 var s: Dictionary = record(h)
 if s.completed or not Quest.progress(s).ready: return
 if variant != "relaxed":
  var before: Dictionary = h.model.state.duplicate(true)
  var trial: Dictionary = h.model.state.expedition_trials[Mastery.key(active_id,variant)]
  var qualified: bool = Mastery.qualified(trial)
  if not Mastery.finish(h.model,active_id,variant): return
  if not h.store.save_state(h.model.state): h.model.state = before; status = "Save failed. Your attempt and best were kept."; show_board(h); return
  status = "Personal best recorded when improved." if qualified else "Restored as practice. Try again within four seasons for the challenge."
  show_board(h); return
 s.completed = true
 if not h.store.save_state(h.model.state):
  s.completed = false; status = "Could not save restoration. Your layout is kept; try completing again."; show_board(h); return
 if not replaying: h.services.register_expedition_completion(active_id)
 h.services.event("expedition_replay_completed" if replaying else "expedition_completed",{"id":active_id,"seasons":s.seasons})
 status = Quest.NAMES[active_id]+" is alive again!"+(" Home reward earned: "+Rewards.DESCRIPTIONS[active_id] if not replaying else "")
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
