extends Node2D
const Model = preload("res://scripts/WorldModel.gd")
const Store = preload("res://scripts/SaveStore.gd")
var presentation = preload("res://scripts/WorldPresentation.gd").new()
var audio_feedback = preload("res://scripts/AudioFeedback.gd").new()
var campaign_ui = preload("res://scripts/CampaignUI.gd").new()
var services = preload("res://scripts/ServiceHub.gd").new()
var placement_blueprint := ""
var show_menu_on_launch := true
var launch_menu := false
var launch_screen: VBoxContainer
var photo_mode := false
var photo_controls: HBoxContainer
var photo_light_button: Button
var photo_lighting := "day"
var ui_root: Control
var model = Model.new()
var store = Store.new()
var zoom_level := 1.0
var pan := Vector2.ZERO
var selected := "0,0"
var targeting := ""
var preview := ""
var input_controller = preload("res://scripts/InputController.gd").new()
var bottom: VBoxContainer
var modal_box: VBoxContainer
var layout := {}
var hud: VBoxContainer
var info: Label
var notice: Label
var objective: Label
var pulse_bar: ProgressBar
var rain_button: Button
var heat_button: Button
var draft_button: Button
var inventory: RichTextLabel
var draft_cards: Array[Button] = []
var confirm_card: Button
var inspection_view := {}
var cosmetic_clock := 0.0
var inspection_mode := false
var inspection_drag_start := Vector2.ZERO
var all_touches := {}
var mixed_touch_sequence := false
var reveal_queue := []
var seen_discoveries := []
var modal_screen := ""
var modal: PanelContainer
var performance_checked_at := 0.0
var clock := 0.0
var save_clock := 0.0
var save_dirty := false
var dirty_elapsed := 0.0
var last_discoveries := 0
var suspended := false
var discard_resume_delta := false

func _ready() -> void:
 add_child(audio_feedback)
 services.model = model
 add_child(services)
 services.changed.connect(func():
  refresh(); persist()
  if modal.visible and modal_screen == "services": services_ui()
  elif modal.visible and modal_screen == "draft": draft()
  elif modal.visible and modal_screen == "codex_detail": campaign_ui.detail(self,campaign_ui.focus_id))
 var loaded = store.load_state()
 if not loaded.is_empty():
  model.state = loaded
  if store.error != "": model.message = store.error
 services.model = model
 services.save_path = store.path
 seen_discoveries = model.state.discoveries.duplicate()
 build_ui()
 apply_settings()
 services.begin_session()
 model.occurred.connect(services.event)
 get_viewport().size_changed.connect(apply_layout)
 apply_layout()
 input_controller.tapped.connect(tap)
 input_controller.inspected.connect(inspect)
 input_controller.panned.connect(func(delta): pan += delta; constrain_camera(); queue_redraw())
 input_controller.zoomed.connect(func(factor): zoom_level = clampf(zoom_level*factor,0.5,2.0); constrain_camera(); queue_redraw())
 refresh()
 if show_menu_on_launch: start_screen()
 elif not model.state.pending.is_empty(): draft()

func panel_style(color: Color) -> StyleBoxFlat:
 var s := StyleBoxFlat.new()
 s.bg_color = color
 s.set_corner_radius_all(18)
 s.set_border_width_all(1)
 s.border_color = Color(0.95,0.77,0.43,0.22)
 s.shadow_color = Color(0,0,0,0.15)
 s.shadow_size = 3
 s.content_margin_left = 16
 s.content_margin_right = 16
 s.content_margin_top = 12
 s.content_margin_bottom = 12
 return s

func label(text: String, size: int, parent: Node) -> Label:
 var l := Label.new()
 l.text = tr(text)
 l.set_meta("base_font",size)
 l.add_theme_font_size_override("font_size",scaled_font(size))
 l.add_theme_color_override("font_color",Color("fff4dc"))
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(l)
 return l

func button(text: String, action: Callable, parent: Node) -> Button:
 var b := Button.new()
 b.text = tr(text)
 b.set_meta("base_font",17)
 b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 b.custom_minimum_size.y = touch_height()
 b.add_theme_font_size_override("font_size",scaled_font(17))
 b.add_theme_color_override("font_color",Color("fff4dc"))
 b.add_theme_stylebox_override("normal",panel_style(Color("2e785d")))
 b.add_theme_stylebox_override("hover",panel_style(Color("408f75")))
 b.add_theme_stylebox_override("pressed",panel_style(Color("31516b")))
 b.add_theme_stylebox_override("disabled",panel_style(Color("263b3b")))
 b.add_theme_color_override("font_disabled_color",Color("b2c1b7"))
 var focus := panel_style(Color(0,0,0,0))
 focus.border_color = Color("f2c46d")
 focus.set_border_width_all(2)
 b.add_theme_stylebox_override("focus",focus)
 b.pressed.connect(action)
 parent.add_child(b)
 return b

