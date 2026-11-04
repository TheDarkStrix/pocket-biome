extends SceneTree
const Model = preload("res://scripts/WorldModel.gd")
const Tools = preload("res://scripts/LayoutTools.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func trapped():
 var m = Model.new()
 for x in range(6):
  for y in range(6):
   if not m.state.tiles.has(m.key(Vector2i(x,y))): m.add_tile(Vector2i(x,y),"forest")
 m.state.expansions = 32
 for x in [0,2,4]:
  for y in [0,2,4]:
   if x != 0 or y != 0: m.fuse(m.key(Vector2i(x,y)))
 return m
func moving():
 var m = Model.new(); m.state.time = 100
 m.add_tile(Vector2i(2,1),"windmill"); m.add_tile(Vector2i(2,2),"grass")
 m.state.expansions = m.state.tiles.size()-4
 m.state.tiles["2,1"].level = 3; m.state.tiles["2,1"].enabled = false; m.state.tiles["2,1"].ready = 110
 return m
func _init() -> void: call_deferred("run")
func run() -> void:
 var store = preload("res://scripts/SaveStore.gd").new(); store.path = "user://layout-recovery-tests.json"
 var m = trapped()
 check(store.valid(m.state) and m.frontier().is_empty(),"regression starts from a valid full 36-cell sanctuary trap")
 var coins: int = m.state.coins; var discoveries: Array = m.state.discoveries.duplicate(); var fusions: int = m.state.stats.fusions
 check(Tools.dismantle(m,"1,2"),"a reserved footprint cell resolves to its sanctuary for dismantling")
 check(m.state.tiles.size() == 36 and m.state.expansions == 32 and m.frontier().is_empty(),"recovery preserves occupied land, connectivity and expansion prices")
 check(m.state.coins == coins and m.state.discoveries == discoveries and m.state.stats.fusions == fusions,"dismantling does not refund Coins or erase/replay discovery milestones")
 for key in ["0,2","1,2","0,3","1,3"]:
  check(m.state.tiles[key].type == "grass" and not m.state.tiles[key].has("owner"),"recovered cell becomes independently editable Meadow")
 for key in ["0,2","1,2","0,3","1,3"]:
  m.state.blueprints["water"] = int(m.state.blueprints.get("water",0))+1
  check(m.deploy("water",key),"recovered Meadow accepts terrain for another sanctuary")
 check(m.fuse("0,2") and m.state.discoveries.size() > discoveries.size(),"previously trapped player can discover another sanctuary through normal deployment and fusion")
 var saved := store.save_state(m.state)
 var recovered: Dictionary = store.load_state()
 check(saved and not recovered.is_empty() and recovered.tiles["1,3"].owner == "0,2","recovered/rebuilt sanctuary survives save validation and JSON load")
 var protected = Model.new()
 for key in ["1,0","2,0","1,1","2,1"]:
  if protected.state.tiles.has(key): protected.state.tiles.erase(key)
  protected.add_tile(protected.coord(key),"stone")
 protected.state.expansions = protected.state.tiles.size()-4
 protected.state.tiles["1,0"].ready = 10
 check(protected.fuse("1,0") and Tools.dismantle(protected,"1,1"),"sanctuary containing an original harvest position can be recovered")
 check(protected.state.tiles["1,0"].type == "stone" and protected.state.tiles["1,0"].ready == 10,"original harvest resource and inherited cooldown are restored without free collection")
 var movable = moving()
 var entity: Dictionary = movable.state.tiles["2,1"].duplicate(true)
 var built: int = movable.state.stats.built_windmill
 check(Tools.move(movable,"2,1","2,2"),"structure moves into existing empty Meadow")
 check(movable.state.tiles["2,2"] == entity and movable.state.tiles["2,1"].type == "grass","full entity identity, upgrades, cooldowns and pause state survive relocation")
 check(movable.state.stats.built_windmill == built,"moving a structure cannot replay construction metrics")
 check(store.save_state(movable.state) and store.load_state().tiles["2,2"].id == entity.id,"relocated entity saves without duplicate identity")
 var before := JSON.stringify(movable.state)
 check(not Tools.move(movable,"2,2","0,0") and JSON.stringify(movable.state) == before,"invalid occupied/protected destination is nonmutating")
 movable.state.tiles["2,2"].enabled = true
 movable.tick(4)
 check(movable.state.stats.automation_coins == 0,"moving does not advance the scheduled production time")
 movable.tick(1)
 check(movable.state.stats.automation_coins == 3,"upgraded production resumes once at its preserved schedule")
 var blocked = trapped(); blocked.state.pending = {"at":"6,0","cards":["water","forest","grass"],"cost":1}
 before = JSON.stringify(blocked.state)
 check(not Tools.dismantle(blocked,"0,2") and JSON.stringify(blocked.state) == before,"pending draft blocks dismantling without rewriting the quote")
 var h = preload("res://scenes/Main.tscn").instantiate(); h.show_menu_on_launch = false; h.store.path = "user://layout-ui-tests.json"
 root.add_child(h); await process_frame; h.set_process(false)
 h.model = moving(); h.services.model = h.model; h.model.state.settings.tutorial_seen = true
 h.refresh(); h.start_play(); h.modal.hide()
 entity = h.model.state.tiles["2,1"].duplicate(true)
 h.layout_ui.begin(h,"2,1"); h.layout_ui.choose(h,"2,2")
 check(h.modal_screen == "move_confirm" and h.model.state.tiles["2,1"] == entity,"choosing a destination previews confirmation without moving anything")
 var path: String = h.store.path; h.store.path = "user://absent-layout-parent/fail.json"
 h.layout_ui.confirm(h)
 check(h.model.state.tiles["2,1"] == entity and h.model.state.tiles["2,2"].type == "grass","failed move save rolls back the entire spatial transaction")
 h.store.path = path; h.layout_ui.confirm(h)
 var restored: Dictionary = h.store.load_state()
 check(h.layout_ui.source == "" and not restored.is_empty() and restored.tiles["2,2"].id == entity.id and restored.tiles["2,2"].level == entity.level and restored.tiles["2,2"].next_production == entity.next_production and restored.tiles["2,2"].ready == entity.ready and restored.tiles["2,2"].enabled == entity.enabled,"confirmed move commits a preserved entity and exits preview mode")
 h.layout_ui.begin(h,"2,2"); h.layout_ui.cancel(h)
 check(h.layout_ui.source == "" and h.model.state.tiles["2,2"] == entity,"cancel cannot change or duplicate the moved structure")
 h.layout_ui.begin(h,"2,2"); h.campaign_ui.pack(h)
 check(h.layout_ui.source == "","opening another task clears unfinished move mode")
 h.queue_free(); h = null; await process_frame
 print("LAYOUT RECOVERY RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
