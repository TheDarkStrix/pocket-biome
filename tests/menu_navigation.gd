extends SceneTree
const Model=preload("res://scripts/WorldModel.gd")
var checks:=0
var failures:=0
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+message)
func button(h, title: String) -> Button:
 for action in h.modal_box.find_children("*","Button",true,false):
  if action.text==title:return action
 return null
func route(h, id: String) -> Button:
 for action in h.modal_box.find_children("*","Button",true,false):
  if action.get_meta("menu_route","")==id:return action
 return null
func settle(h) -> void:
 for frame in range(6):await process_frame
 h.apply_layout();await process_frame
func _init() -> void:call_deferred("run")
func run() -> void:
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size=display.size
   var h=preload("res://tests/fixtures/MobileMain.gd").new();h.display_dp=display.dp;h.show_menu_on_launch=false;h.store.path="user://menu-navigation-%d.json" % Time.get_ticks_usec();root.add_child(h);await process_frame;h.set_process(false)
   h.model=Model.new();h.services.model=h.model;h.model.state.learning={"dismissed":true};h.model.state.text_scale=scale;h.model.harvest("0,0");h.model.add_tile(Vector2i(-1,0),"water");h.model.add_tile(Vector2i(1,1),"workbench");h.model.state.expansions=h.model.state.tiles.size()-4;h.model.state.habitat_projects=["shaded_pond"];h.apply_settings();h.start_play();h.modal.hide();h.refresh()
   var before:=JSON.stringify(h.model.state)
   h.campaign_ui.pack(h);await settle(h)
   check(h.modal_box.find_children("*","Button",true,false).size()<=7,"Pack keeps four purpose routes, one goal and a clear exit")
   for id in ["inventory","discoveries","queue","world"]:check(route(h,id)!=null,"Pack retains the real destination: "+id)
   var fit:=true
   for id in ["inventory","discoveries","queue","world"]:
    var action:=route(h,id)
    fit=fit and action.size.y>=h.touch_height() and action.get_global_rect().end.x<=h.modal_scroll.get_global_rect().end.x+1
   check(fit,"Pack route cards fit at normal and enlarged text sizes")
   route(h,"inventory").pressed.emit();await settle(h)
   check(h.modal_screen=="inventory" and button(h,"Trade spare materials for Coins")!=null,"materials opens real stock and the explicit trading route")
   button(h,"Back to Pack").pressed.emit();route(h,"queue").pressed.emit();await settle(h)
   check(h.modal_screen=="project_queue" and h.campaign_ui.queue_labels.is_empty() and button(h,"Make something in Build")!=null,"queue explains its empty state without presenting the entire recipe catalogue")
   button(h,"Back to Pack").pressed.emit();route(h,"world").pressed.emit();await settle(h)
   check(h.modal_box.find_children("*","Button",true,false).size()<=8,"island tools landing groups actions without the old all-tools list")
   for id in ["care","edit","view","adventures"]:
    route(h,id).pressed.emit();await settle(h)
    check(h.modal_screen=="world_"+id and button(h,"Back to island tools")!=null,"island category has an explicit path back: "+id)
    button(h,"Back to island tools").pressed.emit();await settle(h)
   check(JSON.stringify(h.model.state)==before,"browsing every category does not spend, place, advance or grant anything")
   h.selected="1,1";h.campaign_ui.world(h,"edit");await settle(h)
   var upgrade: Button
   var move: Button
   for item in h.modal_box.find_children("*","Button",true,false):
    if item.get_meta("world_action","")=="upgrade":upgrade=item
    if item.get_meta("world_action","")=="move":move=item
   check(upgrade!=null and upgrade.disabled and move!=null and move.disabled,"unaffordable upgrades and moves without grass are visibly unavailable")
   h.model.state.inventory.wood=20;h.model.state.inventory.stone=20;h.model.state.coins=100
   var funds: Dictionary=h.model.state.duplicate(true);var path: String=h.store.path;h.store.path="user://missing-edit-menu-parent/state.json"
   check(not h.campaign_ui.edit_action(h,func():return h.model.campaign.upgrade_structure(h.model,"1,1")) and h.model.state==funds,"failed edit persistence restores exact plot level and paid resources")
   check(h.campaign_ui.edit_feedback.contains("Could not save") and h.modal_screen=="world_edit","edit failures have visible feedback inside the menu")
   h.store.path=path
   check(h.campaign_ui.edit_action(h,func():return h.model.campaign.upgrade_structure(h.model,"1,1")) and h.model.state.tiles["1,1"].level==2 and h.model.state.coins==75 and h.store.load_state().tiles["1,1"].level==2,"a valid upgrade pays once and persists its real level")
   h.campaign_ui.world(h);route(h,"care").pressed.emit();button(h,"Make a river").pressed.emit();await settle(h)
   check(h.modal_screen=="corridors","the grouped care menu reaches the actual river without losing access")
   h.model.state.blueprints.windmill=1;h.campaign_ui.project_queue(h);await settle(h)
   check(button(h,"Place Windmill · 1 ready").disabled and button(h,"Find room on my island")!=null,"ready items explain missing space and keep placement blocked until it is valid")
   h.campaign_ui.workshop(h);await settle(h)
   var confirm: Button
   for action in h.modal_box.find_children("*","Button",true,false):
    if action.get_meta("build_confirm","")=="workbench":confirm=action
   check(confirm!=null and confirm.text=="Make Workbench","Build names the item it will actually make")
   h.campaign_ui.craft_quantity=3;h.campaign_ui.build_tray.update_selection();await settle(h)
   var batch: Button
   for action in h.modal_box.find_children("*","Button",true,false):
    if action.get_meta("build_confirm","")=="workbench":batch=action
   check(batch!=null and batch.text=="Make Workbench × 3" and h.modal_scroll.get_global_rect().grow(1).encloses(batch.get_global_rect()),"named batch action discloses the actual quantity and stays reachable")
   h.campaign_ui.craft_quantity=1
   h.pulse_selector();await settle(h)
   check(h.modal_title.text=="Weather tools · Pulse" and h.rain_button!=null and h.heat_button!=null,"weather explains Pulse while retaining the real power controls")
   h.campaign_ui.inventory(h);await settle(h)
   var expected=Model.new();expected.state=h.model.state.duplicate(true);expected.harvest_ready()
   h.gather_ready()
   check(h.model.state.inventory==expected.state.inventory and h.model.state.harvests==expected.state.harvests,"collection from the moved inventory screen still uses the real harvest authority")
   h.queue_free();h=null;await process_frame
 print("MENU NAVIGATION RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
