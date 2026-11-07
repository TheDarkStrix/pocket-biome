extends RefCounted
const Lessons = preload("res://scripts/JourneyLessons.gd")
const Goals = preload("res://scripts/ObjectiveGuide.gd")
var signature := ""
var previous_step := ""
func change(h, action: Callable) -> bool:
 var had: bool = h.model.state.has("lessons")
 var before: Dictionary = Lessons.record(h.model).duplicate(true)
 if not action.call(): return false
 if not h.store.save_state(h.model.state):
  if had: h.model.state.lessons = before
  else: h.model.state.erase("lessons")
  h.model.message = "Save failed. Your previous lesson choice was kept."; return false
 previous_step = ""; return true
func start(h, id: String) -> void:
 if id in Lessons.IDS and Lessons.accomplished(h.model,id): lesson(h,id); return
 if change(h,func(): return Lessons.start(h.model,id)): h.refresh(); lesson(h,id)
func library(h) -> void:
 var box: VBoxContainer = h.modal_content("Learn & revisit")
 h.modal_screen = "lesson_library"
 h.sheets.caption(h,"Short lessons follow your real island actions. Skip whenever you like and revisit here. Opening help never spends supplies or completes an objective.",box)
 for id in Lessons.IDS:
  var card: VBoxContainer = h.sheets.card(box)
  h.label(Lessons.TITLES[id],19,card)
  var available: bool = Lessons.eligible(h.model,id) or Lessons.accomplished(h.model,id)
  var done: bool = Lessons.accomplished(h.model,id) or Lessons.record(h.model).completed.has(id)
  h.sheets.caption(h,"Accomplished · review the steps" if done else "Available · learn on your island" if available else {"river":"Restore the first spring to unlock.","fusion":"Reach chapter three to unlock.","automation":"Place a Workbench to unlock.","network":"Restore the climate refuge in chapter four to unlock."}[id],card)
  var action: Button = h.button("Review "+Lessons.TITLES[id] if done else "Learn · "+Lessons.TITLES[id],func(): start(h,id),card)
  action.disabled = not available
 h.button("My chapter objectives",func(): goal(h),box)
 h.campaign_ui.close_button(h,box)
func lesson(h, id: String = "") -> void:
 if id == "": id = Lessons.record(h.model).active
 if id not in Lessons.IDS: library(h); return
 var step := Lessons.current(h.model,id)
 var box: VBoxContainer = h.modal_content(Lessons.TITLES[id])
 h.modal_screen = "journey_lesson"
 box.set_meta("lesson_id",id)
 h.label(step.title,20,box)
 h.sheets.caption(h,"OPTIONAL LESSON · This helps with your chapter. You can leave at any time.",box)
 h.sheets.caption(h,step.why,box)
 h.label(step.body,16,box)
 if step.step == "done":
  h.sheets.primary(h,"Continue my chapter",func():
   if Lessons.record(h.model).active == id: change(h,func(): return Lessons.finish(h.model))
   goal(h),box)
 else:
  h.sheets.primary(h,step.button,func(): h.choose_idea(step),box)
  h.button("More help & lesson options",func(): lesson_options(h,id),box)
 h.campaign_ui.close_button(h,box)
 signature = state_signature(h)
