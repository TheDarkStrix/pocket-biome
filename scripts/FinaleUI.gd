extends RefCounted
# A presentation milestone only. CampaignSystem owns all completion rewards.
var presented_this_session := false
func maybe_show(h) -> bool:
 if presented_this_session or h.model.state.get("finale_seen",false) or not h.model.state.chapter_rewards.has(5): return false
 if h.layout_ui.source != "" or h.launch_menu or h.photo_mode or h.modal.visible or h.targeting != "" or h.placement_blueprint != "" or not h.model.state.pending.is_empty() or not h.reveal_queue.is_empty() or not h.presentation.animations.is_empty(): return false
 show(h)
 return true
func show(h) -> void:
 if not h.model.state.chapter_rewards.has(5): return
 presented_this_session = true
 var was_seen: bool = h.model.state.get("finale_seen",false)
 h.model.state.finale_seen = true
 h.persist()
 if h.save_dirty:
  if was_seen: h.model.state.finale_seen = true
  else: h.model.state.erase("finale_seen")
 var box: VBoxContainer = h.modal_content("Your living sanctuary")
 h.modal_screen = "finale"
 h.sheets.art(h,box,"grass","",240,true)
 h.label(preload("res://scripts/SanctuaryIdentity.gd").name_of(h.model),22,box)
 h.sheets.caption(h,"From a tiny seed, a world of your own",box)
 h.sheets.caption(h,"You have completed all five chapters. Water, warmth and neighboring habitats have helped your island become a living sanctuary.",box)
 h.label("%d discoveries · %d land tiles" % [h.model.state.discoveries.size(),h.model.state.tiles.size()],18,box)
 h.sheets.caption(h,"%d sanctuaries fused · %d Bricks crafted · %d Coins earned by automation" % [h.model.state.stats.fusions,h.model.state.stats.crafted_brick,h.model.state.stats.automation_coins],box)
 h.sheets.caption(h,"Discovery mastery · %d / 20 · %s" % [h.model.state.discoveries.size(),"Complete" if h.model.state.discoveries.size() == 20 else "Optional discoveries remain"],box)
 h.sheets.caption(h,"The campaign is complete. Your island stays yours: refine its layout, take a portrait or restore the expedition islands beyond your home.",box)
 h.sheets.primary(h,"Keep creating",func(): h.modal.hide(); h.frame_world(); h.refresh(),box)
 h.button("Frame an island portrait",func(): h.modal.hide(); h.begin_photo(),box)
 h.button("Explore expeditions",func(): h.expedition_ui.overview(h),box)
 h.button("Before & after portraits",func(): h.identity_ui.portraits(h),box)
 h.sheets.caption(h,"Pocket Biome · a small world shaped by your care. Thank you for bringing it to life.",box)
 if h.save_dirty: h.sheets.caption(h,"Your celebration could not be saved yet. Your progress is kept in memory; retry saving before closing the app.",box)
