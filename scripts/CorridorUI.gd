extends RefCounted
const River = preload("res://scripts/LivingCorridors.gd")
var mode := ""
var draft: Array = []
var opening_confirmation := false
var pointers := {}
var mouse_down := false
var last_pointer := Vector2.ZERO
var undo_layout := {}
var undo_season := -1
var bar: VBoxContainer
var caption: Label
var back: Button
var preview: Button
var moment := false
var signature := ""
var feedback := ""
var invalid_cell := ""
var options: Array = []
var fitted_height := -1.0
func active() -> bool: return mode != ""
func showing() -> bool: return active() or moment
func build(h) -> void:
 bar = VBoxContainer.new(); bar.add_theme_constant_override("separation",4); h.ui_root.add_child(bar)
 var title_panel := PanelContainer.new(); title_panel.add_theme_stylebox_override("panel",preload("res://scripts/GameTheme.gd").floating(Color("233b3b"),10)); bar.add_child(title_panel)
 caption = h.label("",14,title_panel); caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var row := HBoxContainer.new(); row.add_theme_constant_override("separation",4); bar.add_child(row)
 back = h.button("Back one",func():
  if mode=="grove" and options.is_empty():setup_help(h)
  elif active() and draft.size() > 1: draft.pop_back(); feedback=""; h.queue_redraw(); layout(h)
  else: show(h),row)
 preview = h.button("Preview",func():
  if active(): confirm_route(h)
  else: observe(h),row)
 h.button("Close",func(): cancel(h),row)
 bar.hide()
func layout(h) -> void:
 if not is_instance_valid(bar): return
 bar.visible = showing() and not h.modal.visible and not h.launch_menu and not h.photo_mode
 bar.size = Vector2(h.layout.world.size.x-16,0)
 bar.position = Vector2(h.layout.world.position.x+8,h.layout.world.end.y-bar.get_combined_minimum_size().y-8)
 if showing() and absf(fitted_height-bar.get_combined_minimum_size().y)>1:
  fitted_height=bar.get_combined_minimum_size().y;h.call_deferred("frame_world")
 if active():
  caption.text = feedback if feedback!="" else "Step 1 · Tap a blue Water plot" if mode=="source" else "Choose bare Meadow near the garden" if mode=="seedbed" else "No reachable grove · build Forest and connect natural land" if mode=="grove" and options.is_empty() else "Step 2 · Tap a highlighted tree or draw a channel" if mode=="grove" and draft.size()==1 else "Draw through the grove to Fiber or soil" if mode=="garden" and draft.size()==1 else "Channel preview · %d / 12 plots · tap Preview" % draft.size()
  back.text = "Build grove" if mode=="grove" and options.is_empty() else "Review" if mode=="source" else "Back one"; back.disabled = draft.size()<=1 and mode!="source" and not (mode=="grove" and options.is_empty())
  preview.text = "Preview"; preview.disabled = mode not in River.ROLES or not River.role_valid(h.model,mode,draft)
 else:
  var stage: Dictionary = River.status(h.model)
  caption.text = stage.title+" · season %d" % River.record(h.model).get("season",0)
  back.text = "Review"; back.disabled = false; preview.text = "Observe season"; preview.disabled = false
func cancel_pointer() -> void: pointers.clear(); mouse_down = false
func cancel(h, tell: bool = true) -> void:
 var finished: bool = moment and River.earned(h.model)
 mode = ""; draft.clear(); moment = false; invalid_cell=""; options.clear(); cancel_pointer()
 fitted_height=-1
 if tell:feedback=""
 if is_instance_valid(bar): bar.hide()
 if tell: h.model.message = "River planning closed. Your saved routes and supplies are kept."; h.refresh()
 if tell and finished: h.check_transition_ad("river")
func begin(h, role: String) -> void:
 feedback="";invalid_cell=""
 if not River.unlocked(h.model):
  feedback="Restore the Returning Spring habitat to unlock your river.";show(h);return
 if River.record(h.model).get("branch","") not in River.BRANCHES:
  feedback="Choose an approach first, then mark an existing Water spring.";show(h);return
 if role in River.ROLES and River.tile(h.model,River.record(h.model).get("source","")).get("type","")!="water":
  begin(h,"source");return
 h.modal.hide();h.input_controller.reset();h.layout_ui.source="";h.placement_blueprint="";h.targeting="";h.fusion_preview.clear()
 mode=role;draft=[River.record(h.model).source] if role in River.ROLES else [];moment=false;cancel_pointer()
 h.frame_world();h.model.message="Tap a blue Water plot." if role=="source" else "Tap a highlighted tree to preview a channel, or trace it across natural land."
 options=River.grove_options(h.model) if role=="grove" else []
 h.refresh();layout(h)
 if role=="grove" and options.is_empty():setup_help(h)