func build_ui() -> void:
 var layer := CanvasLayer.new()
 add_child(layer)
 var root := Control.new()
 ui_root = root
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layer.add_child(root)
 hud = VBoxContainer.new()
 hud.position = Vector2(22,28)
 hud.size.x = 496
 root.add_child(hud)
 label("POCKET BIOME",30,hud)
 label("T I N Y   E X P A N S I O N",13,hud)
 inventory = RichTextLabel.new()
 inventory.fit_content = true
 inventory.scroll_active = false
 inventory.mouse_filter = Control.MOUSE_FILTER_IGNORE
 inventory.add_theme_font_size_override("normal_font_size",17)
 inventory.add_theme_color_override("default_color",Color("e4e9df"))
 inventory.tooltip_text = "Coins · Pulse energy · Wood · Stone · Fiber · Occupied land"
 hud.add_child(inventory)
 pulse_bar = ProgressBar.new()
 pulse_bar.max_value = 200
 pulse_bar.show_percentage = false
 pulse_bar.custom_minimum_size.y = 5
 pulse_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var track := StyleBoxFlat.new()
 track.bg_color = Color("263c48")
 track.set_corner_radius_all(3)
 var fill := track.duplicate()
 fill.bg_color = Color("f2c46d")
 pulse_bar.add_theme_stylebox_override("background",track)
 pulse_bar.add_theme_stylebox_override("fill",fill)
 hud.add_child(pulse_bar)
 objective = label("",18,hud)
 label("OFFLINE · AUTOSAVE",11,hud)
 bottom = VBoxContainer.new()
 bottom.position = Vector2(22,690)
 bottom.size.x = 496
 root.add_child(bottom)
 info = label("",15,bottom)
 notice = label("",17,bottom)
 notice.max_lines_visible = 2
 info.max_lines_visible = 3
 var row := HBoxContainer.new()
 bottom.add_child(row)
 rain_button = button("Rain · 100",func(): target("rain"),row)
 heat_button = button("Heat · 100",func(): target("heat"),row)
 button_icon(rain_button,"rain"); button_icon(heat_button,"heat")
 button("Recenter",frame_world,row)
 button("Fusion",fusion_dialog,row)
 draft_button = button("Resume draft",func():
  if placement_blueprint != "":
   placement_blueprint = ""
   model.message = "Placement canceled. Blueprint kept."
   refresh()
  elif targeting != "": cancel_target()
  else: draft(),bottom)
 var navigation := HBoxContainer.new()
 bottom.add_child(navigation)
 var journal_button := button("Journal",func(): campaign_ui.journal(self),navigation)
 button_icon(journal_button,"codex")
 button("Craft",func(): campaign_ui.workshop(self),navigation)
 button("World",func(): campaign_ui.world(self),navigation)
 var settings_button := button("Options",func(): campaign_ui.settings(self),navigation)
 button_icon(settings_button,"settings")
 label("Drag to pan · Pinch / wheel to zoom · Hold to inspect",12,bottom)
 photo_controls = HBoxContainer.new()
 photo_controls.position = Vector2(20,880)
 photo_controls.size.x = 500
 root.add_child(photo_controls)
 photo_light_button = button("Light",func():
  photo_lighting = "dusk" if photo_lighting != "dusk" else "day"
  queue_redraw(),photo_controls)
 photo_light_button.tooltip_text = "Day / Dusk photo preview · unlocks in Chapter 2"
 button("Capture",capture_photo,photo_controls)
 button("Share",share_photo,photo_controls)
 button("Exit photo",end_photo,photo_controls)
 photo_controls.hide()
 modal = PanelContainer.new()
 modal.position = Vector2(20,240)
 modal.size = Vector2(500,400)
 modal.add_theme_stylebox_override("panel",panel_style(Color("17243a")))
 root.add_child(modal)
 modal.hide()

func cancel_target() -> void:
 targeting = ""
 preview = ""
 model.message = "Pulse canceled. No energy spent."
 refresh()

func pulse_selector() -> void:
 var box := modal_content("World Pulse")
 var energy: int = model.state.energy
 label(("Ready" if energy >= 100 else "Charging")+" · %d / 200 energy" % energy,19,box)
 var descriptions := {"rain":"Refresh moisture across the selected cross.","heat":"Warm the ground and clear Dusk frost.","frost":"Cool the land and invite frozen discoveries."}
 for power in ["rain","heat","frost"]:
  var action: Button = button(power.capitalize()+" · 100 energy",func(): modal.hide(); target(power),box)
  button_icon(action,power)
  action.disabled = energy < 100 or (power == "frost" and model.state.chapter < 2)
  label("Unlocks in Chapter 2" if power == "frost" and model.state.chapter < 2 else descriptions[power],15,box)
 button("Back to island",func(): modal.hide(),box)

func target(power: String) -> void:
 if targeting == power:
  cancel_target()
  return
 targeting = power
 preview = selected
 model.message = "Tap to preview an area; tap its center again to confirm. Cost 100."
 refresh()

func modal_content(title: String) -> VBoxContainer:
 modal_screen = ""
 inspection_view.clear()
 inspection_mode = false
 for child in modal.get_children():
  modal.remove_child(child)
  child.queue_free()
 var scroll := ScrollContainer.new()
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 modal.add_child(scroll)
 modal_box = VBoxContainer.new()
 modal_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 modal_box.add_theme_constant_override("separation",14)
 scroll.add_child(modal_box)
 label(title,24,modal_box)
 input_controller.reset()
 modal.show()
 return modal_box

func draft() -> void:
 if model.state.pending.is_empty():
  model.message = "Tap a cloud plot to open its three-card draft."
  refresh()
  return
 var box := modal_content("Choose Your Next Biome")
 modal_screen = "draft"
 draft_cards.clear()
 label("One card · %d Coins on placement · inspect a card, then confirm." % model.state.pending.cost,16,box)
 for i in range(3):
  var type: String = model.state.pending.cards[i]
  var definition: Dictionary = model.config.tiles[type]
  var panel := PanelContainer.new()
  var style := panel_style(Color("20394a"))
  style.border_color = rarity_color(definition.rarity)
  panel.add_theme_stylebox_override("panel",style)
  box.add_child(panel)
  var row := HBoxContainer.new()
  panel.add_child(row)
  var preview_art = preload("res://scripts/TileThumbnail.gd").new()
  preview_art.tile_type = type; preview_art.extent = 100
  row.add_child(preview_art)
  var content := VBoxContainer.new()
  content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  row.add_child(content)
  label(type.capitalize()+" · "+definition.rarity.capitalize(),18,content)
  label(definition.category.capitalize()+" · "+card_hint(type),14,content)
  draft_cards.append(button("Inspect "+type.capitalize(),func(): inspect_card(i),content))
 if not model.state.pending.get("ad_rerolled",false):
  var reroll := button("Optional test ad · one new draft",func(): services.request_reward("reroll"),box)
  reroll.disabled = not services.ad_ready or not services.reward_available()
 button("Keep choice for later",func(): modal.hide(); persist(),box)

