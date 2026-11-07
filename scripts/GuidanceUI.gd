extends RefCounted
const Opening = preload("res://scripts/LearningJourney.gd")
const Lessons = preload("res://scripts/JourneyLessons.gd")
var panel: PanelContainer
var caption: Label
var instruction: Label
var action: Button
var pointer: Control
var fitted := -1.0
func build(h) -> void:
 panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",preload("res://scripts/MaterialUI.gd").frame(Color.WHITE,14));h.ui_root.add_child(panel)
 var box:=VBoxContainer.new();box.add_theme_constant_override("separation",6);panel.add_child(box)
 caption=h.label("",12,box);caption.add_theme_color_override("font_color",Color("e7c98c"))
 instruction=h.label("",16,box)
 var row:=HBoxContainer.new();box.add_child(row)
 action=h.sheets.primary(h,"Show me",func():run(h),row)
 var help: Button=h.button("Help",func():show_help(h),row);help.size_flags_horizontal=Control.SIZE_SHRINK_END;help.custom_minimum_size.x=h.touch_height()+16
 panel.hide()
 pointer=preload("res://scripts/GuidancePointer.gd").new();pointer.host=h;pointer.mouse_filter=Control.MOUSE_FILTER_IGNORE;h.ui_root.add_child(pointer);pointer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func opening(h) -> bool:return not Opening.current(h.model).is_empty()
func number(h) -> int:
 var step:=Opening.current(h.model)
 if step.is_empty():return 6
 if h.model.state.harvests==0:return 1
 if h.model.state.discoveries.is_empty():return 2 if h.model.state.expansions==0 or step.action in ["expand","draft","pulse"] else 3
 if step.action=="inspect":return 4
 return 6 if step.action=="habitat" else 5
func message(h) -> String:
 var step:=Opening.current(h.model)
 if step.is_empty():return ""
 match step.action:
  "collect":return "Tap the tree to collect Wood. Follow the pointing hand."
  "expand":return "Tap a glowing + beside the tree. Choose Water for that empty space."
  "draft":return "Choose the Water card, read Info, then place it beside the tree."
  "inspect":return "The tree is changing! Open its details to see what Water does." if not h.model.state.discoveries.is_empty() else "Water helps the tree grow. Watch it change, or open its details."
  "resource":return "Collect 4 Wood and 2 Stone to make your first building. Tap ready trees or rocks."
  "workbench":return "You have the materials. Make a Workbench in Build."
  "projects":return "Your Workbench is being made. Wait for its timer to finish."
  "blueprint":return "Place your finished Workbench on an empty grassy plot."
  "habitat":return "Your tree and pond can welcome frogs. Finish your first habitat."
 return step.body
func run(h) -> void:
 var step:=Opening.current(h.model)
 if step.is_empty():return
 if step.action=="resource":h.gather_ready()
 else:h.choose_idea(step)
func layout(h) -> void:
 if not is_instance_valid(panel):return
 var step:=Opening.current(h.model)
 panel.visible=not step.is_empty() and not h.launch_menu and not h.photo_mode and not h.modal.visible and not h.corridor_ui.showing() and h.targeting=="" and h.placement_blueprint=="" and h.layout_ui.source==""
 if not panel.visible:return
 panel.size=Vector2(h.layout.world.size.x-16,0)
 caption.text="TUTORIAL · %d OF 6" % number(h)
 instruction.text=message(h)
 action.text="Collect ready materials" if step.action=="resource" else "Show me"
 action.disabled=step.action=="resource" and h.model.ready_harvests().is_empty()
 panel.position=Vector2(h.layout.world.position.x+8,h.layout.world.end.y-panel.get_combined_minimum_size().y-8)
 if absf(fitted-panel.get_combined_minimum_size().y)>1:
  fitted=panel.get_combined_minimum_size().y;h.call_deferred("frame_world")
func show_help(h) -> void:
 var box: VBoxContainer=h.modal_content("Tutorial help")
 h.label("This is a short guided start on your real island. You keep everything you earn. The six steps end when you build a Workbench and welcome frogs.",17,box)
 h.sheets.caption(h,"Water helps neighboring plants grow. A biome is a kind of land, such as a pond or forest. A habitat is a place where wildlife can live.",box)
 h.sheets.primary(h,"Continue tutorial",func():h.modal.hide();h.refresh(),box)
 h.button("Finish guidance and explore",func():stop(h),box)
 h.button("Explore other ideas",func():h.open_ideas(true),box)
func target(h) -> Rect2:
 if h.launch_menu or h.photo_mode or h.suspended:return Rect2()
 if h.modal.visible:
  if not opening(h):return Rect2()
  var title: String=""
  if h.modal_screen=="draft":title="Info" if not h.model.state.get("learning",{}).get("compared",false) else h.confirm_card.text
  elif h.modal_screen=="draft_info":title=h.confirm_card.text
  if title!="":
   for button in h.modal_box.find_children("*","Button",true,false):
    if button.text==title and button.is_visible_in_tree() and h.modal_scroll.get_global_rect().encloses(button.get_global_rect()):return button.get_global_rect()
  return Rect2()
 if not opening(h) or h.corridor_ui.showing():return Rect2()
 var step:=Opening.current(h.model)
 var cell: String=step.get("target","")
 if step.action=="expand":
  var cells:=preload("res://scripts/OpeningWater.gd").targets(h.model)
  if cells.is_empty():return Rect2()
  cell=cells[0]
 elif step.action not in ["collect","inspect","resource"]:return action.get_global_rect() if panel.visible else Rect2()
 if cell=="":return Rect2()
 var at: Vector2=h.screen(h.model.coord(cell))
 if step.action=="collect" or cell=="0,0":at+=Vector2(0,-40)*h.zoom_level
 return Rect2(at-Vector2.ONE*12*h.logical_per_dp(),Vector2.ONE*24*h.logical_per_dp())

func stop(h) -> void:
 var before: Dictionary=h.model.state.duplicate(true)
 Opening.mark(h.model,"dismissed")
 if not h.store.save_state(h.model.state):
  h.model.state=before;show_help(h);h.label("Could not save. Your tutorial choice was kept. Please try again.",16,h.modal_box);return
 h.modal.hide();h.refresh()
