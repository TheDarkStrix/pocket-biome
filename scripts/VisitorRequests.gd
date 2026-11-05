extends RefCounted
const Projects = preload("res://scripts/HabitatProjects.gd")
const IDS = ["woodland_visit","sheltered_visit","evening_walk"]
const NAMES = {"woodland_visit":"Juniper's woodland visit","sheltered_visit":"Sola's sheltered garden","evening_walk":"Clover's evening walk"}
const RULES = {"woodland_visit":"Keep a suitable Woodland pond with two healthy trees. Juniper is looking for a broad, leafy rest stop.","sheltered_visit":"Create the Sheltered garden design: moist, fertile flowers with two healthy tree neighbors.","evening_walk":"Keep the connected sanctuary thriving and place an earned garden light beside Water."}
const REWARDS = {"woodland_visit":"Woodland bench","sheltered_visit":"Flower ring","evening_walk":"Firefly lantern"}
static func ready(m, id: String) -> bool:
 if m.state.discoveries.is_empty(): return false
 if id == "woodland_visit": return Projects.inspect(m,"shaded_pond").design == "Woodland pond"
 if id == "sheltered_visit": return Projects.inspect(m,"pollinator_patch").design == "Sheltered garden"
 if id == "evening_walk":
  if not Projects.network(m).ready: return false
  for at in m.state.get("sanctuary",{}).get("decorations",{}):
   if m.state.sanctuary.decorations[at] != "lamp": continue
   for other in m.neighbors(at):
    if m.state.tiles[other].type == "water": return true
 return false
static func claim(m, id: String) -> bool:
 if id not in IDS or m.state.get("visitor_requests",[]).has(id) or not ready(m,id): return false
 if not m.state.has("visitor_requests"): m.state.visitor_requests = []
 m.state.visitor_requests.append(id)
 return true
static func validate(value: Variant) -> bool:
 if not value is Array or value.size() > IDS.size(): return false
 var seen := []
 for id in value:
  if id not in IDS or seen.has(id): return false
  seen.append(id)
 return true
func show_requests(h) -> void:
 var box: VBoxContainer = h.modal_content("A visitor has an idea")
 h.modal_screen = "visitor_requests"
 h.sheets.caption(h,"Three optional visits encourage new layouts. Take them in any order, with no timer, streak or penalty for leaving. Rewards use no habitat space.",box)
 for id in IDS:
  var card: VBoxContainer = h.sheets.card(box)
  h.label(NAMES[id],20,card); h.sheets.caption(h,RULES[id],card)
  h.sheets.caption(h,"Earn · "+REWARDS[id],card)
  if h.model.state.get("visitor_requests",[]).has(id): h.sheets.caption(h,"Visit remembered · decoration earned",card)
  else:
   var action: Button = h.button("Welcome this visit",func():
    var before: Dictionary = h.model.state.duplicate(true)
    if not claim(h.model,id): show_requests(h); return
    if not h.store.save_state(h.model.state): h.model.state = before; h.model.message = "Save failed. The visit can be welcomed again."
    else: h.model.message = NAMES[id]+" remembered. "+REWARDS[id]+" earned."; h.audio_feedback.play("visitor"); h.playtest.record("visitor_request_saved",{"id":id})
    h.refresh(); show_requests(h),card)
   action.disabled = not ready(h.model,id)
 h.button("Review habitat designs",func(): h.habitat_ui.show_projects(h),box)
 h.button("Personalize my island",func(): h.identity_ui.show(h),box)
 h.campaign_ui.close_button(h,box)