func inspect_card(index: int) -> void:
 audio_feedback.play("card")
 if model.state.pending.is_empty() or index < 0 or index > 2: return
 var type: String = model.state.pending.cards[index]
 var definition: Dictionary = model.config.tiles[type]
 var box := modal_content(type.capitalize()+" · "+definition.rarity.capitalize())
 var image = preload("res://scripts/TileThumbnail.gd").new()
 image.tile_type = type; image.extent = 180
 box.add_child(image)
 label(card_hint(type),18,box)
 if definition.resource != "": label("Produces 1 %s every %ds" % [definition.resource.capitalize(),definition.cooldown],16,box)
 for i in range(5): dna_bar(box,model.config.attributes[i],definition.dna[i])
 confirm_card = button("Place here · %d Coins" % model.state.pending.cost,func():
  if model.place(index):
   modal.hide(); haptic(22)
  persist(); refresh(),box)
 button("Back to three cards",draft,box)

func rarity_color(rarity: String) -> Color:
 return {"common":Color("8ea18f"),"uncommon":Color("78d4a2"),"rare":Color("a58be8"),"legendary":Color("f2c46d")}.get(rarity,Color("8ea18f"))

func dna_bar(parent: Node, attribute: String, value: float) -> Dictionary:
 var caption: Label = label("%s · %d" % [attribute.capitalize(),value],15,parent)
 var bar := ProgressBar.new()
 bar.max_value = 100; bar.value = value; bar.show_percentage = false
 bar.custom_minimum_size.y = 7
 var track := StyleBoxFlat.new(); track.bg_color = Color("263c48"); track.set_corner_radius_all(3)
 var fill := track.duplicate()
 fill.bg_color = {"moisture":Color("8dbfe8"),"heat":Color("e9a06d"),"fertility":Color("78d4a2"),"stability":Color("b3b6b9"),"magic":Color("a58be8")}[attribute]
 bar.add_theme_stylebox_override("background",track); bar.add_theme_stylebox_override("fill",fill)
 parent.add_child(bar)
 return {"caption":caption,"bar":bar}

func fusion_dialog() -> void:
 var box := modal_content("Evolve a 2 × 2 sanctuary")
 label("Select the upper origin of four matching Forest, Water, Stone or Grass cells with no active pulse boosts. The entire footprint becomes one entity.",18,box)
 button("Confirm fusion",func():
  if not model.fuse(selected): model.message = "Needs four matching Forest, Water, Stone or Grass cells in a 2 × 2 square."
  modal.hide()
  persist()
  refresh(),box)
 button("Back",func(): modal.hide(),box)

func queue_save() -> void:
 if not save_dirty: dirty_elapsed = 0.0
 save_dirty = true

func persist() -> void:
 dirty_elapsed = 0.0
 save_dirty = not store.save_state(model.state)
 if save_dirty:
  model.message = "Save failed: " + store.error
  services.event("save_failed",{"reason":store.error})

func refresh() -> void:
 for id in model.state.discoveries:
  if seen_discoveries.has(id): continue
  seen_discoveries.append(id)
  for recipe in model.config.recipes+model.config.fusions:
   if recipe.id == id and recipe.rarity in ["rare","legendary"]: reveal_queue.append(id)
 presentation.sync(model.state.tiles)
 if model.state.settings.reduced_motion: presentation.advance(10.0)
 services.model = model
 services.save_path = store.path
 for cue in presentation.cues:
  if model.state.settings.sfx: audio_feedback.play(cue)
 photo_light_button.disabled = model.state.chapter < 2
 pulse_bar.value = model.state.energy
 rain_button.disabled = model.state.energy < 100
 heat_button.disabled = model.state.energy < 100
 draft_button.text = "Cancel placement" if placement_blueprint != "" else ("Cancel pulse" if targeting != "" else "Resume draft")
 draft_button.disabled = targeting == "" and placement_blueprint == "" and model.state.pending.is_empty()
 draft_button.visible = not draft_button.disabled
 inventory.add_theme_font_size_override("normal_font_size",scaled_font(17))
 inventory.clear()
 for resource in ["coins","rain","wood","stone","fiber"]:
  if resource == "wood": inventory.add_text("\n")
  elif resource != "coins": inventory.add_text("   ")
  inventory.add_image(preload("res://scripts/UIIcons.gd").texture(resource),28,28,Color.WHITE,INLINE_ALIGNMENT_CENTER)
  var amount: int = model.state.coins if resource == "coins" else model.state.energy if resource == "rain" else model.state.inventory[resource]
  inventory.add_text(" %d" % amount + ("/200" if resource == "rain" else ""))
 inventory.add_text("   Land %d/36" % model.state.tiles.size())
 objective.text = model.objective_text()
 notice.text = model.message
 var k: String = model.origin(selected)
 if k != "":
  var t: Dictionary = model.state.tiles[k]
  info.text = "%s · ready in %ds\n" % [tile_title(t),ceili(maxf(0,t.ready-model.state.time))]
  for a in model.config.attributes: info.text += "%s %d  " % [{"moisture":"Water","heat":"Heat","fertility":"Growth","stability":"Rock","magic":"Magic"}[a],t.dna[a]]

 update_inspection()
 campaign_ui.update_live(self)
 last_discoveries = model.state.discoveries.size()
 call_deferred("apply_layout")
 queue_redraw()

func project(c: Vector2) -> Vector2:
 return Vector2((c.x-c.y)*66,(c.x+c.y)*33)

func screen(c: Vector2) -> Vector2:
 return world_anchor()+pan+project(c)*zoom_level

func hit(pos: Vector2) -> String:
 var p := (pos-world_anchor()-pan)/zoom_level
 var c := Vector2(p.x/132+p.y/66,p.y/66-p.x/132)
 return model.key(Vector2i(roundi(c.x),roundi(c.y)))

func tap(pos: Vector2) -> void:
 if launch_menu or photo_mode or not world_rect().has_point(pos) or modal.visible: return
 var harvest_path := false
 var k := pick(pos)
 if placement_blueprint != "":
  if model.deploy(placement_blueprint,k):
   placement_blueprint = ""
   services.event("structure_placed")
  else: model.message = "Choose an empty Grass tile. Blueprint kept."
 elif targeting != "":
  if model.origin(k) != "" and preview != model.origin(k):
   preview = model.origin(k)
   model.message = "Area preview · tap center again to confirm; choose another tile to move it."
  elif model.pulse(targeting,k):
   presentation.pulse(targeting,model.origin(k))
   targeting = ""
   haptic(35)
   audio_feedback.play("pulse")
  else: model.message = "Choose land with at least 100 energy. No energy spent."
 elif model.state.tiles.has(k):
  harvest_path = true
  selected = model.origin(k)
  var before: Dictionary = model.state.inventory.duplicate()
  if model.harvest(selected):
   haptic(18)
   var output: String = model.production(model.state.tiles[selected]).resource
   audio_feedback.play("wood" if output == "wood" else "stone" if output in ["stone","iron","clay"] else "water" if model.state.tiles[selected].type == "water" else "harvest")
   for resource in before:
    var delta: int = model.state.inventory[resource]-before[resource]
    if delta > 0: presentation.harvest(selected,"+%d %s" % [delta,resource.replace("_"," ").capitalize()],resource)
 elif model.begin_draft(k): draft()
 if harvest_path: queue_save()
 else: persist()
 refresh()

