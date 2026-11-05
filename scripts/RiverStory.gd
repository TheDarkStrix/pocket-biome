extends RefCounted
const River = preload("res://scripts/LivingCorridors.gd")
var recording := false
var capturing := false
func frame_path(h, stage: int) -> String: return "user://river-%d-%d.png" % [int(h.model.state.seed),stage]
func capture_if_enabled(h) -> void:
 if recording and not capturing: h.call_deferred("capture_river_moment")
func capture(h) -> bool:
 if capturing or h.launch_menu or h.photo_mode or h.modal.visible: return false
 capturing = true
 h.input_controller.reset(); h.corridor_ui.cancel_pointer()
 var bar_was: bool = h.corridor_ui.moment
 # Photograph settled land, then restore unfinished cosmetic transitions.
 # This changes no terrain, chemistry, rewards or simulation timers.
 var poses: Dictionary = h.presentation.animations.duplicate(true)
 var known: Dictionary = h.presentation.known.duplicate()
 h.presentation.animations.clear()
 h.begin_photo()
 h.photo_controls.hide()
 await h.get_tree().process_frame
 await RenderingServer.frame_post_draw
 var image: Image = h.get_viewport().get_texture().get_image()
 var width := mini(360,image.get_width())
 image.resize(width,maxi(1,roundi(image.get_height()*float(width)/image.get_width())),Image.INTERPOLATE_LANCZOS)
 var result: Error = image.save_png(frame_path(h,int(River.record(h.model).get("stage",0))))
 h.end_photo()
 for at in poses:
  if h.presentation.known.get(at,"") == known.get(at,""): h.presentation.animations[at] = poses[at]
 h.corridor_ui.moment = bar_was; h.corridor_ui.layout(h)
 h.input_controller.reset()
 capturing = false
 if result != OK: h.model.message = "The story image could not be saved. Your river progress is safe."; h.refresh(); return false
 return true
func show(h) -> void:
 var box: VBoxContainer = h.modal_content("Your river story")
 h.modal_screen = "river_story"
 h.sheets.caption(h,"Clover follows Water. Juniper offers living shelter. Sola carries growth through a healthy grove into the corner you chose. Your Living Heart remembers the three restored moments.",box)
 h.button("Record future moments locally · "+("On" if recording else "Off"),func(): recording = not recording; show(h),box)
 h.sheets.caption(h,"Recording is optional and session-only. Up to four small images per island stay on this device; nothing uploads. Turn it on before observing milestones. Sharing opens your device's chooser only when you press Share.",box)
 for stage in range(4):
  var path := frame_path(h,stage)
  if not FileAccess.file_exists(path): continue
  var image := Image.load_from_file(path)
  if image == null: continue
  var art := TextureRect.new(); art.texture = ImageTexture.create_from_image(image); art.custom_minimum_size = Vector2(0,200); art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; box.add_child(art)
  h.sheets.caption(h,["The plan begins","The grove recovers","Sola reaches the flowers","The dormant corner blooms"][stage],box)
 h.button("Record the current island",func(): h.modal.hide(); await capture(h); show(h),box)
 h.button("Share animated river story",func(): share(h,true),box)
 h.button("Export / share story strip",func(): share(h,false),box)
 h.button("Delete local river images",func():
  for stage in range(4):
   var path := frame_path(h,stage)
   if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
  show(h),box)
 h.button("Back to the Living River",func(): h.corridor_ui.show(h),box)
func export_strip(h) -> String:
 var frames := []
 for stage in range(4):
  var path := frame_path(h,stage)
  if not FileAccess.file_exists(path): continue
  var image := Image.load_from_file(path)
  if image != null: frames.append(image)
 if frames.is_empty(): return ""
 var height: int = frames[0].get_height(); var width: int = frames[0].get_width()
 var strip := Image.create(width*frames.size(),height,false,Image.FORMAT_RGBA8)
 strip.fill(Color("233b3b"))
 for index in range(frames.size()):
  var image: Image = frames[index]
  image.resize(width,height); image.convert(Image.FORMAT_RGBA8)
  strip.blit_rect(image,Rect2i(0,0,width,height),Vector2i(index*width,0))
 var path := "user://river-story-%d.png" % int(h.model.state.seed)
 return path if strip.save_png(path) == OK else ""
func share(h, animated: bool = false) -> void:
 var path := ""
 if animated:
  var frames := []
  for stage in range(4):
   if FileAccess.file_exists(frame_path(h,stage)):
    var image := Image.load_from_file(frame_path(h,stage))
    if image != null: frames.append(image)
  var output := "user://river-story-%d.gif" % int(h.model.state.seed)
  if preload("res://scripts/StoryGif.gd").save(output,frames): path = output
 else: path = export_strip(h)
 if path == "": h.model.message = "Record a river moment before exporting its story."; h.refresh(); return
 if h.services.bridge != null and h.services.bridge.has_method("shareImage"): h.services.bridge.shareImage(ProjectSettings.globalize_path(path))
 else: h.model.message = ("Animated story" if animated else "Story strip")+" saved locally: "+ProjectSettings.globalize_path(path); h.refresh()