func setup_help(h) -> void:
 opening_confirmation=true
 var box: VBoxContainer=h.modal_content("Your river needs a connected grove")
 opening_confirmation=false;h.modal_screen="corridor_setup"
 h.label("Your spring is selected. Build a Forest at least two edges away and connect it with Meadow, plants or Water.",17,box)
 h.sheets.caption(h,"Stone and machines block the channel. You can choose another spring or extend the land. Your source, saved cards and earned progress stay yours.",box)
 var has_workbench: bool=h.model.campaign.has_structure(h.model,"workbench")
 var saved_forest: bool=h.model.state.pending.get("cards",[]).has("forest")
 if saved_forest:
  h.sheets.primary(h,"Use the Forest in my saved cards",func():
   cancel(h,false);h.draft();h.draft_hand.choose(h.model.state.pending.cards.find("forest")),box)
  h.button("Build a Forest" if has_workbench else "Build a Workbench",func():h.choose_idea({"action":"recipe","target":"forest" if has_workbench else "workbench"}),box)
 else:h.sheets.primary(h,"Build a Forest" if has_workbench else "Build a Workbench",func():h.choose_idea({"action":"recipe","target":"forest" if has_workbench else "workbench"}),box)
 h.button("Use my saved land cards" if not h.model.state.pending.is_empty() else "Explore another land plot",func():
  cancel(h,false);h.modal.hide();h.frame_world();h.refresh()
  if not h.model.state.pending.is_empty():h.draft()
  else:h.model.message="Tap a cloud to extend the river bank.";h.refresh(),box)
 h.button("Choose another spring",func():begin(h,"source"),box)
 h.button("Show my spring and land",func():h.modal.hide();h.frame_world();h.refresh();layout(h),box)
func fail(h, text: String) -> void:
 feedback=text;h.model.message=text;h.refresh();layout(h)
 if h.modal.visible and h.modal_screen=="corridors":show(h)
func remember_layout(h) -> void:
 var s: Dictionary = River.record(h.model)
 undo_layout = s.duplicate(true); undo_season = int(s.get("season",0))
func commit(h, action: Callable) -> bool:
 var before: Dictionary = h.model.state.duplicate(true)
 var old_layout: Dictionary = River.record(h.model).duplicate(true)
 if not action.call(): h.model.state=before;fail(h,"That plan no longer fits. Check the selected spring, connected plots and available flow."); return false
 if not h.store.save_state(h.model.state):
  h.model.state = before; fail(h,"Save failed. Your previous river and progress were kept. Try saving again."); return false
 feedback=""
 h.model.message="River plan saved. Review flow or observe a season to grow your island."
 undo_layout = old_layout; undo_season = int(River.record(h.model).get("season",0))
 h.playtest.record("river_layout_saved",{"type":River.record(h.model).get("branch","")})
 h.refresh(); return true
