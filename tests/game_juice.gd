extends SceneTree
const Rig = preload("res://scripts/ObjectMotion.gd")
const Art = preload("res://scripts/TileArtwork.gd")
const Living = preload("res://scripts/WorldAmbience.gd")
const Visitors = preload("res://scripts/VisitorAnimation.gd")
const Presentation = preload("res://scripts/WorldPresentation.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void: call_deferred("run")
func run() -> void:
 for type in ["golem","workbench","totem"]:
  var spec: Dictionary = Art.appearance(type,"")
  var mesh := Rig.grid(spec)
  var roots_fixed := true
  var no_fold := true
  var max_motion := 0.0
  for frame in range(32):
   var positions := PackedVector2Array()
   for point in mesh.points:
    var shift := Rig.offset(type,point,frame*0.23,7,1)
    max_motion = maxf(max_motion,shift.length())
    if point.y >= spec.pivot.y: roots_fixed = roots_fixed and shift.is_zero_approx()
    positions.append(point+shift)
   for i in range(0,mesh.indices.size(),3):
    var a: Vector2 = positions[mesh.indices[i]]
    var b: Vector2 = positions[mesh.indices[i+1]]
    var c: Vector2 = positions[mesh.indices[i+2]]
    no_fold = no_fold and (b-a).cross(c-a) > 0
  check(roots_fixed,type+" keeps contact points and ground fixed through full idle/harvest cycle")
  check(no_fold,type+" continuous UV mesh never folds or tears")
  check(max_motion > 1 and max_motion < 10,type+" has visible bounded local motion")
  var safe := true
  for uv in mesh.uvs:
   var source: Vector2 = uv*spec.texture.get_size()
   safe = safe and spec.region.has_point(source)
  check(safe,type+" UVs cannot bleed adjacent atlas objects")
  check(Rig.offset(type,Vector2(203,170),0,7).is_equal_approx(Rig.offset(type,Vector2(203,170),TAU/0.085,7)),type+" idle clock wraps without a pose discontinuity")
 var canopy: Dictionary = Art.appearance("oak","")
 var grown := Living.foliage_mesh(canopy,0.32,0,1,false,0,1)
 var sprout := Living.foliage_mesh(canopy,0.32,0,1,false,0,0.45)
 check(grown.base == sprout.base and grown.points[2] == sprout.points[2],"growth anchors both the soil and trunk seam")
 check(sprout.points[0].y > grown.points[0].y,"new canopy grows upward instead of scaling land")
 var p := Presentation.new()
 for i in range(30): p.harvest("%d,0" % i,"+1 Wood","wood")
 check(p.harvests.size() == 12,"rapid feedback stays within a fixed particle budget")
 check(is_zero_approx(p.visitor_reaction(["29,0"])),"visitor response eases in without a snap")
 p.advance(0.5)
 check(p.visitor_reaction(["29,0"]) > 0.5 and p.visitor_reaction(["unrelated"]) == 0,"only visitors in the harvested habitat react")
 p.advance(2)
 check(p.reactions.is_empty() and p.harvests.is_empty(),"all local feedback expires without saved state")
 for id in ["shaded_pond","pollinator_patch","living_workshop","thermal_refuge","sanctuary_network"]:
  check(Visitors.pose(id,0,true,1) == Visitors.pose(id,100,true,0),id+" reduced/photo visitor pose is time-independent")
 check(Visitors.pose("shaded_pond",4.1,false).hop > 5,"frog has an authored hop phase")
 check(Visitors.pose("living_workshop",1,false).perched and not Visitors.pose("living_workshop",4,false).perched,"bird alternates between perch and flight")
 check(not Visitors.pose("living_workshop",1,false,1).perched,"nearby harvesting startles a perched bird into flight")
 var h = preload("res://scenes/Main.tscn").instantiate()
 h.show_menu_on_launch = false; h.store.path = "user://juice-test-%d.json" % Time.get_ticks_usec()
 root.add_child(h); await process_frame; h.set_process(false)
 h.model.state.settings.tutorial_seen = true; h.model.state.learning = {"completed":true}
 h.services.model = h.model; h.modal.hide(); h.start_play(); h.modal.hide(); h.refresh(); h.presentation.advance(10)
 h.presentation.harvest("0,0","+1 Wood","wood")
 h.photo_mode = true
 var clock: float = h.ambient_time
 h._process(0.1)
 check(h.presentation.harvests[0].elapsed == 0 and h.ambient_time == clock,"photo freezes transient feedback and world clock")
 h.photo_mode = false; h.services.fullscreen_ad = true; h._process(0.1)
 check(h.presentation.harvests[0].elapsed == 0 and h.ambient_time == clock,"fullscreen ad freezes feedback and world clock")
 h.services.fullscreen_ad = false
 var audio = h.audio_feedback
 audio.set_suspended(false); audio.configure(1,1)
 var note: Dictionary = audio.request("wood")
 check(not note.is_empty() and audio.request("wood").is_empty(),"rapid identical sound requests are coalesced")
 audio._process(0.1)
 check(not audio.request("wood").is_empty(),"tap sounds recover after their short cooldown")
 audio.request("restoration")
 check(audio.ambience.volume_db < -24,"milestone sound briefly ducks ambience")
 audio.configure(0,0)
 check(audio.request("restoration").is_empty() and audio.ambience.volume_db == -80,"user mute remains authoritative during celebrations")
 audio.configure(0.5,0.5); audio.set_suspended(true)
 var duck: float = audio.duck; audio._process(2)
 check(audio.duck == duck and audio.request("wood").is_empty() and audio.suspended,"background/ad pause blocks cues and freezes duck envelope")
 audio.set_suspended(false)
 for frame in range(30): audio._process(0.1)
 check(is_equal_approx(audio.ambience.volume_db,-20+linear_to_db(0.5)),"ambience returns exactly to the user's selected level")
 var state := JSON.stringify(h.model.state)
 var box: VBoxContainer = h.modal_content("Celebration test")
 var banner = preload("res://scripts/MilestoneCelebration.gd").attach(h,box)
 banner.set_process(false)
 h.services.fullscreen_ad = true; banner._process(0.5)
 check(banner.elapsed == 0,"celebration does not advance behind fullscreen ads")
 h.services.fullscreen_ad = false
 for frame in range(30): banner._process(0.1)
 check(banner.elapsed == 2.4 and not banner.is_processing(),"celebration reaches a settled state and stops processing")
 check(JSON.stringify(h.model.state) == state,"celebrating cannot award duplicate rewards or change game progress")
 h.queue_free(); h = null; await process_frame; await create_timer(0.15).timeout
 print("GAME JUICE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