func _unhandled_input(event: InputEvent) -> void:
 if mixed_touch_sequence:
  input_controller.reset()
  return
 if modal.visible:
  input_controller.reset()
  return
 input_controller.feed(event,world_rect(),Time.get_ticks_msec()/1000.0)

func apply_layout() -> void:
 var viewport_size := get_viewport_rect().size
 var safe := Rect2(Vector2.ZERO,viewport_size)
 if OS.get_name() == "Android" or OS.get_name() == "iOS":
  var physical := Vector2(DisplayServer.screen_get_size())
  safe = preload("res://scripts/SafeLayout.gd").logical_safe_rect(viewport_size,physical,Rect2(DisplayServer.get_display_safe_area()))
 layout = preload("res://scripts/SafeLayout.gd").regions(safe,maxf(185,hud.get_combined_minimum_size().y),maxf(305,bottom.get_combined_minimum_size().y))
 hud.position = layout.top.position
 hud.size.x = layout.top.size.x
 bottom.position = layout.bottom.position
 bottom.size.x = layout.bottom.size.x
 modal.position = layout.modal.position
 modal.size = layout.modal.size
 if inspection_mode:
  modal.position.y = maxf(layout.modal.position.y,get_viewport_rect().size.y*0.44)
  modal.size.y = layout.modal.end.y-modal.position.y
 photo_controls.position = Vector2(safe.position.x+20,safe.end.y-touch_height()-12)
 photo_controls.size.x = safe.size.x-40
 constrain_camera()
 queue_redraw()

func world_rect() -> Rect2:
 if photo_mode: return Rect2(20,40,get_viewport_rect().size.x-40,get_viewport_rect().size.y-150)
 return layout.get("world",Rect2(0,205,540,475))

func world_anchor() -> Vector2:
 return world_rect().get_center()-Vector2(0,45)


func constrain_camera() -> void:
 # Keep at least the island's projected center reachable in the play area.
 var bounds := Rect2()
 var initialized := false
 for k in model.state.tiles:
  var point := project(model.coord(k))*zoom_level
  if not initialized: bounds = Rect2(point,Vector2.ZERO); initialized = true
  else: bounds = bounds.expand(point)
 var area := world_rect().grow(-48)
 var anchor := world_anchor()
 pan.x = clampf(pan.x,area.position.x-anchor.x-bounds.end.x,area.end.x-anchor.x-bounds.position.x)
 pan.y = clampf(pan.y,area.position.y-anchor.y-bounds.end.y,area.end.y-anchor.y-bounds.position.y)

func _process(delta: float) -> void:
 if not launch_menu and not photo_mode and not modal.visible and not reveal_queue.is_empty(): show_discovery(reveal_queue.pop_front())
 if suspended or launch_menu: return
 if discard_resume_delta:
  discard_resume_delta = false
  return
 model.advance_time(delta)
 if save_dirty:
  dirty_elapsed += delta
  if dirty_elapsed >= 0.35: persist()
 cosmetic_clock += delta
 if cosmetic_clock >= 0.12 and not model.state.settings.reduced_motion:
  cosmetic_clock = 0.0
  queue_redraw()
 if model.state.settings.reduced_motion:
  if presentation.advance(10.0): queue_redraw()
 elif presentation.advance(delta): queue_redraw()
 clock += delta
 save_clock += delta
 if clock >= 1.0:
  clock -= 1.0
  model.tick(0.0)
  model.expire_boosts()
  if int(model.state.time)%30 == 0: services.flush_telemetry()
  if model.state.time-performance_checked_at >= 30:
   performance_checked_at = model.state.time
   if Engine.get_frames_per_second() > 0 and Engine.get_frames_per_second() < 25: services.event("performance_warning",{"fps":Engine.get_frames_per_second()})
  if save_clock >= 5.0 or model.state.discoveries.size() != last_discoveries:
   save_clock = 0.0
   persist()
  refresh()

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
  input_controller.reset()
  all_touches.clear(); mixed_touch_sequence = false
 if what == NOTIFICATION_WM_GO_BACK_REQUEST:
  if modal.visible: modal.hide()
  elif photo_mode: end_photo()
  elif targeting != "": cancel_target()
  elif launch_menu:
   services.event("session_ended")
   get_tree().quit()
  else: start_screen()
 if what == NOTIFICATION_APPLICATION_PAUSED:
  if audio_feedback.ambience != null: audio_feedback.ambience.stream_paused = true
  services.event("session_backgrounded")
  suspended = true
  persist()
 elif what == NOTIFICATION_APPLICATION_RESUMED:
  apply_settings()
  suspended = false
  discard_resume_delta = true
 elif what == NOTIFICATION_WM_CLOSE_REQUEST:
  services.event("session_ended")
  persist()

func polygon(points: Array, color: Color) -> void:
 draw_colored_polygon(PackedVector2Array(points),color)

func tile_fraction(tile: Dictionary, attribute: String) -> float:
 return clampf(float(tile.dna[attribute])/100.0,0.0,1.0)

func visible_palette() -> String:
 return photo_lighting if photo_mode else model.state.cosmetic