func goal(h) -> void:
 var box: VBoxContainer = h.modal_content("Your chapter objectives")
 h.modal_screen = "island_goal"
 h.label(h.model.campaign.PURPOSE,16,box)
 var chapter: Dictionary = h.model.campaign.chapter_definition(h.model)
 h.label("Chapter %d · %s" % [h.model.state.chapter,chapter.name],20,box)
 var rows := Goals.rows(h.model)
 var done := 0
 for row in rows:
  if row.done: done += 1
 h.sheets.caption(h,"%d / %d requirements complete · progress updates as you play" % [done,rows.size()],box)
 if h.model.state.chapter_rewards.has(5):
  h.sheets.primary(h,"Celebrate my sanctuary",func(): h.finale_ui.show(h),box)
  h.sheets.caption(h,"The ending is earned. Expeditions, discovery mastery and personal decoration remain optional.",box)
 var active: String = Lessons.record(h.model).active
 var recommendation: String = active if active != "" else Lessons.recommended(h.model)
 if recommendation != "" and not h.model.state.chapter_rewards.has(5):
  var step := Lessons.current(h.model,recommendation)
  h.sheets.primary(h,("Continue lesson · " if active != "" else "Learn · ")+Lessons.TITLES[recommendation],func(): start(h,recommendation),box)
  h.sheets.caption(h,step.title+" · skippable, no extra reward or material cost",box)
 for row in rows:
  var card: VBoxContainer = h.sheets.card(box)
  h.label(("✓ " if row.done else "○ ")+row.title,18,card)
  h.sheets.caption(h,"%s · %d / %d" % ["Complete" if row.done else "In progress",mini(row.current,row.required),row.required],card)
  if row.done: continue
  h.sheets.caption(h,"WHY · "+row.why,card)
  h.label(row.body,15,card)
  h.sheets.primary(h,row.button,func(): h.choose_idea(row),card).set_meta("objective_id",row.id)
 h.button("Learn & revisit",func(): library(h),box)
 h.button("Other things to try",func(): h.open_ideas(true),box)
 h.button("All restoration projects",func(): h.habitat_ui.show_projects(h),box)
 h.button("Observe for five seconds",func(): h.island_actions.observe(h),box)
 h.campaign_ui.close_button(h,box)
 signature = state_signature(h)
func state_signature(h) -> String:
 return JSON.stringify([Goals.rows(h.model),Lessons.record(h.model),Lessons.current(h.model)])
func sync_progress(h) -> void:
 var step := Lessons.current(h.model)
 var token: String = Lessons.record(h.model).active+":"+step.get("step","")
 if not step.is_empty() and step.step == "done":
  var name: String = Lessons.TITLES[Lessons.record(h.model).active]
  if change(h,func(): return Lessons.finish(h.model)):
   h.model.message = "Lesson complete · "+name+". Your chapter progress is kept."
   h.audio_feedback.play("restoration"); h.haptic(18)
 elif previous_step != "" and token != previous_step and not step.is_empty():
  h.model.message = "Next lesson step · "+step.title
  h.audio_feedback.play("card")
 previous_step = token
func update_live(h) -> void:
 if not h.modal.visible or h.modal_screen not in ["island_goal","journey_lesson"] or not h.all_touches.is_empty(): return
 if signature == state_signature(h): return
 var offset: int = h.modal_scroll.scroll_vertical
 if h.modal_screen == "island_goal": goal(h)
 else: lesson(h,h.modal_box.get_meta("lesson_id",Lessons.record(h.model).active))
 h.modal_scroll.set_deferred("scroll_vertical",offset)

func show_reference(h, id: String) -> void:
 var box: VBoxContainer = h.modal_content(Lessons.TITLES[id]+" · reference")
 h.modal_screen = "lesson_reference"
 var index := 0
 for text in Lessons.instructions(id):
  index += 1; h.label("%d · %s" % [index,text],16,box)
 h.sheets.caption(h,"Reference only. Your progress, skipped lessons, currency and current island remain unchanged.",box)
 h.button("Back to this lesson",func(): lesson(h,id),box)
 h.button("Learn & revisit",func(): library(h),box)
 h.campaign_ui.close_button(h,box)

func lesson_options(h, id: String) -> void:
 var box: VBoxContainer=h.modal_content("Lesson help & options")
 h.label("A grove means a group of trees. A spring is the pond your river starts from. Flow is the water sent along a channel each season. A season advances only when you tap Observe.",16,box)
 h.button("Review all steps",func():show_reference(h,id),box)
 h.button("All lessons & review",func():library(h),box)
 h.button("Skip this lesson for now",func():
  if change(h,func():return Lessons.skip(h.model)):goal(h),box)
 h.sheets.primary(h,"Back to this lesson",func():lesson(h,id),box)
