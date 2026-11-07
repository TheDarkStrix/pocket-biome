extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Projects = preload("res://scripts/HabitatProjects.gd")
const Care = preload("res://scripts/RestorationCare.gd")
const Learn = preload("res://scripts/LearningJourney.gd")
const Layout = preload("res://scripts/LayoutTools.gd")
class Ads extends RefCounted:
 var shown := 0
 var initialized := 0
 func showInterstitial() -> void: shown += 1
 func initializeServices() -> void: initialized += 1
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func button(node: Node, title: String) -> Button:
 for child in node.find_children("*","Button",true,false):
  if child.text == title: return child
 return null
func world():
 var m = Model.new()
 m.state.discoveries = ["rainforest"]; m.state.objectives = [0,1,2]; m.state.settings.tutorial_seen = true
 for entry in [[Vector2i(-1,0),"water"],[Vector2i(-1,1),"water"],[Vector2i(1,1),"workbench"],[Vector2i(2,1),"windmill"],[Vector2i(1,2),"forest"],[Vector2i(0,2),"water"],[Vector2i(2,2),"glacier"]]: m.add_tile(entry[0],entry[1])
 m.state.tiles["0,0"].dna.moisture = 75
 m.state.tiles["1,2"].dna.moisture = 75
 m.state.expansions = m.state.tiles.size()-4
 return m