func show(h) -> void:
 cancel(h,false)
 var box: VBoxContainer = h.modal_content("The Living River")
 h.modal_screen = "corridors"
 var status: Dictionary = River.status(h.model)
 if feedback!="":h.label(feedback,17,box)
 if not h.model.state.pending.is_empty():h.sheets.caption(h,"Your land cards and quoted price stay saved while you plan this river.",box)
 h.label(status.title if River.unlocked(h.model) else "Restore the Returning Spring first",20,box)
 h.sheets.caption(h,status.body if River.unlocked(h.model) else "Complete your first spring habitat to unlock river planning.",box)
 if not River.unlocked(h.model):
  h.sheets.primary(h,"Restore the first spring",func(): h.habitat_ui.show_projects(h),box)
  h.campaign_ui.close_button(h,box); return
 var s: Dictionary = River.record(h.model)
 if s.get("branch","") == "":
  h.sheets.caption(h,"Two approaches lead to one living sanctuary. Your choice changes the water supply and the garden's requirements.",box)
  for branch in River.BRANCHES:
   var card: VBoxContainer = h.sheets.card(box)
   h.label(River.NAMES[branch],19,card)
   h.sheets.caption(h,"Four spring flow. Flowers need neighboring Water; the dry spell leaves three flow." if branch == "wetland" else "Three spring flow. A tree beside your grove reduces its water demand; the garden needs two healthy tree neighbors. Living shelter also buffers the forecast warmth.",card)
   h.sheets.primary(h,"Choose "+River.NAMES[branch],func():
    if commit(h,func(): return River.choose_branch(h.model,branch)): begin(h,"source"),card)
  h.campaign_ui.close_button(h,box); signature = current_signature(h); return
 var flow: Dictionary = River.delivered(h.model)
 h.label("Spring supply · %d flow%s" % [River.budget(h.model)," · dry spell" if River.dry(h.model) else ""],17,box)
 h.sheets.caption(h,"Forecast · A dry spell begins when the grove matures: one less flow"+(" and warmer routed land" if h.model.state.get("ecology_rules","classic") == "balanced" else " (Classic climate keeps ordinary heat)")+". It passes when the flowering corner is restored. Seasons advance only when you choose; harvest and machine timers stay ordinary.",box)
 for role in River.ROLES:
  var route: Dictionary = s.routes.get(role,{})
  if route.is_empty(): continue
  var row := HBoxContainer.new(); box.add_child(row)
  var demand: int = River.grove_demand(h.model) if role == "grove" else 1
  var label: Label = h.label("%s · %d delivered / %d needed" % [role.capitalize(),flow[role],demand],14,row); label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  var minus: Button = h.button("−",func():
   if commit(h,func(): return River.allocate(h.model,role,maxi(0,int(route.water)-1))): show(h),row)
  var plus: Button = h.button("+",func():
   if commit(h,func(): return River.allocate(h.model,role,int(route.water)+1)): show(h),row)
  for button in [minus,plus]: button.custom_minimum_size.x = h.touch_height(); button.size_flags_horizontal = Control.SIZE_SHRINK_END
  minus.disabled = route.water <= 0
  var requested := 0
  for item in s.routes.values(): requested += int(item.water)
  plus.disabled = route.water >= 3 or requested >= River.base_budget(h.model)
  var plant: Dictionary = River.tile(h.model,River.end_of(h.model,role))
  h.sheets.caption(h,"Requested %d · growth %d / 2 · moisture %d · fertility %d · heat %d" % [route.water,s.growth[role],plant.dna.moisture,plant.dna.fertility,plant.dna.heat],box)
 if s.seedbed != "":
  var soil: Dictionary = River.tile(h.model,s.seedbed)
  h.sheets.caption(h,"Seedbed · %s · growth %d / 2\nMoisture %d / 50 · fertility %d / 80 · heat %d / at most 65" % [s.seedbed,s.growth.bloom,soil.dna.moisture,soil.dna.fertility,soil.dna.heat],box)
 var observe: Button = h.sheets.primary(h,"Observe next season",func(): observe(h),box)
 observe.disabled = not s.routes.has("grove")
 var tools := GridContainer.new(); tools.columns = 2; box.add_child(tools)
 h.button("Choose spring",func(): begin(h,"source"),tools)
 h.button("Trace grove route",func(): begin(h,"grove"),tools)
 h.button("Trace flower route",func(): begin(h,"garden"),tools)
 h.button("Choose seedbed",func(): begin(h,"seedbed"),tools).disabled = not s.routes.has("garden")
 h.sheets.caption(h,"Stone and machines block routes. Shared sections carry both allocations. Grove flow gets priority when a dry spell reduces the supply; lower its request to redirect Water.",box)
 if not undo_layout.is_empty() and undo_season == s.season: h.button("Undo last river edit",func(): undo(h),box)
 h.button("Try the other approach…",func(): branch_prompt(h),box)
 h.button("River story & portraits",func(): h.river_story.show(h),box)
 h.button("How this river works",func(): help(h),box)
 h.button("Return to my island",func(): h.close_sheet(); h.frame_world(); h.refresh(),box)
 signature = current_signature(h)
 h.call_deferred("apply_layout")
