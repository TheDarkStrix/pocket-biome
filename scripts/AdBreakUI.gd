extends RefCounted
func caption(h, box: VBoxContainer, kind: String = "") -> void:
 if h.model.state.entitlements.has("remove_ads"): return
 h.services.prepare_ad_services(kind)
 h.sheets.caption(h,"Occasional ads support Pocket Biome between completed activities. Your earned progress is saved before continuing.",box)
func leave(h, kind: String, after: Callable = Callable()) -> void:
 h.modal.hide(); h.frame_world(); h.refresh(); h.check_transition_ad(kind)
 if after.is_valid(): after.call()
func chapter(h) -> void:
 var id: int = h.services.chapter_result
 if id < 1: return
 h.services.chapter_result = 0
 var definition: Dictionary = h.model.config.chapters[id-1]
 h.services.offer_break("chapter",str(id))
 var box: VBoxContainer = h.modal_content("Chapter complete · "+definition.name)
 h.modal_screen = "chapter_result"
 h.audio_feedback.play("restoration")
 h.haptic(35)
 preload("res://scripts/MilestoneCelebration.gd").attach(h,box)
 h.label("Your island is growing into a living sanctuary.",20,box)
 h.sheets.caption(h,"Earned · %d Coins · 2 Star Dew · Pulse energy. These rewards are already part of your saved progress." % definition.reward,box)
 h.sheets.art(h,box,"grass","",200,true)
 h.label(h.model.campaign.next_goal(h.model).split("\n")[0],18,box)
 caption(h,box)
 h.sheets.primary(h,"Continue my island",func(): leave(h,"chapter"),box)
 h.button("Plan my next objective",func(): leave(h,"chapter",func(): h.journey_ui.goal(h)),box)