func _init() -> void: call_deferred("run")
func run() -> void:
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://restoration-campaign-tests.json"
 var m = world()
 var snapshot := JSON.stringify(m.state)
 for id in Projects.IDS.slice(0,4): check(Projects.inspect(m,id).ready,"distinct restoration has a legal compact layout: "+id)
 check(JSON.stringify(m.state) == snapshot,"layout and preference queries never grant achievements or tools")
 check(not Care.unlocked(m,"channel") and not Care.assign(m,"channel","0,0"),"unearned care tools cannot be used")
 check(not Projects.inspect(m,"sanctuary_network").ready,"suitable but unclaimed habitats do not complete the finale project")
 for id in Projects.IDS.slice(0,4):
  check(Projects.claim(m,id),"normal project authority records restoration: "+id)
  check(not Projects.claim(m,id),"restoration cannot replay its reward: "+id)
 check(Care.unlocked(m,"channel") and Care.unlocked(m,"shade") and Care.unlocked(m,"warmth"),"restorations unlock useful tools without ads or purchases")
 check(Projects.inspect(m,"sanctuary_network").ready,"claimed suitable habitats connected by natural land qualify")
 check(Projects.claim(m,"sanctuary_network") and Care.capacity(m) == 2,"final restoration expands care capacity")
 check(store.save_state(m.state),"new restoration records use the existing atomic save")
 check(store.load_state().habitat_projects.size() == 5,"all five projects survive JSON roundtrip")
 var before_coins: int = m.state.coins
 m.state.tiles["0,0"].dna.moisture = 0; m.state.tiles["1,2"].dna.moisture = 0
 check(not Projects.wildlife(m,"shaded_pond").arrived and m.state.coins == before_coins,"frogs leave unsuitable habitat without taking earned rewards")
 m.state.tiles["0,0"].dna.moisture = 75; m.state.tiles["1,2"].dna.moisture = 75
 check(Projects.wildlife(m,"shaded_pond").arrived,"restoring suitability welcomes visitors back")
 # A broad design works even when neither tree directly touches the pond.
 var broad = Model.new(); broad.state.tiles.clear()
 for entry in [[Vector2i(0,0),"water"],[Vector2i(1,0),"grass"],[Vector2i(2,0),"forest"],[Vector2i(1,1),"forest"]]: broad.add_tile(entry[0],entry[1])
 broad.state.tiles["2,0"].dna.moisture = 70; broad.state.tiles["1,1"].dna.moisture = 70
 var choice := Projects.inspect(broad,"shaded_pond")
 check(choice.ready and choice.design == "Woodland pond" and choice.quality == 2,"larger pond design is a genuinely different viable layout")
 broad.add_tile(Vector2i(1,0),"windmill")
 check(not Projects.inspect(broad,"shaded_pond").ready,"a machine blocks the pond's natural route")
 var garden = Model.new(); garden.state.tiles.clear()
 for entry in [[Vector2i(0,0),"fiber"],[Vector2i(1,0),"forest"],[Vector2i(0,1),"forest"]]: garden.add_tile(entry[0],entry[1])
 for key in ["0,0","1,0","0,1"]: garden.state.tiles[key].dna.moisture = 70; garden.state.tiles[key].dna.fertility = 80
 check(Projects.inspect(garden,"pollinator_patch").design == "Sheltered garden","two trees and rich moist flowers support a garden without adjacent Water")
 garden.state.tiles["0,0"].dna.moisture = 0
 check(not Projects.inspect(garden,"pollinator_patch").ready,"sheltered flower design still requires real suitable conditions")
 var workshop = Model.new(); workshop.state.tiles.clear()
 for entry in [[Vector2i(0,0),"workbench"],[Vector2i(1,0),"grass"],[Vector2i(2,0),"windmill"],[Vector2i(0,1),"forest"],[Vector2i(1,1),"forest"]]: workshop.add_tile(entry[0],entry[1])
 check(Projects.inspect(workshop,"living_workshop").design == "Woodland workshop","larger workshop design reaches a Windmill across living land")
 workshop.add_tile(Vector2i(1,0),"furnace")
 check(not Projects.inspect(workshop,"living_workshop").ready,"a blocking machine invalidates the larger workshop route")
 # A disconnected attractive habitat must not hide another connected valid choice.
 var connected = world(); connected.state["habitat_projects"] = Projects.IDS.slice(0,4)
 connected.add_tile(Vector2i(3,1),"forest"); connected.add_tile(Vector2i(4,1),"water"); connected.add_tile(Vector2i(4,2),"forest")
 connected.state.tiles["3,1"].dna.moisture = 75; connected.state.tiles["4,2"].dna.moisture = 75
 check(Projects.inspect(connected,"sanctuary_network").ready,"network searches valid connected alternatives even when another pond is more attractive")
 # Timed care is connected to ordinary world ticks and does not catch up a stalled frame.
 var timed = world(); timed.state["habitat_projects"] = ["shaded_pond"]
 timed.add_tile(Vector2i(-2,0),"grass"); Care.assign(timed,"channel","-2,0")
 timed.state.tiles["-1,0"].enabled = false
 var initial_moisture: int = timed.state.tiles["-2,0"].dna.moisture
 timed.tick(20)
 check(timed.state.tiles["-2,0"].dna.moisture == initial_moisture+12,"ordinary world tick applies one care cycle after a long frame")
 var climate = Model.new(); climate.state.tiles.clear()
 climate.add_tile(Vector2i(0,0),"forest"); climate.add_tile(Vector2i(1,0),"totem")
 climate.state.tiles["0,0"].dna.moisture = 80; climate.state.tiles["0,0"].dna.heat = 45
 check(Projects.inspect(climate,"thermal_refuge").design == "Rain shelter","mild rain shelter is an alternate climate solution")
 climate.state.tiles["1,0"].enabled = false
 check(not Projects.inspect(climate,"thermal_refuge").ready,"paused Rain Totem cannot support the rain shelter")
 # Care range, cadence, bounded slots and real environmental changes.
 m = world(); m.state["habitat_projects"] = Projects.IDS.duplicate()
 check(Care.assign(m,"channel","0,0"),"earned channel can be placed beside real Water")
 var moisture: int = m.state.tiles["0,0"].dna.moisture
 Care.apply(m)
 check(m.state.tiles["0,0"].dna.moisture == moisture,"assigning a tool grants no immediate environmental pulse")
 m.state.time = 4; Care.apply(m)
 check(m.state.tiles["0,0"].dna.moisture == moisture+12,"channel affects moisture on its four-second cadence")
 Care.apply(m)
 check(m.state.tiles["0,0"].dna.moisture == moisture+12,"same-time care cannot replay")
 check(not Care.assign(m,"channel","2,1"),"machines cannot receive natural-land care")
 check(Care.assign(m,"shade","1,2") and Care.assign(m,"warmth","0,1"),"shade and warmth unlock independent choices")
 var heat: int = m.state.tiles["1,2"].dna.heat
 m.state.time = 8; Care.apply(m)
 check(m.state.tiles["1,2"].dna.heat == heat-12 and m.state.tiles["0,1"].dna.heat == 42,"shade cools and warmth warms actual tile conditions")
 check(Care.assign(m,"shade","0,0",1) and not Care.assign(m,"shade","0,1",2),"finale capacity is exactly two per care type")
 check(not Care.assign(m,"shade","0,0",0),"same tool cannot be duplicated on a target")
 var cadence: float = m.state.restoration_care.next_at
 check(Care.remove(m,"shade","0,0") and m.state.restoration_care.next_at == cadence,"removal does not reset the care clock")
 check(store.save_state(m.state) and store.load_state().restoration_care.channel == ["0,0"],"care assignments and cadence persist")
 var restored = Model.new(); restored.state = store.load_state()
 var saved_moisture: int = restored.state.tiles["0,0"].dna.moisture
 Care.apply(restored)
 check(restored.state.tiles["0,0"].dna.moisture == saved_moisture,"loading cannot replay an already-applied care cycle")
 var dormant = world(); dormant.state["habitat_projects"] = ["shaded_pond"]
 Care.assign(dormant,"channel","0,0")
 dormant.add_tile(Vector2i(-1,0),"grass"); dormant.add_tile(Vector2i(-1,1),"grass"); dormant.add_tile(Vector2i(0,2),"grass")
 var dry: int = dormant.state.tiles["0,0"].dna.moisture
 dormant.state.time = 4; Care.apply(dormant)
 check(dormant.state.tiles["0,0"].dna.moisture == dry,"channel becomes dormant when its water source disappears")
 dormant.state["habitat_projects"].append("pollinator_patch")
 check(Care.assign(dormant,"shade","0,0") and not Care.assign(dormant,"shade","0,1",1),"before finale each tool is limited to one slot")
 var target = world(); target.state["habitat_projects"] = ["living_workshop"]
 var tree: Dictionary = target.state.tiles["1,2"].duplicate(true)
 target.add_tile(Vector2i(2,2),"grass")
 check(Layout.move(target,"1,2","2,2") and target.state.tiles["2,2"] == tree,"earned landscape movement preserves natural identity and conditions")
 check(not Layout.move(world(),"1,2","1,1"),"landscape movement cannot be used before its unlock")
 check(not Layout.move(target,"0,0","1,2"),"landscape movement keeps original resource nodes protected")
 target.state["habitat_projects"] = Projects.IDS.duplicate()
 Care.assign(target,"shade","2,2"); Care.assign(target,"shade","1,2",1)
 check(Layout.move(target,"2,2","1,2") and Care.targets(target,"shade") == ["1,2"],"moving care onto another cared plot deduplicates assignments")
 check(store.valid(target.state),"landscape movement with care remains a valid save")
 var locked_state: Dictionary = m.state.duplicate(true); locked_state.habitat_projects = []
 check(not store.valid(locked_state),"a save cannot retain tools without their earned unlocks")
 var learning_state: Dictionary = m.state.duplicate(true); learning_state.learning = {"unknown":true}
 check(not store.valid(learning_state),"malformed teaching progress is rejected")
 for corrupt in [{"channel":["0,0"],"shade":[],"warmth":[],"next_at":99999},{"channel":["missing"],"shade":[],"warmth":[],"next_at":m.state.time},{"channel":[],"shade":[],"warmth":[],"next_at":m.state.time,"extra":true}]:
  var state: Dictionary = m.state.duplicate(true); state.restoration_care = corrupt
  check(not store.valid(state),"malformed care state rejected")
 var old = Model.new(); old.state.chapter = 5; old.state.chapter_rewards = [1,2,3,4,5]
 check(store.valid(old.state) and not old.state.has("restoration_care"),"existing completed saves need no new fields or replayed goals")
 var old_coins: int = old.state.coins; old.campaign.evaluate(old)
 check(old.state.coins == old_coins and old.state.chapter_rewards.size() == 5,"old chapter rewards cannot replay")
 # Playable guidance advances only through ordinary actions.
 var learner = Model.new()
 check(Learn.current(learner).action == "collect","teaching starts with a real harvest")
 learner.harvest("0,0")
 check(Learn.current(learner).action == "expand","harvesting leads to spatial choice")
 learner.begin_draft("-1,0")
 check(Learn.current(learner).body.contains("Info"),"the draft step teaches comparing actual cards")
 learner.place(1)
 check(Learn.current(learner).action == "inspect","placement leads to observing live conditions")
 for second in range(4): learner.tick(1)
 Learn.mark(learner,"inspected")
 check(Learn.current(learner).action == "resource","discovery and observation explain the missing building materials first")
 learner.state.inventory.wood = 4; learner.state.inventory.stone = 2
 check(Learn.current(learner).action == "workbench","enough real materials expose the building action")
 learner.craft("workbench")
 check(Learn.current(learner).action == "projects","an unfinished craft leads to its real queue")
 learner.tick(4)
 check(Learn.current(learner).action == "blueprint","a finished craft leads to placement")
 learner.deploy("workbench","1,1")
 check(Learn.current(learner).action == "habitat","a deployed Workbench leads to the first wildlife restoration")
 check(Projects.claim(learner,"shaded_pond") and learner.state.learning.get("completed",false),"finishing the real building and habitat lesson persists completion")
 learner.campaign.retire(learner,"1,1")
 check(Learn.current(learner).is_empty(),"retiring a Workbench cannot restart completed teaching")
 check(store.save_state(learner.state) and store.load_state().learning.completed,"completed teaching survives relaunch")
 Learn.mark(learner,"dismissed")
 check(Learn.current(learner).is_empty() and store.valid(learner.state),"guidance can be dismissed and persisted without blocking play")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://restoration-care-ui.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = world(); h.services.model = h.model; h.model.state["habitat_projects"] = Projects.IDS.duplicate(); h.selected = "0,0"; h.refresh(); h.modal.hide()
 h.care_ui.show_tools(h)
 check(button(h.modal_box,"Place Water channel here · slot 1") != null,"earned tool is reachable through a real UI action")
 var before_choice: Dictionary = h.model.state.duplicate(true)
 button(h.modal_box,"Place Water channel here · slot 1").pressed.emit()
 check(h.modal_title.text == "Place Water channel?" and h.model.state == before_choice,"tool placement previews without mutating the island")
 button(h.modal_box,"Keep current layout").pressed.emit()
 check(h.model.state == before_choice,"canceling care placement keeps all state")
 var state_before: Dictionary = h.model.state.duplicate(true)
 h.store.path = "user://absent-care-parent/fail.json"; h.care_ui.commit(h,"channel","0,0",0)
 check(h.model.state == state_before,"failed save rolls back the entire tool assignment")
 h.store.path = "user://restoration-care-ui.json"; h.care_ui.commit(h,"channel","0,0",0)
 check(h.store.load_state().restoration_care.channel == ["0,0"],"successful UI placement commits its actual save")
 h.habitat_ui.show_projects(h)
 check(button(h.modal_box,"Compare habitat designs") != null,"players can read the alternative layout rules in game")
 h.model.state.chapter = 4; h.model.state.habitat_projects = ["living_workshop"]; h.habitat_ui.show_projects(h)
 var headings: Array = h.modal_box.find_children("*","Label",true,false).map(func(label): return label.text)
 check(headings.find(Projects.NAMES.thermal_refuge) < headings.find(Projects.NAMES.living_workshop),"the next unfinished chapter restoration appears before completed projects")
 h.model = Model.new(); h.services.model = h.model; h.model.harvest("0,0"); h.model.begin_draft("-1,0"); h.inspect_card(1)
 check(h.model.state.get("learning",{}).get("compared",false),"inspecting Water records the real comparison action")
 h.modal.hide(); h.reveal_queue.clear(); h.presentation.animations.clear(); h.targeting = ""; h.placement_blueprint = ""
 h.model = Model.new(); h.model.state.time = 500; h.model.state.discoveries = ["rainforest"]; h.model.state.chapter_rewards = [1]; h.services.model = h.model
 var ads := Ads.new(); h.services.bridge = ads; h.services.interstitial_ready = true; h.services.session_start = 0; h.services.last_interstitial = -1000; h.services.last_ad_chapter = 0
 h.services.active_seconds = 500; h.services.cadence.path = "user://restoration-ad-cadence-%d.json" % Time.get_ticks_usec(); h.services.offer_break("chapter","1")
 h.check_transition_ad("chapter")
 check(ads.shown == 0,"even an otherwise eligible interstitial waits for playable teaching to finish")
 h._process(0)
 check(ads.initialized == 0,"automatic consent/provider preparation also waits during teaching")
 Learn.mark(h.model,"dismissed"); h.services.offer_break("chapter","fresh-after-guidance"); h.check_transition_ad("chapter")
 check(ads.shown == 1,"finishing guidance restores ordinary capped chapter-break ads")
 h.services.bridge = null
 h.queue_free(); h = null; await process_frame
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(540,960),"dp":1.0}]:
  root.size = display.size
  var mobile = preload("res://tests/fixtures/MobileMain.gd").new(); mobile.display_dp = display.dp; mobile.show_menu_on_launch = false; mobile.store.path = "user://restoration-mobile-tests.json"
  root.add_child(mobile); await process_frame; mobile.set_process(false)
  mobile.model = world(); mobile.model.state["habitat_projects"] = Projects.IDS.duplicate(); mobile.model.state.text_scale = 1.2; mobile.services.model = mobile.model; mobile.apply_settings(); mobile.selected = "0,0"; mobile.care_ui.show_tools(mobile)
  for frame in range(5): await process_frame
  mobile.apply_layout(); await process_frame
  var fits := true
  for action in mobile.modal_box.find_children("*","Button",true,false):
   fits = fits and action.size.y >= mobile.touch_height()-1 and action.get_global_rect().end.x <= mobile.modal_scroll.get_global_rect().end.x+1
  check(fits,"earned tool controls retain touch targets and horizontal bounds at "+str(display.size))
  mobile.habitat_ui.expanded = "sanctuary_network"; mobile.habitat_ui.show_projects(mobile)
  for frame in range(5): await process_frame
  mobile.apply_layout(); await process_frame
  fits = true
  for action in mobile.modal_box.find_children("*","Button",true,false):
   fits = fits and action.size.y >= mobile.touch_height()-1 and action.get_global_rect().end.x <= mobile.modal_scroll.get_global_rect().end.x+1
  check(fits,"expanded restoration controls fit enlarged-text mobile sheets at "+str(display.size))
  mobile.queue_free(); await process_frame
 print("RESTORATION CAMPAIGN RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
