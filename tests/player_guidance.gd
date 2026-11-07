extends SceneTree
const Model=preload("res://scripts/WorldModel.gd")
const River=preload("res://scripts/LivingCorridors.gd")
var checks:=0
var failures:=0
func check(ok: bool, text: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+text)
func button(h, title: String) -> Button:
 for item in h.modal_box.find_children("*","Button",true,false):
  if item.text==title:return item
 return null
func settle(h) -> void:
 for frame in range(8):
  h.guidance_ui.layout(h);h.river_labels.layout(h);h.apply_layout();await process_frame
 h.frame_world();await process_frame
func _init() -> void:call_deferred("run")
func run() -> void:
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size=display.size
   var h=preload("res://tests/fixtures/MobileMain.gd").new();h.display_dp=display.dp;h.show_menu_on_launch=false;h.store.path="user://player-guidance-%d.json" % Time.get_ticks_usec();root.add_child(h);await process_frame;h.set_process(false)
   h.model=Model.new();h.model.state.text_scale=scale;h.services.model=h.model;h.apply_settings();h.start_play();h.modal.hide();h.refresh();await settle(h)
   var before:=JSON.stringify(h.model.state)
   check(h.guidance_ui.panel.visible and h.guidance_ui.caption.text=="TUTORIAL · 1 OF 6","fresh islands visibly identify the tutorial")
   check(h.guidance_ui.target(h).has_point(h.screen(Vector2.ZERO)+Vector2(0,-40)*h.zoom_level),"the first pointing hand targets the actual Oak")
   check(h.world_rect().end.y<=h.guidance_ui.panel.position.y and h.layout.world.encloses(h.guidance_ui.panel.get_rect()),"tutorial card reserves island space and fits the play area %s scale=%s world=%s panel=%s area=%s" % [display.size,scale,h.layout.world,h.guidance_ui.panel.get_rect(),h.world_rect()])
   check(JSON.stringify(h.model.state)==before,"guidance and layout do not grant harvests or progress")
   var visible:=0
   for dock in h.stacked_buttons:
    if dock.has_meta("primary_dock") and dock.visible:visible+=1
   check(visible==0,"advanced dock choices stay out of the first harvest step")
   h.guidance_ui.run(h);await settle(h)
   check(h.model.state.harvests==0 and not h.modal.visible,"Show me points to the tree without collecting it")
   h.model.harvest("0,0");h.refresh();await settle(h)
   check(h.guidance_ui.number(h)==2 and preload("res://scripts/OpeningWater.gd").targets(h.model).size()>0,"real harvesting advances to a genuine Water placement target")
   h.model.state.learning={"dismissed":true};h.refresh();await settle(h)
   check(not h.guidance_ui.panel.visible,"leaving guidance restores ordinary play without faking completion")
   visible=0
   for dock in h.stacked_buttons:
    if dock.has_meta("primary_dock") and dock.visible:visible+=1
   check(visible==3,"all dock tools return after leaving guidance")
   h.model.state.habitat_projects=["shaded_pond"];h.model.add_tile(Vector2i(-1,0),"water");h.model.add_tile(Vector2i(0,2),"forest");h.model.state.expansions=h.model.state.tiles.size()-4
   River.choose_branch(h.model,"wetland");River.set_source(h.model,"-1,0");River.set_route(h.model,"grove",["-1,0","0,0","0,1","0,2"]);River.allocate(h.model,"grove",2);h.model.state.text_scale=scale
   h.refresh();await settle(h)
   check(h.river_labels.bar.visible and h.river_labels.entries(h).size()==2,"spring and delivered Water have matching numbered labels")
   var fits:=true
   for badge in h.river_labels.badges:fits=fits and h.layout.world.encloses(badge.get_global_rect()) and not h.world_rect().intersects(badge.get_global_rect())
   check(fits,"readable river badges stay clear of the island at both text sizes")
   h.rotate_camera(1);await settle(h)
   check(h.river_labels.entries(h)[1].cell=="0,2","camera rotation retains labels attached to the actual route destination")
   h.corridor_ui.show(h);await settle(h)
   var controls: Array=h.modal_box.find_children("*","Button",true,false)
   check(controls.size()<=5 and button(h,"River tools & help")!=null,"normal river review has one next action and a secondary tools menu")
   h.journey_ui.start(h,"river");await settle(h)
   check(h.modal_box.find_children("*","Button",true,false).size()<=4 and button(h,"More help & lesson options")!=null,"optional lessons separate the main action from extra choices")
   h.modal.hide();h.begin_photo();await settle(h)
   check(not h.river_labels.bar.visible and not h.guidance_ui.target(h).has_area(),"photos omit guide pointers and river labels")
   h.end_photo();h.model.state.learning={};h.refresh();h.store.path="user://missing-guidance-parent/save.json";h.guidance_ui.stop(h)
   check(not h.model.state.learning.get("dismissed",false) and h.modal.visible,"failed tutorial preference saves restore the previous choice visibly")
   h.queue_free();h=null;await process_frame
 print("PLAYER GUIDANCE RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
