extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+message)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 for display in [{"size":Vector2i(320,640),"dp":1.6875},{"size":Vector2i(360,780),"dp":1.5},{"size":Vector2i(540,960),"dp":1.0}]:
  for scale in [1.0,1.2]:
   root.size = display.size
   var h = preload("res://tests/fixtures/MobileMain.gd").new()
   h.display_dp = display.dp
   h.store.path = "user://mobile-layout-tests.json"
   root.add_child(h)
   h.model = preload("res://scripts/WorldModel.gd").new()
   h.model.state.text_scale = scale
   h.apply_settings(); h.refresh(); h.start_play(); h.modal.hide()
   await process_frame
   await process_frame
   h.apply_layout()
   await process_frame
   var context := "%s text=%s" % [display.size,scale]
   var actual_zoom: float = h.zoom_level
   var actual_pan: Vector2 = h.pan
   h.frame_world()
   check(is_equal_approx(actual_zoom,h.zoom_level) and actual_pan.is_equal_approx(h.pan),"play frames the island after HUD layout settles at "+context)
   var gauge_width: float = h.pulse_button.get_theme_font("font").get_string_size("200/200",HORIZONTAL_ALIGNMENT_LEFT,-1,h.scaled_font(17)).x
   check(gauge_width+24 <= h.pulse_button.size.x,"full Pulse capacity fits without splitting at "+context)
   check(h.world_rect().size.y > 100,"usable world region at "+context)
   check(h.hud.get_global_rect().end.y <= h.world_rect().position.y+1,"header does not cover the world at "+context)
   var captions_fit := true
   for action in h.stacked_buttons:
    var caption: Label = action.get_meta("icon_caption")
    captions_fit = captions_fit and caption.get_line_count() <= 2 and caption.get_global_rect().end.y <= action.get_global_rect().end.y+1
    captions_fit = captions_fit and caption.get_minimum_size().x <= action.size.x
   check(captions_fit,"footer icons/captions fit without splitting words or clipping at "+context)
   check(h.ecology_monitor.get_global_rect().end.x <= h.get_viewport_rect().end.x and h.ecology_monitor.get_global_rect().end.y <= h.layout.world.position.y+1 and h.ecology_monitor.position.x >= h.hud.get_global_rect().end.x,"separate top-right ecological meters fit beside top-left resources at "+context)
   var conditions_fit := true
   for attribute in h.ecology_monitor.captions:
    var caption: Label = h.ecology_monitor.captions[attribute]
    conditions_fit = conditions_fit and caption.get_global_rect().end.x <= h.ecology_monitor.values[attribute].get_global_rect().position.x
   check(conditions_fit,"named moisture/heat readings fit without overlap at "+context)
   check(h.bottom.get_global_rect().end.y <= h.get_viewport_rect().end.y,"footer remains inside portrait screen at "+context)
   h.start_screen()
   await process_frame
   await process_frame
   var center := Vector2.ZERO
   for key in h.model.state.tiles: center += h.screen(h.model.coord(key))
   center /= h.model.state.tiles.size()
   check(center.y > h.get_viewport_rect().size.y*0.25 and center.y < h.get_viewport_rect().size.y*0.65,"title island hero stays centered after portrait resize at "+context)
   h.start_play(); h.modal.hide()
   h.begin_photo()
   h.apply_layout()
   await process_frame
   check(h.photo_controls.get_global_rect().end.y <= h.get_viewport_rect().end.y,"photo toolbar fits safe portrait viewport at "+context)
   h.end_photo()
   h.model = preload("res://scripts/WorldModel.gd").new()
   h.model.state.tiles.clear()
   for at in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.ONE]: h.model.add_tile(at,"forest")
   h.model.fuse("0,0")
   # A tall staircase makes vertical clipping observable; this is a visual fixture.
   for edge in range(2,16):
    h.model.add_tile(Vector2i(edge,edge-1),"grass")
    h.model.add_tile(Vector2i(edge,edge),"grass")
   h.model.state.expansions = h.model.state.tiles.size()-4
   h.refresh(); h.presentation.advance(10); h.begin_photo(); h.apply_layout(); h.frame_world()
   # Derive the sprite rectangle independently from the renderer's atlas metadata.
   var art: Dictionary = preload("res://scripts/TileArtwork.gd").appearance("forest","grove")
   var sprite_scale: float = 132.0/418.0*art.normalization*2*h.zoom_level
   var rendered := Rect2(h.entity_screen("0,0")-art.pivot*sprite_scale,art.region.size*sprite_scale)
   check(h.world_rect().grow(1).encloses(rendered),"photo framing includes the full tall fused artwork at "+context)
   h.end_photo(); h.start_screen()
   await process_frame
   await process_frame
   sprite_scale = 132.0/418.0*art.normalization*2*h.zoom_level
   rendered = Rect2(h.entity_screen("0,0")-art.pivot*sprite_scale,art.region.size*sprite_scale)
   var hero := Rect2(Vector2(20,h.get_viewport_rect().size.y*0.20),Vector2(h.get_viewport_rect().size.x-40,h.get_viewport_rect().size.y*0.42))
   check(hero.grow(1).encloses(rendered),"title hero fits actual sanctuary art rather than grid cells at "+context)
   h.queue_free()
   await process_frame
 print("MOBILE LAYOUT RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
