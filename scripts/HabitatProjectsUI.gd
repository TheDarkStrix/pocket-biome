extends RefCounted
const Projects = preload("res://scripts/HabitatProjects.gd")
const Guidance = preload("res://scripts/HabitatGuidance.gd")
var status := ""
var signature := ""
var expanded := ""
func show_projects(h) -> void:
 var box: VBoxContainer = h.modal_content("Living habitat projects")
 h.modal_screen = "habitat_projects"
 signature = current_signature(h)
 h.sheets.caption(h,"Restore distinct places to unlock reusable tools. Give neighboring plots a purpose. Complete a project for a one-time Coin reward and wildlife visitors. Visitors stay while the habitat is suitable; your earned reward is never taken away.",box)
 if h.model.state.discoveries.is_empty(): h.sheets.caption(h,"Make your first discovery to unlock project rewards. You can plan the layouts now.",box)
 h.label("Chapter %d · %s" % [h.model.state.chapter,h.model.campaign.chapter_definition(h.model).name],19,box)
 if status != "":
  h.label(status,18,box)
  h.sheets.primary(h,"Return to your island",func(): h.modal.hide(); h.frame_world(); h.refresh(),box)
 var order: Array = Projects.IDS.duplicate()
 var priorities: Array = {2:["shaded_pond"],3:["pollinator_patch"],4:["living_workshop","thermal_refuge"],5:["sanctuary_network"]}.get(int(h.model.state.chapter),["shaded_pond"])
 var priority: String = priorities[0]
 for id in priorities:
  if not h.model.state.get("habitat_projects",[]).has(id): priority = id; break
 order.erase(priority); order.push_front(priority)
 for id in order:
  var current := Projects.inspect(h.model,id)
  var done: bool = h.model.state.get("habitat_projects",[]).has(id)
  var card: VBoxContainer = h.sheets.card(box)
  h.label(Projects.NAMES[id],21,card)
  h.sheets.caption(h,Projects.RULES[id],card)
  h.sheets.caption(h,"Wildlife · "+Projects.ANIMALS[id]+(" · "+current.design if done and current.ready else " · ready to welcome" if current.ready else " · waiting for suitable habitat"),card)
  h.button("Compare habitat designs",func(): expanded = "" if expanded == id else id; show_projects(h),card)
  if expanded == id:
   h.sheets.caption(h,Projects.DESIGNS[id],card)
   if id == "thermal_refuge":
    h.button("Plan Glacier",func(): follow_step(h,Guidance.supply(h.model,"glacier")),card)
    h.button("Plan Rain Totem",func(): follow_step(h,Guidance.supply(h.model,"totem")),card)
   h.button("Review earned care tools",func(): h.care_ui.show_tools(h),card)
  h.sheets.caption(h,"Completed · visitors present" if done and current.ready else "Completed · rebuild a suitable habitat to welcome visitors back" if done else "Ready to complete" if current.ready else "%d / %d relationships satisfied" % [current.matched,current.total],card)
  h.sheets.caption(h,"One-time reward · %d Coins" % Projects.REWARDS[id],card)
  h.sheets.caption(h,("EARNED · " if done else "Unlock · ")+Projects.UNLOCKS[id],card)
  if done and id != "living_workshop": h.button("Use earned care tools",func(): h.care_ui.show_tools(h),card)
  var next_step := Guidance.advice(h.model,id)
  if not current.ready and not next_step.is_empty():
   h.sheets.caption(h,next_step.text,card)
   if next_step.action != "": h.button(next_step.label,func(): follow(h,id),card)
  if current.anchor != "":
   h.button("Show habitat on island",func():
    h.fusion_preview.clear()
    for key in current.cells:
     for cell in h.model.footprint(key): h.fusion_preview.append(cell)
    h.selected = current.anchor; h.modal.hide(); h.frame_world(); h.refresh()
    h.model.message = "Highlighted habitat. Open Pack → Habitat projects to review or complete it.",card)
  else: h.sheets.caption(h,"Start with "+{"shaded_pond":"Water","pollinator_patch":"Fiber or Wildflower Meadow","living_workshop":"a Workbench","thermal_refuge":"a sheltered tree","sanctuary_network":"four suitable restored habitats"}[id]+" on your island.",card)
  if not done:
   var complete: Button = h.sheets.primary(h,"Complete project · %d Coins" % Projects.REWARDS[id],func(): claim(h,id),card)
   complete.disabled = not current.ready or h.model.state.discoveries.is_empty()
 h.button("Refresh habitat checks",func(): show_projects(h),box)
 h.campaign_ui.close_button(h,box)
func claim(h, id: String) -> void:
 var before: Dictionary = h.model.state.duplicate(true)
 if not Projects.claim(h.model,id):
  status = "That project is already completed or its habitat has changed."; show_projects(h); return
 if not h.store.save_state(h.model.state):
  h.model.state = before
  status = "Save failed. No reward was committed; your project can be completed again when saving works."
  show_projects(h); return
 status = Projects.NAMES[id]+" restored! "+Projects.UNLOCKS[id]
 h.fusion_preview.clear()
 for key in Projects.inspect(h.model,id).cells:
  for cell in h.model.footprint(key):
   if not h.fusion_preview.has(cell): h.fusion_preview.append(cell)
 h.selected = Projects.inspect(h.model,id).anchor
 h.services.event("habitat_project_completed",{"id":id})
 h.refresh(); show_projects(h)

func current_signature(h) -> String:
 var parts := []
 for id in Projects.IDS: parts.append([Projects.inspect(h.model,id),Guidance.advice(h.model,id)])
 return JSON.stringify([parts,h.model.state.get("habitat_projects",[]),h.model.state.discoveries.size()])
func update_live(h) -> void:
 if not h.modal.visible or h.modal_screen != "habitat_projects" or signature == current_signature(h): return
 var offset: int = h.modal_scroll.scroll_vertical
 show_projects(h)
 h.modal_scroll.set_deferred("scroll_vertical",offset)

func follow(h, id: String) -> void:
 # Recompute at activation so a changed island or finished queue cannot use stale advice.
 follow_step(h,Guidance.advice(h.model,id))

func follow_step(h, next: Dictionary) -> void:
 if next.is_empty(): return
 match next.action:
  "ideas": h.open_ideas()
  "habitats": show_projects(h)
  "draft": h.draft()
  "projects": h.campaign_ui.workshop_details(h)
  "build":
   h.campaign_ui.build_choice = next.target
   h.campaign_ui.build_family = "Structures" if h.model.config.tiles[next.target].category == "structure" else "Land"
   h.campaign_ui.workshop(h)
  "blueprint":
   h.placement_blueprint = next.target
   h.targeting = ""; h.modal.hide()
   h.model.message = "Choose empty Grass beside your planned habitat. Blueprint kept until you place it."
   h.refresh()
  "world":
   if h.model.origin(next.target) != "": h.selected = h.model.origin(next.target)
   h.campaign_ui.world(h)
  "inspect":
   if h.model.origin(next.target) != "": h.open_inspector(h.model.origin(next.target))
  "expand":
   h.modal.hide(); h.frame_world()
   h.model.message = "Choose a cloud to compare land offers. Selection and inspection cost nothing."
   h.refresh()
  _: show_projects(h)