func branch_prompt(h) -> void:
 var branch: String = "woodland" if River.record(h.model).branch == "wetland" else "wetland"
 var box: VBoxContainer = h.modal_content("Try "+River.NAMES[branch]+"?")
 h.label("This clears the current routes and growth counters so you can try different objectives. Your terrain, discoveries, earned chapter moments and rewards stay yours. There is no material cost.",16,box)
 h.sheets.primary(h,"Try this approach",func():
  if commit(h,func(): return River.choose_branch(h.model,branch)): show(h),box)
 h.button("Keep my river",func(): show(h),box)
func append_cell(h, cell: String) -> void:
 if mode == "source":
  if River.tile(h.model,cell).get("type","") != "water": invalid_cell=cell;fail(h,"Tap one of the blue Water plots to choose your spring.");return
  point_prompt(h,cell); return
 if mode == "seedbed":
  var copy = h.model.get_script().new(); copy.state = h.model.state.duplicate(true)
  if not River.set_seedbed(copy,cell): h.model.message = "Choose bare Meadow or Ploughed Soil within three green steps of the flower route."; h.refresh(); return
  point_prompt(h,cell); return
 if mode not in River.ROLES or draft.is_empty(): return
 feedback="";invalid_cell=""
 if mode=="grove" and draft.size()==1:
  var suggestion: Array=River.link(h.model,draft[0],cell,11)
  if River.role_valid(h.model,"grove",suggestion):
   draft=suggestion;h.queue_redraw();layout(h);return
 if draft.has(cell): draft.resize(draft.find(cell)+1)
 elif draft.size() < 12 and River.passable(h.model,cell) and River.adjacent(h.model,draft[-1],cell): draft.append(cell)
 else: invalid_cell=cell;feedback="Follow connected natural land. Stone and machines block Water.";h.model.message=feedback
 h.queue_redraw(); layout(h)
func point_prompt(h, cell: String) -> void:
 var selection: String = mode
 cancel_pointer()
 opening_confirmation = true
 var box: VBoxContainer = h.modal_content("Use this "+("spring" if mode == "source" else "seedbed")+"?")
 opening_confirmation = false; h.modal_screen = "corridor_confirm"
 h.sheets.caption(h,"Plot "+cell+(" · Changing the spring clears current routes and growth, while earned moments remain." if mode == "source" else " · Sola can carry growth from the flower route into this bare plot."),box)
 h.sheets.primary(h,"Confirm selection",func():
  var ok: bool = commit(h,func(): return River.set_source(h.model,cell) if selection == "source" else River.set_seedbed(h.model,cell))
  if ok:
   h.selected=h.model.origin(cell);cancel(h,false)
   if selection=="source":begin(h,"grove")
   else:show(h)
  else: h.label(h.model.message,15,box),box)
 h.button("Choose another plot",func(): h.modal.hide(); layout(h),box)
func confirm_route(h) -> void:
 if mode not in River.ROLES or not River.role_valid(h.model,mode,draft): return
 var role: String = mode; var path: Array = draft.duplicate()
 cancel_pointer()
 opening_confirmation = true
 var box: VBoxContainer = h.modal_content("Confirm "+role+" route")
 opening_confirmation = false; h.modal_screen = "corridor_confirm"
 h.label("%d plots · %s → %s" % [path.size(),path[0],path[-1]],17,box)
 var initial: int=initial_flow(h,role,path)
 h.sheets.caption(h,"Natural land carries this channel. %d flow will be supplied when saved; adjust it later with + / −. No materials or Coins are spent. Replacing a route resets its current growth; earned moments stay yours." % initial,box)
 h.sheets.primary(h,"Save this route",func():
  if commit(h,func(): return save_route_with_flow(h,role,path)): cancel(h,false); show(h)
  else: h.label(h.model.message,15,box),box)
 h.button("Keep planning",func(): h.modal.hide(); layout(h),box)
func initial_flow(h, role: String, path: Array) -> int:
 var s: Dictionary=River.record(h.model)
 if s.routes.has(role):return int(s.routes[role].water)
 var wanted:=1
 if role=="grove":wanted=1 if s.branch=="woodland" and River.trees_near(h.model,path[-1])>=1 else 2
 var used:=0
 for route in s.routes.values():used+=int(route.water)
 var available:=maxi(0,River.base_budget(h.model)-used)
 if role=="garden":available=mini(available,maxi(0,River.budget(h.model)-int(s.routes.get("grove",{}).get("water",0))))
 return mini(wanted,available)
func save_route_with_flow(h, role: String, path: Array) -> bool:
 var amount:=initial_flow(h,role,path)
 return River.set_route(h.model,role,path) and River.allocate(h.model,role,amount)