func _draw() -> void:
 var palette: String = visible_palette()
 if palette != "day":
  var palettes := {"moon":Color("101b38"),"dusk":Color("30263e"),"celestial":Color("182d36"),"sakura":Color("322d41")}
  draw_rect(get_viewport_rect(),palettes.get(palette,Color("17243a")))
  for i in range(28):
   draw_circle(Vector2(fmod(i*137.0,540),180+fmod(i*97.0,450)),1.0+float(i%2),Color(0.95,0.82,0.56,0.4))
 # Candidate atlas renderer; final evolved artwork and edge cleanup pending approval.
 for i in range(16):
  var pos := Vector2(fmod(i*193.0,540),220+fmod(i*117.0,420))
  draw_circle(pos,30+float(i%3)*12,Color(0.6,0.8,0.9,0.035))
 for k in model.frontier():
  var p := screen(model.coord(k))
  var r := 25*zoom_level
  preload("res://scripts/TileArtwork.gd").draw_tile(self,"cloud",p,132.0/418.0*zoom_level*0.72,Color(0.82,0.92,1,0.5))
  draw_line(p-Vector2(7,0),p+Vector2(7,0),Color("8dbfe8"),2)
  draw_line(p-Vector2(0,7),p+Vector2(0,7),Color("8dbfe8"),2)
 var keys := render_keys()
 for k in keys:
  var t: Dictionary = model.state.tiles[k]
  if t.has("owner"): continue
  var size: float = 2.0 if t.size == 4 else 1.0
  var offset := Vector2(0.5,0.5) if size == 2 else Vector2.ZERO
  var p := screen(Vector2(model.coord(k))+offset)
  var pose: Dictionary = presentation.pose(k)
  p.y += pose.rise*zoom_level
  var s := zoom_level
  if pose.burst > 0:
   for i in range(10):
    var angle := TAU*i/10.0
    var spark: Vector2 = p+Vector2(cos(angle),sin(angle)*0.6)*(35+30*pose.burst)*s
    draw_circle(spark,2.5*pose.burst,Color(0.95,0.77,0.43,pose.burst))
  var tint := Color(1,1,1,pose.mix)
  # Gentle authored-state modulation: DNA remains readable without replacing sprites.
  var heat: float = tile_fraction(t,"heat")
  var fertility: float = tile_fraction(t,"fertility")
  if t.type in ["forest","oak","grass","fiber","dirt"]:
   tint *= Color(1.0-fertility*0.035,1.0-heat*0.025,1.0-heat*0.07)
  elif t.type == "water":
   var moisture: float = tile_fraction(t,"moisture")
   tint *= Color(0.9+moisture*0.1,0.95+moisture*0.05,1)
  if palette == "moon": tint *= Color(0.82,0.88,1.0)
  elif palette == "celestial": tint *= Color(1.0,0.97,0.81)
  draw_ellipse_shadow(p+Vector2(0,35*zoom_level),60*zoom_level*size)
  if not pose.parts.is_empty():
   var pull: float = clampf(pose.progress/0.5,0,1)
   for part in pose.parts:
    var source: Vector2 = screen(model.coord(part.key))
    var location: Vector2 = source.lerp(p,pull)
    draw_arc(source,28*zoom_level,0,TAU,24,Color(1,0.85,0.5,1.0-pull),2*zoom_level)
    draw_line(source,p,Color(0.95,0.77,0.43,(1.0-pull)*0.5),2*s)
    preload("res://scripts/TileArtwork.gd").draw_tile(self,part.type,location,132.0/418.0*zoom_level*(1.0-pull*0.8),Color(1,1,1,1.0-pull),part.evolution)
  if pose.mix < 1.0 and not pose.previous.is_empty() and pose.parts.is_empty():
   preload("res://scripts/TileArtwork.gd").draw_tile(self,pose.previous.type,p,132.0/418.0*zoom_level*size*pose.scale,Color(1,1,1,1.0-pose.mix),pose.previous.evolution)
  preload("res://scripts/TileArtwork.gd").draw_tile(self,t.type,p,132.0/418.0*zoom_level*size*pose.scale,tint,t.evolution,t.ready > model.state.time)
  if model.state.event.targets.has(k) and not model.state.event.cleared.has(k):
   var frost := p-Vector2(0,30*s)
   for i in range(3):
    var ray := Vector2.from_angle(PI*i/3.0)*12*s
    draw_line(frost-ray,frost+ray,Color("b8e9ff"),2*s)
  if t.dna.magic >= 70 or t.dna.heat >= 85:
   var magical: bool = t.dna.magic >= 70
   var glow_tint := Color("b5a2ed") if magical else Color("eeac6b")
   for mote in range(2):
    var phase: float = float(t.id)*1.7+mote*3.0
    if not model.state.settings.reduced_motion: phase += model.state.time*0.8
    var mote_position := p+Vector2(sin(phase)*22,-28-12*cos(phase))*s
    glow_tint.a = 0.25+0.25*absf(sin(phase))
    draw_circle(mote_position,1.8*s,glow_tint)
  if palette == "celestial" and model.state.entitlements.has("founders"):
   # Cosmetic only: the Founder's Collection never changes production or DNA.
   for star in range(3):
    var phase: float = model.state.time*0.7+float(t.id+star)*2.1 if not model.state.settings.reduced_motion else float(t.id+star)
    var glow := p+Vector2(sin(phase)*35,-35-cos(phase*0.8)*22)*s
    var opacity: float = 0.35+0.35*absf(sin(phase))
    draw_circle(glow,2*s,Color(1,0.85,0.5,opacity))
    draw_line(glow-Vector2(4,0)*s,glow+Vector2(4,0)*s,Color(1,0.85,0.5,opacity),s)
  if selected == k or affected(k): draw_arc(p,38*s*size,0,TAU,32,Color("f2c46d"),2*s)

 for effect in presentation.weather:
  var center := entity_screen(effect.key)
  var elapsed: float = effect.elapsed
  var color: Color = {"rain":Color("8dbfe8"),"heat":Color("f2a56d"),"frost":Color("d3f4ff")}[effect.power]
  color.a = 1.0-elapsed/1.2
  draw_arc(center,(35+elapsed*55)*zoom_level,0,TAU,32,color,2*zoom_level)
  for i in range(12):
   var angle := TAU*i/12.0
   var at: Vector2 = center+Vector2(cos(angle),sin(angle)*0.55)*(35+elapsed*45)*zoom_level
   if effect.power == "rain": draw_line(at-Vector2(3,10)*zoom_level,at,color,2*zoom_level)
   else: draw_circle(at,(2+sin(angle))*zoom_level,color)
 for effect in presentation.harvests:
  var at := entity_screen(effect.key)+Vector2(-24,-55-effect.elapsed*30)*zoom_level
  var flight: float = clampf(effect.elapsed/0.4,0,1)
  var icon_at: Vector2 = entity_screen(effect.key).lerp(inventory.global_position+Vector2(18,12),1-pow(1-flight,2))
  if flight < 1: preload("res://scripts/UIIcons.gd").draw(self,effect.resource,icon_at,32,Color(1,1,1,1-flight*0.6))
  draw_string(ThemeDB.fallback_font,at,effect.text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(0.95,0.83,0.56,1-effect.elapsed/0.8))
 if photo_mode:
  draw_string(ThemeDB.fallback_font,Vector2(22,get_viewport_rect().size.y-25),"POCKET BIOME · TINY EXPANSION",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("fff4dc"))

