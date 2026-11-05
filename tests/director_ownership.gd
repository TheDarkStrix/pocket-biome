extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Identity = preload("res://scripts/SanctuaryIdentity.gd")
const Requests = preload("res://scripts/VisitorRequests.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func button(node: Node, text: String) -> Button:
 for action in node.find_children("*","Button",true,false):
  if action.text == text: return action
 return null
func _init() -> void: call_deferred("run")
func run() -> void:
 var m = Model.new(); Identity.remember_start(m)
 check(m.state.sanctuary.before.size() == 4,"new islands preserve an actual four-plot starting portrait")
 check(Identity.rename(m,"  Clover Hollow  ") and Identity.name_of(m) == "Clover Hollow","sanctuary names are trimmed and persistent")
 check(not Identity.rename(m,"\n") and not Identity.rename(m,"bad\nname") and not Identity.rename(m,"x".repeat(33)),"empty, control-character and overlong names are rejected")
 var tiles := JSON.stringify(m.state.tiles); var coins: int = m.state.coins
 check(Identity.decorate(m,"1,1","path") and JSON.stringify(m.state.tiles) == tiles and m.state.coins == coins,"decoration consumes no terrain, condition, production or currency")
 check(not Identity.decorate(m,"1,1","firefly"),"unearned decorations cannot be placed")
 m.state.visitor_requests = ["evening_walk"]
 check(Identity.decorate(m,"1,1","firefly"),"an earned optional visit unlocks its decoration")
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://director-ownership.json"
 check(store.save_state(m.state) and store.load_state().sanctuary.name == "Clover Hollow","identity, portraits and decoration survive JSON save/load")
 for bad in ["unknown","\n","x".repeat(100)]:
  var corrupt: Dictionary = m.state.duplicate(true); corrupt.sanctuary.decorations["1,1"] = bad
  check(not store.valid(corrupt),"unknown decoration data is rejected")
 var corrupt: Dictionary = m.state.duplicate(true); corrupt.sanctuary["unknown"] = true
 check(not store.valid(corrupt),"unknown sanctuary fields are rejected")
 corrupt = m.state.duplicate(true); corrupt.sanctuary.before[0].size = 4
 check(not store.valid(corrupt),"malformed starting portraits are rejected")
 corrupt = m.state.duplicate(true); corrupt.visitor_requests = ["evening_walk","evening_walk"]
 check(not store.valid(corrupt),"visitor request rewards cannot be duplicated in a save")
 m = Model.new(); m.state.tiles["0,0"].dna.moisture = 75; m.state.discoveries = ["rainforest"]
 m.add_tile(Vector2i(-1,0),"water"); m.add_tile(Vector2i(-1,1),"forest"); m.state.tiles["-1,1"].dna.moisture = 75; m.state.expansions = 2
 check(Requests.ready(m,"woodland_visit") and Requests.claim(m,"woodland_visit"),"the authored woodland visit rewards a real alternate habitat design")
 check(not Requests.claim(m,"woodland_visit") and Identity.owned(m,"bench"),"once-only visitor requests unlock cosmetics without replaying rewards")
 var metrics = preload("res://scripts/AdMetrics.gd").new()
 check(not metrics.ingest(JSON.stringify({"event":"request","kind":"interstitial","placement":"i1"})).is_empty(),"ad requests are measured as requests")
 check(not metrics.counts.has("interstitial_impression"),"dispatch/load activity cannot count as an impression")
 metrics.ingest(JSON.stringify({"event":"impression","kind":"interstitial","placement":"i1"}))
 metrics.ingest(JSON.stringify({"event":"impression","kind":"interstitial","placement":"i1"}))
 check(metrics.counts.interstitial_impression == 1,"duplicate impression callbacks are deduplicated")
 for currency in ["USD","INR"]:
  var payload := JSON.stringify({"event":"paid","kind":"interstitial","placement":"paid-"+currency,"value_micros":125,"currency":currency})
  metrics.ingest(payload); metrics.ingest(payload)
 check(metrics.paid_micros == {"USD":125,"INR":125},"paid callbacks deduplicate and keep currencies separate")
 for bad in [{"event":"paid","kind":"interstitial","placement":"bad","value_micros":-1,"currency":"USD"},{"event":"paid","kind":"interstitial","placement":"bad","value_micros":1,"currency":"US$"},{"event":"click","kind":"interstitial","placement":"bad"}]:
  check(metrics.ingest(JSON.stringify(bad)).is_empty(),"invalid callback data is rejected")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://director-ownership-ui.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = Model.new(); h.services.model = h.model; h.model.state.blueprints["workbench"] = 1; h.placement_blueprint = "workbench"; h.modal.hide(); h.refresh()
 var before: Dictionary = h.model.state.duplicate(true)
 h.island_actions.deploy_prompt(h,"workbench","1,1")
 check(h.modal_screen == "deploy_confirm" and h.model.state == before,"blueprint placement previews actual consequences before spending")
 button(h.modal_box,"Choose another plot").pressed.emit()
 check(h.model.state == before and h.placement_blueprint == "workbench","canceling a placement preview preserves the blueprint")
 h.island_actions.deploy_prompt(h,"workbench","1,1"); h.store.path = "user://missing-director-ownership/fail.json"
 button(h.modal_box,"Confirm blueprint placement").pressed.emit()
 check(h.model.state == before and h.placement_blueprint == "workbench","failed blueprint save restores both terrain and ownership")
 h.store.path = "user://director-ownership-ui.json"; button(h.modal_box,"Confirm blueprint placement").pressed.emit()
 check(h.model.state.tiles["1,1"].type == "workbench" and h.store.load_state().blueprints.workbench == 0,"confirmed placement is atomically persisted")
 h.selected = "0,0"; h.store.path = "user://missing-director-ownership/fail.json"
 var before_decor: Dictionary = h.model.state.duplicate(true); h.identity_ui.decorate(h,"0,0","path")
 check(h.model.state == before_decor,"failed decoration save restores the prior island")
 h.store.path = "user://director-ownership-ui.json"; h.identity_ui.show(h)
 check(button(h.modal_box,"Save sanctuary name") != null,"personalization is reachable through the real UI")
 h.identity_ui.portraits(h)
 check(h.modal_screen == "sanctuary_portraits","older saves have an honest current portrait without a fabricated starting image")
 h.return_summary.show(h)
 check(h.modal_screen == "return_summary" and button(h.modal_box,"Continue my island") != null,"return flow offers a direct continuation and next task")
 h.model.state.private_playtest = true; h.playtest.path = "user://director-ownership-playtest.json"; h.playtest.erase(); h.playtest.attach(h.model)
 h.playtest.record("biome_discovered",{"id":"rainforest"})
 var another = Model.new(); another.state.private_playtest = true; h.playtest.attach(another)
 check(not h.playtest.report().contains("rainforest"),"local playtest reports keep different island timelines separate")
 h.playtest.erase(); h.queue_free(); h = null; await process_frame
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(540,960),"dp":1.0}]:
  root.size = display.size
  var mobile = preload("res://tests/fixtures/MobileMain.gd").new(); mobile.display_dp = display.dp; mobile.show_menu_on_launch = false; mobile.store.path = "user://director-personalize-mobile.json"
  root.add_child(mobile); await process_frame; mobile.set_process(false)
  mobile.model = Model.new(); Identity.remember_start(mobile.model); mobile.model.state.text_scale = 1.2; mobile.services.model = mobile.model; mobile.apply_settings()
  for page in ["personalize","portraits","requests","return"]:
   match page:
    "personalize": mobile.identity_ui.show(mobile)
    "portraits": mobile.identity_ui.portraits(mobile)
    "requests": mobile.visitor_requests.show_requests(mobile)
    "return": mobile.return_summary.show(mobile)
   for frame in range(5): await process_frame
   mobile.apply_layout(); await process_frame
   var fits := true
   for action in mobile.modal_box.find_children("*","Button",true,false):
    fits = fits and action.size.y >= mobile.touch_height()-1 and action.get_global_rect().end.x <= mobile.modal_scroll.get_global_rect().end.x+1
   check(fits,"ownership screen retains mobile touch bounds: "+page+" / "+str(display.size))
  mobile.queue_free(); await process_frame
 print("DIRECTOR OWNERSHIP RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