func observe(h) -> void:
 var before: Dictionary = h.model.state.duplicate(true)
 var old: Array = River.record(h.model).get("ledger",[]).duplicate()
 if not River.advance(h.model): fail(h,"Choose an approach, Water spring and connected grove route first."); return
 if not h.store.save_state(h.model.state):
  h.model.state = before; h.model.message = "Save failed. The season and its discoveries were not committed."; h.refresh(); show(h); return
 h.services.observe_saved_progress()
 if not old.has("bloom") and River.earned(h.model):
  h.services.offer_break("river","bloom"); h.services.chapter_result = 0
 undo_layout.clear(); undo_season = -1
 h.modal.hide(); mode = ""; moment = true; cancel_pointer(); h.frame_world()
 var target: String = River.end_of(h.model,"garden") if River.record(h.model).stage >= 2 else River.end_of(h.model,"grove")
 if target != "": h.selected = h.model.origin(target)
 h.refresh(); layout(h)
 if not old.has("bloom") and River.earned(h.model): h.services.prepare_ad_services()
 if River.record(h.model).ledger != old:
  h.audio_feedback.play("restoration"); h.haptic(22)
  h.river_story.capture_if_enabled(h)
 h.playtest.record("river_season_saved",{"chapter":River.record(h.model).stage,"type":River.record(h.model).branch})
func undo(h) -> void:
 if undo_layout.is_empty() or undo_season != River.record(h.model).get("season",0): return
 var before: Dictionary = h.model.state.duplicate(true)
 var current: Dictionary = River.record(h.model)
 var previous: Dictionary = undo_layout.duplicate(true)
 # Revert configuration only. Time, chemistry, growth and reward ledgers never rewind.
 for field in ["branch","source","routes","seedbed"]: current[field] = previous.get(field,current[field])
 if not h.store.save_state(h.model.state): h.model.state = before; h.model.message = "Save failed. Your current plan was kept."
 else: undo_layout.clear(); h.model.message = "Previous river layout restored. Earned growth, discoveries and timers were not rewound."
 h.refresh(); show(h)
func feed(h, event: InputEvent) -> bool:
 if not active() or h.modal.visible: return false
 if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION: return true
 if event is InputEventScreenTouch:
  if event.pressed and h.world_rect().has_point(event.position):
   pointers[event.index] = event.position
   if pointers.size() == 1: append_cell(h,h.hit(event.position))
  elif not event.pressed: pointers.erase(event.index)
  return true
 if event is InputEventScreenDrag:
  if pointers.has(event.index) and pointers.size() == 1 and h.world_rect().has_point(event.position): append_cell(h,h.hit(event.position))
  return true
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
  mouse_down = event.pressed and h.world_rect().has_point(event.position)
  if mouse_down: append_cell(h,h.hit(event.position))
  return true
 if event is InputEventMouseMotion and mouse_down:
  if h.world_rect().has_point(event.position): append_cell(h,h.hit(event.position))
  return true
 return false
func current_signature(h) -> String:
 var s: Dictionary = River.record(h.model)
 var parts := [s]
 for role in River.ROLES:
  var at: String = River.end_of(h.model,role)
  if at != "": parts.append(River.tile(h.model,at).get("dna",{}))
 return JSON.stringify(parts)
func update_live(h) -> void:
 if h.modal.visible and h.modal_screen == "corridors" and signature != current_signature(h):
  var offset: int = h.modal_scroll.scroll_vertical
  show(h); h.modal_scroll.set_deferred("scroll_vertical",offset)
func help(h) -> void:
 var box: VBoxContainer = h.modal_content("A river you can understand")
 for text in ["1 · Choose a Water source and an approach. No supplies are spent on planning.","2 · Tap a highlighted remote tree or draw a path, then preview and save the visible channel. Its first flow is shown before saving; adjust with + / −.","3 · Observe seasons to mature the grove. A dry spell then lowers the available supply.","4 · Route a second branch through that grove to flowers. Meet the wetland or woodland requirements.","5 · Pick a bare nearby seedbed. Sola carries moisture and fertility there when both habitats work.","Routes can be edited, undone before another season, or rebuilt. Paused/broken routes grant no growth. Earned discoveries and chapter moments remain."]:
  h.label(text,15,box)
 h.sheets.primary(h,"Back to my river",func(): show(h),box)