func draw_ellipse_shadow(p: Vector2,w: float) -> void:
 var points := PackedVector2Array()
 for i in range(32): points.append(p+Vector2(cos(i*TAU/32)*w,sin(i*TAU/32)*w*0.32))
 draw_colored_polygon(points,Color(0,0,0,0.14))

func affected(k: String) -> bool:
 return targeting != "" and model.pulse_targets(preview).has(k)

func inspect(pos: Vector2) -> void:
 if photo_mode or not world_rect().has_point(pos): return
 var key := model.origin(pick(pos))
 if key == "": return
 selected = key
 var tile: Dictionary = model.state.tiles[key]
 var box := modal_content(tile_title(tile))
 inspection_mode = true
 var image = preload("res://scripts/TileThumbnail.gd").new()
 image.tile_type = tile.type; image.evolution = tile.evolution; image.extent = 130
 box.add_child(image)
 inspection_view = {"key":key,"title":box.get_child(0),"image":image,"bars":{},"conditions":[]}
 var production: Dictionary = model.production(tile)
 if production.resource != "": inspection_view["production"] = label("%d %s · %ds cycle · ready in %ds" % [production.amount,production.resource.replace("_"," ").capitalize(),production.cooldown,ceili(maxf(0,tile.ready-model.state.time))],16,box)
 else: label(card_hint(tile.type),16,box)
 for attribute in model.config.attributes: inspection_view.bars[attribute] = dna_bar(box,attribute,tile.dna[attribute])
 label("Neighbor influences",19,box)
 var count := 0
 for neighbor in model.neighbors(key):
  var source: Dictionary = model.state.tiles[neighbor]
  var effects: Dictionary = model.config.effects.get(source.type,{})
  if effects.is_empty(): continue
  var text: String = source.type.capitalize()+" · "
  if not source.get("enabled",true): text += "Paused"
  else:
   for attribute in effects: text += "%+d %s " % [effects[attribute]*source.get("level",1),attribute]
   text += "every %ds" % model.config.tiles[source.type].get("effect_interval",1)
  label(text,14,box); count += 1
 if count == 0: label("No environmental sources nearby.",14,box)
 label("Discovery opportunities",19,box)
 for recipe in model.config.recipes:
  if not tile.type in recipe.types: continue
  var caption: Label = label(recipe.name+" · "+recipe_conditions(tile,recipe),14,box)
  inspection_view.conditions.append({"recipe":recipe,"caption":caption})
 button("Back to island",dismiss_inspection,box)
 apply_layout()

func recipe_conditions(tile: Dictionary, recipe: Dictionary) -> String:
 var reasons := PackedStringArray()
 for attribute in recipe.min:
  if tile.dna[attribute] < recipe.min[attribute]: reasons.append("%s %d / %d" % [attribute,tile.dna[attribute],recipe.min[attribute]])
 for attribute in recipe.max:
  if tile.dna[attribute] > recipe.max[attribute]: reasons.append("%s must be ≤ %d" % [attribute,recipe.max[attribute]])
 for structure in recipe.structures:
  if not model.campaign.has_structure(model,structure): reasons.append("Needs "+structure.capitalize())
 if recipe.pulse != "" and (tile.get("last_pulse","") != recipe.pulse or tile.get("last_pulse_until",0) < model.state.time): reasons.append("Recent "+recipe.pulse.capitalize()+" Pulse")
 return "Conditions met" if reasons.is_empty() else "; ".join(reasons)

func update_inspection() -> void:
 if not inspection_mode or not modal.visible or inspection_view.is_empty(): return
 var at: String = model.origin(inspection_view.key)
 if at == "": dismiss_inspection(); return
 var tile: Dictionary = model.state.tiles[at]
 inspection_view.title.text = tile_title(tile)
 inspection_view.image.evolution = tile.evolution
 inspection_view.image.queue_redraw()
 var production: Dictionary = model.production(tile)
 if inspection_view.has("production"):
  inspection_view.production.text = "%d %s · %ds cycle · ready in %ds" % [production.amount,production.resource.replace("_"," ").capitalize(),production.cooldown,ceili(maxf(0,tile.ready-model.state.time))]
 for attribute in inspection_view.bars:
  var widgets: Dictionary = inspection_view.bars[attribute]
  widgets.caption.text = "%s · %d" % [attribute.capitalize(),tile.dna[attribute]]
  widgets.bar.value = tile.dna[attribute]
 for condition in inspection_view.conditions:
  condition.caption.text = condition.recipe.name+" · "+recipe_conditions(tile,condition.recipe)

func dismiss_inspection() -> void:
 inspection_mode = false
 modal.hide()
 input_controller.reset()

func tile_title(tile: Dictionary) -> String:
 for fusion in model.config.fusions:
  if tile.evolution == fusion.id: return fusion.name
 for recipe in model.config.recipes:
  if recipe.id == tile.evolution: return recipe.name
 return tile.type.capitalize()

