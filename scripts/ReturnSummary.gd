extends RefCounted
var shown := false
func show(h) -> void:
 if shown: return
 shown = true
 var box: VBoxContainer = h.modal_content("Welcome back to "+preload("res://scripts/SanctuaryIdentity.gd").name_of(h.model))
 h.modal_screen = "return_summary"
 var lesson := preload("res://scripts/LearningJourney.gd").current(h.model)
 if lesson.is_empty(): lesson = preload("res://scripts/JourneyLessons.gd").current(h.model)
 h.label(lesson.title if not lesson.is_empty() else h.model.campaign.next_goal(h.model),18,box)
 h.sheets.caption(h,"Your island waits safely. Conditions and production advance while you play; returning late never removes earned discoveries or chapter rewards.",box)
 var ready: Array = h.model.ready_harvests()
 h.sheets.caption(h,"%d resource nodes ready · %d suitable visitor groups" % [ready.size(),h.habitat_visitors.size()],box)
 h.sheets.primary(h,"Continue my island",func(): h.modal.hide(); h.frame_world(); h.refresh(),box)
 if lesson.is_empty(): h.button("Review my next restoration",func(): h.island_actions.show_goal(h),box)
 else: h.button("Continue my guided step",func(): h.open_ideas(),box)
 for kind in h.model.state.blueprints:
  if h.model.state.blueprints[kind] <= 0: continue
  h.button("Place ready "+kind.capitalize(),func(): h.placement_blueprint = kind; h.modal.hide(); h.refresh(),box)
  break
 h.button("Visitor field notes",func(): h.sanctuary_life.show_notes(h),box)
