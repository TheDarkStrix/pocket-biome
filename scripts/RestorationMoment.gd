extends RefCounted
const Projects = preload("res://scripts/HabitatProjects.gd")
const STORIES = {"shaded_pond":"Clover finds a sheltered water edge. The first spring has become a home.","pollinator_patch":"Sola follows the flowers into your garden. Water and living shelter have made room for wings.","living_workshop":"Juniper rests near the working garden. Your builders and woodland can thrive together.","thermal_refuge":"A quiet shelter holds steady through the weather. Warmth and shade are now yours to shape.","sanctuary_network":"Fireflies cross the connected habitats. Your small acts of care have become one living sanctuary."}
func show(h, id: String) -> void:
 h.selected = Projects.inspect(h.model,id).anchor
 h.frame_world(); h.refresh()
 var box: VBoxContainer = h.modal_content(Projects.NAMES[id]+" restored")
 h.modal_screen = "restoration_moment"
 h.sheets.art(h,box,"grass","",200,true)
 h.label(STORIES[id],18,box)
 h.sheets.caption(h,"You earned · "+Projects.UNLOCKS[id],box)
 h.audio_feedback.play("restoration")
 if id == "shaded_pond": h.sheets.primary(h,"Plan your Living River",func(): h.corridor_ui.show(h),box)
 if id == "living_workshop":
  h.sheets.primary(h,"Try landscape movement",func(): h.layout_ui.begin(h,h.selected),box)
 else: h.sheets.primary(h,"Try your earned care tools",func(): h.care_ui.show_tools(h),box)
 h.button("Plan the next restoration",func(): h.island_actions.show_goal(h),box)
 h.button("Enjoy my island",func(): h.modal.hide(); h.frame_world(); h.refresh(),box)