func apply_settings() -> void:
 audio_feedback.process_mode = Node.PROCESS_MODE_INHERIT
 var effects: float = model.state.audio_levels.sfx if model.state.settings.sfx else 0.0
 for player in audio_feedback.players: player.volume_db = -80 if effects <= 0 else -10+linear_to_db(effects)
 if audio_feedback.ambience != null:
  var music: float = model.state.audio_levels.music if model.state.settings.music else 0.0
  audio_feedback.ambience.volume_db = -80 if music <= 0 else -20+linear_to_db(music)
  audio_feedback.ambience.stream_paused = music <= 0
 if ui_root != null: update_fonts(ui_root)
 call_deferred("apply_layout")

func update_fonts(node: Node) -> void:
 if node is Control and node.has_meta("base_font"): node.add_theme_font_size_override("font_size",scaled_font(node.get_meta("base_font")))
 for child in node.get_children(): update_fonts(child)

func haptic(duration: int) -> void:
 if model.state.settings.vibration and OS.get_name() in ["Android","iOS"]: Input.vibrate_handheld(duration)

func services_ui() -> void:
 if not modal.visible or modal_screen != "services": services.event("store_opened")
 var box := modal_content("Optional Store · Sandbox")
 modal_screen = "services"
 label(services.status,16,box)
 label("Test advertisements only. Purchases require a Play sandbox tester installation. No paid item is needed to finish the game.",15,box)
 button("Connect optional services",func(): services.initialize_online(),box).disabled = services.bridge == null
 button("Optional test ad · +25 coins",func(): services.request_reward("coins"); modal.hide(),box).disabled = not services.ad_ready or not services.reward_available()
 button("Optional test ad · +100 pulse",func(): services.request_reward("pulse"); modal.hide(),box).disabled = not services.ad_ready or not services.reward_available()
 for product in services.products:
  button(str(product.name)+" · "+str(product.price),func(): services.purchase(product.id),box)
 button("Restore purchases",func(): services.restore(),box).disabled = services.bridge == null
 if model.state.entitlements.has("moon") or model.state.entitlements.has("founders"):
  button("Select Moonlit theme",func(): model.state.cosmetic = "moon"; persist(); refresh(),box)
 if model.state.entitlements.has("founders"):
  button("Select Celestial founder theme",func(): model.state.cosmetic = "celestial"; persist(); refresh(),box)
 button("Use daylight palette",func(): model.state.cosmetic = "day"; persist(); refresh(),box)
 campaign_ui.close_button(self,box)

func frame_world() -> void:
 var bounds := Rect2()
 var first := true
 for key in model.state.tiles:
  var point := project(model.coord(key))
  if first: bounds = Rect2(point,Vector2.ZERO); first = false
  else: bounds = bounds.expand(point)
 bounds = bounds.grow(150)
 var area := world_rect()
 zoom_level = clampf(minf(area.size.x/bounds.size.x,area.size.y/bounds.size.y),0.04 if photo_mode else 0.5,2.0)
 pan = area.get_center()-world_anchor()-bounds.get_center()*zoom_level
 queue_redraw()

func begin_photo() -> void:
 photo_lighting = model.state.cosmetic
 photo_mode = true
 hud.hide(); bottom.hide(); photo_controls.show()
 frame_world()

func end_photo() -> void:
 photo_mode = false
 hud.show(); bottom.show(); photo_controls.hide()
 constrain_camera()
 queue_redraw()

func capture_photo() -> bool:
 photo_controls.hide()
 await RenderingServer.frame_post_draw
 var result := get_viewport().get_texture().get_image().save_png("user://island_photo.png")
 photo_controls.show()
 model.message = "Photo saved in app storage." if result == OK else "Could not save photo."
 return result == OK

func share_photo() -> void:
 var captured: bool = await capture_photo()
 if not captured: return
 if services.bridge != null: services.bridge.shareImage(ProjectSettings.globalize_path("user://island_photo.png"))
 else: model.message = "Photo saved. Native sharing is available in the Android build."

func card_hint(type: String) -> String:
 var hints := {"forest":"Shares fertility · evolves with water","water":"Shares moisture · place beside Oak","crystal":"Shares magic · enchanted reactions","vent":"Shares heat · thermal reactions","glacier":"Cools neighbors · frozen discoveries","grass":"An open meadow for crafting and sanctuary fusion","stone":"Gather Stone · strengthens neighboring ground","clay":"Gather Clay · furnace construction","iron":"Gather Iron · awaken a Golem","workbench":"Craft blueprints from your materials","furnace":"Processes Stone + Wood into Brick; emits heat","windmill":"Generates a Coin every five seconds","golem":"Harvests nearby ready Stone and Iron nodes","totem":"Moisture and faster harvest cooldowns","compost":"Enriches neighboring plants","shrine":"Cultivates fertility and magic","dirt":"Ploughed soil waiting for a new ecology","lantern":"A warm decorative light for your world"}
 return hints.get(type,"Discover a new corner of your world.")

func start_screen() -> void:
 launch_menu = true
 hud.hide(); bottom.hide(); modal.hide()
 if launch_screen != null: launch_screen.queue_free()
 launch_screen = VBoxContainer.new()
 launch_screen.position = layout.top.position+Vector2(0,40)
 launch_screen.size.x = get_viewport_rect().size.x-44
 ui_root.add_child(launch_screen)
 label("POCKET BIOME",34,launch_screen)
 label("T I N Y   E X P A N S I O N",15,launch_screen)
 label("A little world. Endless possibilities.",18,launch_screen)
 var spacer := Control.new()
 spacer.custom_minimum_size.y = maxf(140,world_rect().size.y-140)
 launch_screen.add_child(spacer)
 button("Continue your world" if model.state.harvests > 0 else "Start exploring",start_play,launch_screen)
 button("Settings",func(): campaign_ui.settings(self),launch_screen)
 button("About the game",func():
  var box := modal_content("Pocket Biome · Tiny Expansion")
  label("An offline miniature-world discovery game. Version 0.9 test build. Original synthesized sound; generated art assembled and reviewed for this game. No mandatory ads or purchases.",17,box)
  campaign_ui.close_button(self,box),launch_screen)
 button("Start a new world…",func():
  var box := modal_content("Create another tiny world?")
  label("Your current world will be archived in app storage. This starts a fresh island; permanent purchase entitlements remain.",17,box)
  button("Archive and start fresh",func():
   persist()
   var from := ProjectSettings.globalize_path(store.path)
   var to := ProjectSettings.globalize_path("user://world_archive_%d.json" % int(Time.get_unix_time_from_system()))
   if FileAccess.file_exists(from) and DirAccess.copy_absolute(from,to) != OK:
    model.message = "Could not archive the current world. It has been kept."
    return
   var entitlements: Array = model.state.entitlements.duplicate()
   model = Model.new()
   model.occurred.connect(services.event)
   model.state.entitlements = entitlements
   services.model = model
   presentation = preload("res://scripts/WorldPresentation.gd").new()
   selected = "0,0"; pan = Vector2.ZERO; zoom_level = 1.0
   persist(); refresh(); start_play(),box)
  campaign_ui.close_button(self,box),launch_screen)

func start_play() -> void:
 launch_menu = false
 if launch_screen != null: launch_screen.hide()
 hud.show(); bottom.show(); modal.hide()
 if not model.state.settings.tutorial_seen:
  services.event("tutorial_started")
  model.state.settings.tutorial_seen = true
  persist()
  campaign_ui.welcome(self)
 elif not model.state.pending.is_empty(): draft()
 refresh()

func check_transition_ad() -> void:
 if launch_menu or photo_mode or targeting != "" or placement_blueprint != "" or not reveal_queue.is_empty() or not presentation.animations.is_empty(): return
 services.maybe_interstitial()

func logical_per_dp() -> float:
 if OS.get_name() not in ["Android","iOS"]: return 1.0
 var width := float(DisplayServer.window_get_size().x)
 var dpi := maxf(160.0,float(DisplayServer.screen_get_dpi()))
 return maxf(1.0,get_viewport_rect().size.x/maxf(1,width)*dpi/160.0)

func touch_height() -> float:
 return clampf(48.0*logical_per_dp(),48,96)

func scaled_font(size: int) -> int:
 return roundi(size*maxf(1.0,logical_per_dp()*14.0/17.0)*float(model.state.get("text_scale",1.0)))

func render_keys() -> Array:
 var keys := []
 for key in model.state.tiles:
  if not model.state.tiles[key].has("owner"): keys.append(key)
 keys.sort_custom(func(a,b):
  var ca: Vector2i = model.coord(a)
  var cb: Vector2i = model.coord(b)
  var da: int = ca.x+ca.y+(1 if model.state.tiles[a].size == 4 else 0)
  var db: int = cb.x+cb.y+(1 if model.state.tiles[b].size == 4 else 0)
  return ca.x < cb.x if da == db else da < db)
 return keys

func pick(position: Vector2) -> String:
 var keys := render_keys()
 keys.reverse()
 for key in keys:
  var tile: Dictionary = model.state.tiles[key]
  var size := 2.0 if tile.size == 4 else 1.0
  var at := Vector2(model.coord(key))+(Vector2(0.5,0.5) if size == 2 else Vector2.ZERO)
  if preload("res://scripts/TileArtwork.gd").hit(tile.type,tile.evolution,position-screen(at),132.0/418.0*zoom_level*size,tile.ready > model.state.time): return key
 var selected_key: String = model.origin(selected)
 if selected_key != "":
  var selected_tile: Dictionary = model.state.tiles[selected_key]
  if selected_tile.ready > model.state.time and preload("res://scripts/TileArtwork.gd").hit(selected_tile.type,selected_tile.evolution,position-screen(model.coord(selected_key)),132.0/418.0*zoom_level): return selected_key
 return hit(position)

func _input(event: InputEvent) -> void:
 if event is InputEventScreenTouch:
  if event.pressed: all_touches[event.index] = event.position
  else: all_touches.erase(event.index)
  if all_touches.size() >= 2:
   for position in all_touches.values():
    if not world_rect().has_point(position): mixed_touch_sequence = true; input_controller.reset()
  if all_touches.is_empty(): mixed_touch_sequence = false
 if not inspection_mode or not modal.visible: return
 if event is InputEventScreenTouch or event is InputEventMouseButton:
  if event.pressed:
   inspection_drag_start = event.position
   if not modal.get_global_rect().has_point(event.position):
    dismiss_inspection(); get_viewport().set_input_as_handled()
 elif event is InputEventScreenDrag:
  if inspection_drag_start.y < modal.position.y+70 and event.position.y-inspection_drag_start.y > 55:
   dismiss_inspection(); get_viewport().set_input_as_handled()

func show_discovery(id: String) -> void:
 var recipe: Dictionary = {}
 for candidate in model.config.recipes+model.config.fusions:
  if candidate.id == id: recipe = candidate
 if recipe.is_empty(): return
 var box := modal_content("A new world awakens")
 modal_screen = "discovery"
 audio_feedback.play("legendary" if recipe.rarity == "legendary" else "evolve")
 var image = preload("res://scripts/TileThumbnail.gd").new()
 image.tile_type = recipe.types[0]; image.evolution = id; image.extent = 260
 box.add_child(image)
 var title := label(recipe.name,28,box)
 title.add_theme_color_override("font_color",rarity_color(recipe.rarity))
 label(recipe.rarity.capitalize()+" discovery",18,box)
 label(recipe.lore,17,box)
 label("%d Coins · 1 Star Dew · +100 Pulse energy (capacity 200)" % recipe.reward,16,box)
 button("Share your island",func(): modal.hide(); begin_photo(); share_photo(),box)
 button("Keep exploring",func(): modal.hide(),box)
 if not model.state.settings.reduced_motion:
  image.modulate.a = 0
  var tween := create_tween()
  tween.tween_property(image,"modulate:a",1.0,0.6)
  tween.parallel().tween_property(title,"modulate:a",1.0,0.8).from(0.0)
 services.event("discovery_reveal",{"id":id})

func entity_screen(key: String) -> Vector2:
 var origin: String = model.origin(key)
 if origin == "": return screen(model.coord(key))
 var offset := Vector2(0.5,0.5) if model.state.tiles[origin].size == 4 else Vector2.ZERO
 return screen(Vector2(model.coord(origin))+offset)

func button_icon(target: Button, id: String) -> void:
 target.icon = preload("res://scripts/UIIcons.gd").texture(id)
 target.expand_icon = true
 target.add_theme_constant_override("icon_max_width",roundi(24*logical_per_dp()))
