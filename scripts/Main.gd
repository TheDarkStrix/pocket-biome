extends Node2D
const Model = preload("res://scripts/WorldModel.gd")
const ThemeKit = preload("res://scripts/GameTheme.gd")
const Store = preload("res://scripts/SaveStore.gd")
var sky_backdrop: CanvasLayer
var sheets = preload("res://scripts/GameSheets.gd").new()
var game_hud = preload("res://scripts/GameHUD.gd").new()
var ui_motion = preload("res://scripts/UIMotion.gd").new()
var fusion_preview: Array[String] = []
var fusion_controls := []
var ledger_signature := ""
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
var photo_saved_view := {}
var ui_root: Control
var model = Model.new()
var store = Store.new()
var view_turn := 0
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
var pulse_button: Button
var frame_on_layout := false
var modal_title: Label
var modal_scroll: ScrollContainer
var modal_scrim: ColorRect
var notice_toast: PanelContainer
var last_notice := ""
var notice_time := 0.0
var menu_spacer: Control
var ecology_monitor: PanelContainer
var chapter_dial: Control
var draft_button: Button
var inventory: RichTextLabel
var draft_cards: Array[Button] = []
var stacked_buttons: Array[Button] = []
var confirm_card: Button
var inspection_view := {}
var cosmetic_clock := 0.0
var ambient_time := 0.0
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
 input_controller.rotated.connect(rotate_camera)
 input_controller.zoomed.connect(func(factor): zoom_level = clampf(zoom_level*factor,0.04 if photo_mode else 0.5,2.0); constrain_camera(); queue_redraw())
 refresh()
 if show_menu_on_launch: start_screen()
 elif not model.state.pending.is_empty(): draft()

func panel_style(color: Color) -> StyleBoxFlat:
 return ThemeKit.panel(color)

func label(text: String, size: int, parent: Node) -> Label:
 var l := Label.new()
 l.text = tr(text)
 l.set_meta("base_font",size)
 l.add_theme_font_size_override("font_size",scaled_font(size))
 l.add_theme_color_override("font_color",ThemeKit.SHEET_INK if is_sheet(parent) else ThemeKit.INK)
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(l)
 return l

func is_sheet(parent: Node) -> bool:
 return is_instance_valid(modal) and (parent == modal or modal.is_ancestor_of(parent))

func button(text: String, action: Callable, parent: Node) -> Button:
 var b := Button.new()
 # Let ScrollContainer see touch drags begun over a button. Modal panels still contain input.
 b.mouse_filter = Control.MOUSE_FILTER_PASS
 b.text = tr(text)
 b.set_meta("base_font",17)
 b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 b.custom_minimum_size.y = touch_height()
 b.add_theme_font_size_override("font_size",scaled_font(17))
 b.add_theme_color_override("font_color",Color("fff4dc"))
 b.add_theme_stylebox_override("normal",panel_style(ThemeKit.ACTION))
 b.add_theme_stylebox_override("hover",panel_style(Color("46515c")))
 b.add_theme_stylebox_override("pressed",panel_style(Color("202831")))
 b.add_theme_stylebox_override("disabled",panel_style(Color("30373f")))
 b.add_theme_color_override("font_disabled_color",ThemeKit.MUTED)
 var focus := panel_style(Color(0,0,0,0))
 focus.border_color = ThemeKit.ACCENT
 focus.set_border_width_all(2)
 b.add_theme_stylebox_override("focus",focus)
 if is_sheet(parent):
  b.add_theme_color_override("icon_normal_color",ThemeKit.SHEET_CTA)
  b.add_theme_color_override("icon_hover_color",ThemeKit.SHEET_CTA)
  b.add_theme_color_override("icon_pressed_color",ThemeKit.SHEET_INK)
  b.add_theme_color_override("font_color",ThemeKit.SHEET_INK)
  b.add_theme_color_override("font_hover_color",ThemeKit.SHEET_INK)
  b.add_theme_color_override("font_pressed_color",ThemeKit.SHEET_INK)
  b.add_theme_color_override("font_disabled_color",Color("8c9b91"))
  b.add_theme_stylebox_override("normal",ThemeKit.sheet_panel(Color("dce6d8")))
  b.add_theme_stylebox_override("hover",ThemeKit.sheet_panel(Color("c9ddc9")))
  b.add_theme_stylebox_override("pressed",ThemeKit.sheet_panel(Color("b8cdbb")))
  b.add_theme_stylebox_override("disabled",ThemeKit.sheet_panel(Color("e2e7dc")))
 b.pressed.connect(action)
 parent.add_child(b)
 ui_motion.bind_button(b,func(): return model.state.settings.reduced_motion)
 return b

func build_ui() -> void:
 sky_backdrop = preload("res://scripts/SkyBackdrop.gd").new()
 add_child(sky_backdrop)
 var layer := CanvasLayer.new()
 add_child(layer)
 var root := Control.new()
 ui_root = root
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 root.theme = ThemeKit.theme()
 layer.add_child(root)
 game_hud.build(self,root)
 notice_toast = PanelContainer.new()
 notice_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
 notice_toast.add_theme_stylebox_override("panel",panel_style(ThemeKit.PAPER))
 root.add_child(notice_toast)
 notice = label("",16,notice_toast)
 notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
 notice.max_lines_visible = 2
 notice_toast.hide()
 ecology_monitor = preload("res://scripts/EcologyReadout.gd").new()
 root.add_child(ecology_monitor)
 ecology_monitor.explanation_requested.connect(conditions_help)
 hud.visibility_changed.connect(func(): ecology_monitor.visible = hud.visible)
 photo_controls = HBoxContainer.new()
 photo_controls.position = Vector2(20,880)
 photo_controls.size.x = 500
 root.add_child(photo_controls)
 photo_light_button = button("Light",func():
  photo_lighting = "dusk" if photo_lighting != "dusk" else "day"
  queue_redraw(),photo_controls)
 photo_light_button.tooltip_text = "Day / Dusk photo preview · unlocks in Chapter 2"
 button("Save",capture_photo,photo_controls)
 button("Share",share_photo,photo_controls)
 button("Done",end_photo,photo_controls)
 photo_controls.hide()
 modal_scrim = ColorRect.new()
 modal_scrim.color = Color(0.06,0.07,0.10,0.58)
 modal_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.add_child(modal_scrim)
 modal_scrim.hide()
 modal_scrim.gui_input.connect(func(event):
  if event is InputEventMouseButton and event.pressed and not modal.get_global_rect().has_point(event.position):
   modal.hide())
 modal = PanelContainer.new()
 modal.position = Vector2(20,240)
 modal.size = Vector2(500,400)
 modal.add_theme_stylebox_override("panel",ThemeKit.sheet_panel(ThemeKit.SHEET_BG))
 root.add_child(modal)
 modal.visibility_changed.connect(func(): modal_scrim.visible = modal.visible)
 modal.hide()

func cancel_target() -> void:
 targeting = ""
 preview = ""
 model.message = "Pulse canceled. No energy spent."
 refresh()

func conditions_help() -> void:
 var box := modal_content("Tile conditions")
 var origin: String = model.origin(selected)
 if origin != "":
  var tile: Dictionary = model.state.tiles[origin]
  sheets.art(self,box,tile.type,tile.evolution,150)
  label(tile_title(tile),20,box)
 sheets.caption(self,"Neighbors and World Pulses change what your land can become.",box)
 var example := HBoxContainer.new(); box.add_child(example)
 for item in [{"type":"water","evolution":"","label":"Water"},{"type":"oak","evolution":"","label":"Oak"},{"type":"forest","evolution":"rainforest","label":"Rainforest"}]:
  var group := VBoxContainer.new(); group.size_flags_horizontal = Control.SIZE_EXPAND_FILL; example.add_child(group)
  sheets.art(self,group,item.type,item.evolution,88)
  var caption: Label = sheets.caption(self,item.label,group); caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 for detail in [{"icon":"rain","title":"Moisture","text":"Nearby Water and Rain Pulse make the ground wetter."},{"icon":"heat","title":"Heat","text":"Heat Pulse warms the ground. Frost cools it."}]:
  var content: VBoxContainer = sheets.card(box)
  var row := HBoxContainer.new(); content.add_child(row); sheets.icon(row,detail.icon,30)
  label(detail.title,19,row)
  sheets.caption(self,detail.text,content)
 sheets.caption(self,"Scores run from 0–100; Heat is not °C. Higher is not always better. The inspector shows every condition and transformation requirement.",box)
 sheets.primary(self,"Inspect selected tile",func():
  if origin != "": open_inspector(origin),box)
 button("Back to island",func(): modal.hide(),box)

func pulse_selector() -> void:
 var box := modal_content("World Pulse")
 sheets.energy(self,box)
 var descriptions := {"rain":"Refresh the center tile and its four neighbors.","heat":"Warm the same cross and clear Dusk frost.","frost":"Cool the cross and invite frozen discoveries."}
 for power in ["rain","heat","frost"]:
  var action: Button = sheets.power(self,box,power,descriptions[power])
  if power == "rain": rain_button = action
  elif power == "heat": heat_button = action
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
  child.hide()
  child.queue_free()
 var scroll := ScrollContainer.new()
 modal_scroll = scroll
 sheets.scroll_skin(scroll)
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 modal.add_child(scroll)
 modal_box = VBoxContainer.new()
 modal_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 modal_box.add_theme_constant_override("separation",14)
 scroll.add_child(modal_box)
 modal_box.minimum_size_changed.connect(func(): call_deferred("apply_layout"))
 var heading := HBoxContainer.new()
 modal_box.add_child(heading)
 modal_title = label(title,23,heading)
 modal_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var close := button("×",func(): modal.hide(),heading)
 close.size_flags_horizontal = Control.SIZE_SHRINK_END
 close.custom_minimum_size.x = touch_height()
 close.tooltip_text = "Close"
 close.add_theme_stylebox_override("normal",ThemeKit.quiet())
 notice_toast.hide()
 input_controller.reset()
 modal.show()
 ui_motion.reveal(modal,model.state.settings.reduced_motion)
 call_deferred("apply_layout")
 return modal_box

func draft() -> void:
 if model.state.pending.is_empty():
  model.message = "Tap a cloud plot to open its three-card draft."; refresh(); return
 var box := modal_content("Choose your next biome")
 modal_screen = "draft"; draft_cards.clear()
 sheets.chips(self,box,{"coins":model.state.pending.cost})
 sheets.caption(self,"Swipe through three offers. Coins are spent only on placement.",box)
 var carousel := ScrollContainer.new()
 carousel.name = "DraftCarousel"
 carousel.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 carousel.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
 carousel.custom_minimum_size.y = 344*model.state.text_scale
 box.add_child(carousel)
 var cards := HBoxContainer.new(); cards.add_theme_constant_override("separation",12); carousel.add_child(cards)
 for i in range(3):
  var type: String = model.state.pending.cards[i]
  var definition: Dictionary = model.config.tiles[type]
  var content: VBoxContainer = sheets.card(cards)
  content.get_parent().custom_minimum_size.x = 230
  sheets.caption(self,definition.rarity.to_upper()+" · "+definition.category.to_upper(),content)
  sheets.art(self,content,type,"",164)
  label(type.capitalize(),22,content)
  if definition.resource != "": sheets.caption(self,"Gather "+definition.resource.capitalize(),content)
  else: sheets.caption(self,card_hint(type),content)
  draft_cards.append(sheets.primary(self,"Inspect "+type.capitalize(),func(): inspect_card(i),content))
 var paging := HBoxContainer.new(); box.add_child(paging)
 var previous: Button = button("‹",func(): carousel.scroll_horizontal = maxi(0,carousel.scroll_horizontal-242),paging)
 previous.custom_minimum_size.x = touch_height(); previous.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
 var offers: Label = sheets.caption(self,"3 offers · swipe to compare",paging)
 offers.size_flags_horizontal = Control.SIZE_EXPAND_FILL; offers.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var next: Button = button("›",func(): carousel.scroll_horizontal += 242,paging)
 next.custom_minimum_size.x = touch_height(); next.size_flags_horizontal = Control.SIZE_SHRINK_END
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
 sheets.art(self,box,type,"",188)
 label(card_hint(type),18,box)
 label(preload("res://scripts/GameplayAdvisor.gd").placement(model,type,model.state.pending.at),16,box)
 if definition.resource != "": label("Produces 1 %s every %ds" % [definition.resource.capitalize(),definition.cooldown],16,box)
 var attributes := GridContainer.new(); attributes.columns = 2; attributes.add_theme_constant_override("h_separation",16); box.add_child(attributes)
 for i in range(5):
  var group := VBoxContainer.new(); group.size_flags_horizontal = Control.SIZE_EXPAND_FILL; attributes.add_child(group)
  dna_bar(group,model.config.attributes[i],definition.dna[i])
 confirm_card = sheets.primary(self,"Place here · %d Coins" % model.state.pending.cost,func():
  if model.place(index):
   modal.hide(); haptic(22)
  persist(); refresh(),box)
 button("Back to three cards",draft,box)

func rarity_color(rarity: String) -> Color:
 return {"common":Color("8ea18f"),"uncommon":Color("78d4a2"),"rare":Color("a58be8"),"legendary":ThemeKit.ACCENT}.get(rarity,Color("8ea18f"))

func dna_bar(parent: Node, attribute: String, value: float) -> Dictionary:
 var caption: Label = label("%s · %d / 100" % [attribute.capitalize(),value],15,parent)
 var bar := ProgressBar.new()
 bar.max_value = 100; bar.value = value; bar.show_percentage = false
 bar.custom_minimum_size.y = 7
 var track := StyleBoxFlat.new(); track.bg_color = Color("263c48"); track.set_corner_radius_all(3)
 var fill := track.duplicate()
 fill.bg_color = {"moisture":Color("8dbfe8"),"heat":Color("e9a06d"),"fertility":Color("78d4a2"),"stability":Color("b3b6b9"),"magic":Color("a58be8")}[attribute]
 bar.add_theme_stylebox_override("background",track); bar.add_theme_stylebox_override("fill",fill)
 parent.add_child(bar)
 return {"caption":caption,"bar":bar}

func open_ideas() -> void:
 if launch_menu or photo_mode: return
 var suggestions: Array = preload("res://scripts/GameplayAdvisor.gd").ideas(model,selected)
 var box := modal_content("What would you like to try?")
 modal_screen = "ideas"
 label("Choose a direction. Your chapter goal can wait while you experiment.",16,box)
 for suggestion in suggestions:
  var panel := PanelContainer.new()
  panel.add_theme_stylebox_override("panel",ThemeKit.sheet_panel())
  box.add_child(panel)
  var content := VBoxContainer.new(); panel.add_child(content)
  var heading := HBoxContainer.new(); content.add_child(heading)
  var icon := TextureRect.new()
  icon.texture = preload("res://scripts/UIIcons.gd").texture(suggestion.icon)
  if preload("res://scripts/UIIcons.gd").LINE.has(suggestion.icon): icon.modulate = ThemeKit.SHEET_CTA
  icon.custom_minimum_size = Vector2(40,40)
  icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
  heading.add_child(icon)
  var title := label(suggestion.title,19,heading)
  title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  label(suggestion.body,16,content)
  button(suggestion.button,func(): choose_idea(suggestion),content)
 button("Back to my island",func(): modal.hide(),box)

func choose_idea(idea: Dictionary) -> void:
 targeting = ""; preview = ""; placement_blueprint = ""
 match idea.action:
  "collect":
   var at: String = model.origin(idea.target)
   if at != "": selected = at
   modal.hide(); frame_world()
   model.message = "Tap the highlighted Oak to gather Wood."
   refresh()
  "expand":
   modal.hide(); frame_world()
   model.message = "Choose a cloud. Water beside Oak can grow a rainforest."
   refresh()
  "draft": draft()
  "fusion": fusion_dialog()
  "trade": campaign_ui.trade(self)
  "workshop": campaign_ui.workshop(self)
  "world":
   if idea.has("target") and model.origin(idea.target) != "": selected = model.origin(idea.target)
   refresh(); campaign_ui.world(self)
  "pulse": pulse_selector()
  "journal": campaign_ui.journal(self)
  "blueprint":
   placement_blueprint = idea.target
   modal.hide()
   model.message = "Choose an empty Grass tile for your "+str(idea.target).capitalize()+"."
   refresh()

func fusion_dialog() -> void:
 var guide = preload("res://scripts/FusionGuide.gd")
 var options: Array = guide.options(model,selected)
 var box := modal_content("Create a sanctuary")
 modal_screen = "fusion"
 fusion_controls.clear()
 label("Four matching tiles must form a 2 × 2 square, seen as a diamond on your island. Evolved tiles still count. Oak is not Forest.",17,box)
 if options.is_empty():
  label("Expand with Forest, Water, Stone or Meadow to begin a group.",17,box)
 for option in options.slice(0,4):
  var panel := PanelContainer.new()
  panel.add_theme_stylebox_override("panel",ThemeKit.sheet_panel())
  box.add_child(panel)
  var content := VBoxContainer.new(); panel.add_child(content)
  var diagram = preload("res://scripts/FusionDiagram.gd").new()
  diagram.type = option.type; diagram.evolution = option.recipe.id; diagram.matches = option.matches
  content.add_child(diagram)
  label(option.recipe.name+" · %d / 4 ready" % option.matches,19,content)
  var reason := label(option.reason,15,content)
  var origin: String = option.at
  var footprint: Array[String] = option.cells
  button("Show this group",func():
   fusion_preview = footprint.duplicate(); selected = origin if model.origin(origin) != "" else selected
   modal.hide(); model.message = "Highlighted diamond: four matching tiles. World → Fuse sanctuary to combine."
   refresh(),content)
  var confirm := button("Fuse into "+option.recipe.name,func():
   if model.fuse(origin):
    selected = origin; fusion_preview.clear(); modal.hide(); haptic(50)
   else:
    fusion_dialog(); model.message = "Group changed. Check its current requirements."
   persist(); refresh(),content)
  confirm.add_theme_stylebox_override("normal",ThemeKit.sheet_panel(ThemeKit.SHEET_CTA))
  confirm.add_theme_color_override("font_color",Color("fffdf2"))
  confirm.disabled = not option.ready
  fusion_controls.append({"origin":origin,"action":confirm,"reason":reason})
 button("Back to island",func(): modal.hide(),box)

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
 if model.state.settings.reduced_motion: presentation.animations.clear()
 services.model = model
 services.save_path = store.path
 for cue in presentation.cues:
  if model.state.settings.sfx: audio_feedback.play(cue)
 update_stacked_buttons()
 photo_light_button.disabled = model.state.chapter < 2
 pulse_bar.value = model.state.energy
 if is_instance_valid(rain_button): rain_button.disabled = model.state.energy < 100
 if is_instance_valid(heat_button): heat_button.disabled = model.state.energy < 100
 pulse_button.text = ""
 update_pulse_width()
 draft_button.text = "Cancel placement" if placement_blueprint != "" else ("Cancel pulse" if targeting != "" else "Resume draft")
 draft_button.disabled = targeting == "" and placement_blueprint == "" and model.state.pending.is_empty()
 if model.state.chapter == 3 and model.state.stats.fusions == 0 and targeting == "" and placement_blueprint == "" and model.state.pending.is_empty():
  draft_button.text = "Find a sanctuary fusion"
  draft_button.disabled = false
 draft_button.visible = not draft_button.disabled
 chapter_dial.display(model)
 var signature := str([model.state.coins,model.state.inventory,model.state.tiles.size()])
 if ledger_signature != "" and ledger_signature != signature:
  ui_motion.emphasize(inventory,model.state.settings.reduced_motion)
 ledger_signature = signature
 game_hud.display(self)
 var goal: String = model.objective_text()
 var parts: PackedStringArray = goal.split(" · ",true,1)
 if parts[0] in ["FIRST SEED","NEW HORIZONS","LIVING ROOTS","YOUR LIVING WORLD"]:
  goal = parts[-1].replace(" (+10 coins)","")
 else: goal = goal.replace(" · ","\n")
 game_hud.display_goal(self,goal)
 if model.message != last_notice:
  last_notice = model.message
  notice.text = model.message
  notice_time = 3.5
 var k: String = model.origin(selected)
 if k != "":
  var t: Dictionary = model.state.tiles[k]
  ecology_monitor.display(t,model.state.settings.reduced_motion)
  var production: Dictionary = model.production(t)
  var remaining: int = ceili(maxf(0,t.ready-model.state.time))
  info.text = tile_title(t)+"\n"+("Ready to collect" if remaining == 0 and production.resource != "" else "Ready in %ds" % remaining if production.resource != "" else "Hold to discover its secrets")

 update_inspection()
 campaign_ui.update_live(self)
 if modal.visible and modal_screen == "fusion":
  var current: Array = preload("res://scripts/FusionGuide.gd").options(model,selected)
  for controls in fusion_controls:
   if not is_instance_valid(controls.action): continue
   controls.action.disabled = not model.can_fuse(controls.origin)
   for option in current:
    if option.at == controls.origin: controls.reason.text = option.reason; break
 last_discoveries = model.state.discoveries.size()
 call_deferred("apply_layout")
 queue_redraw()

func compact_amount(amount: int) -> String:
 if amount >= 1000000: return "%.1fm" % (float(amount)/1000000.0)
 if amount >= 10000: return "%dk" % (amount/1000)
 if amount >= 1000: return "%.1fk" % (float(amount)/1000.0)
 return str(amount)

func camera_coord(c: Vector2) -> Vector2:
 for step in range(view_turn): c = Vector2(-c.y,c.x)
 return c

func project(c: Vector2) -> Vector2:
 var rotated := camera_coord(c)
 return Vector2((rotated.x-rotated.y)*66,(rotated.x+rotated.y)*33)

func rotate_camera(steps: int) -> void:
 if launch_menu or photo_mode: return
 view_turn = posmod(view_turn+steps,4)
 frame_world()
 model.message = "View %d° · Two-finger twist turns the island; pinch to zoom." % (view_turn*90)
 haptic(12)
 refresh()

func screen(c: Vector2) -> Vector2:
 return world_anchor()+pan+project(c)*zoom_level

func hit(pos: Vector2) -> String:
 var p := (pos-world_anchor()-pan)/zoom_level
 var c := Vector2(p.x/132+p.y/66,p.y/66-p.x/132)
 for step in range(view_turn): c = Vector2(c.y,-c.x)
 return model.key(Vector2i(roundi(c.x),roundi(c.y)))

func tap(pos: Vector2) -> void:
 if launch_menu or photo_mode or not world_rect().has_point(pos) or modal.visible: return
 var harvest_path := false
 var k := pick(pos)
 fusion_preview.clear()
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
   presentation.pulse(targeting,model.origin(k),model.pulse_targets(k))
   model.message = targeting.capitalize()+" Pulse released · affects %d biomes" % model.pulse_targets(k).size()
   targeting = ""
   haptic(35)
   audio_feedback.play("pulse")
  else: model.message = "Choose land with at least 100 energy. No energy spent."
 elif model.state.tiles.has(k):
  harvest_path = true
  selected = model.origin(k)
  game_hud.show_selection()
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
 var ecology_width: float = touch_height()
 hud.size.x = safe.size.x-40
 game_hud.fit_header(self,hud.size.x,Vector2(ecology_width,ecology_monitor.get_combined_minimum_size().y))
 layout = preload("res://scripts/SafeLayout.gd").regions(safe,maxf(72,hud.get_combined_minimum_size().y),maxf(72,bottom.get_combined_minimum_size().y))
 layout.top.size.x = hud.size.x
 hud.position = layout.top.position
 hud.size = layout.top.size
 bottom.position = layout.bottom.position
 bottom.size = layout.bottom.size
 modal.position = layout.modal.position
 modal.size = Vector2(layout.modal.size.x,minf(layout.modal.size.y,maxf(220,modal_box.get_combined_minimum_size().y+24))) if is_instance_valid(modal_box) else layout.modal.size
 if launch_menu and is_instance_valid(launch_screen) and is_instance_valid(menu_spacer):
  launch_screen.position = Vector2(safe.position.x+22,safe.position.y+40)
  launch_screen.size.x = safe.size.x-44
  var fixed_height: float = launch_screen.get_combined_minimum_size().y-menu_spacer.custom_minimum_size.y
  menu_spacer.custom_minimum_size.y = maxf(100,safe.size.y-80-fixed_height)
 if launch_menu:
  modal.position.y = safe.position.y+20
  modal.size.y = safe.size.y-40
 ecology_monitor.custom_minimum_size = Vector2.ONE*touch_height()
 ecology_monitor.size = Vector2.ONE*touch_height()
 ecology_monitor.position = Vector2(safe.end.x-ecology_monitor.size.x-20,hud.position.y+game_hud.quest_slot.position.y)
 notice_toast.size = Vector2(layout.world.size.x-16,0)
 notice_toast.position = Vector2(layout.world.position.x+8,layout.bottom.position.y-notice_toast.get_combined_minimum_size().y-12)
 if inspection_mode:
  modal.position.y = maxf(layout.modal.position.y,get_viewport_rect().size.y*0.44)
  modal.size.y = layout.modal.end.y-modal.position.y
 photo_controls.position = Vector2(safe.position.x+20,safe.end.y-maxf(touch_height(),photo_controls.get_combined_minimum_size().y)-12)
 photo_controls.size.x = safe.size.x-40
 if launch_menu: frame_title_island(safe)
 elif frame_on_layout:
  frame_world()
  frame_on_layout = false
 else: constrain_camera()
 queue_redraw()

func frame_title_island(safe: Rect2) -> void:
 # Android can resize after _ready; never reuse the gameplay pan for the title hero.
 var bounds := world_art_bounds(false)
 var hero := Rect2(safe.position+Vector2(20,safe.size.y*0.20),Vector2(safe.size.x-40,safe.size.y*0.42))
 zoom_level = clampf(minf(hero.size.x/bounds.size.x,hero.size.y/bounds.size.y),0.04,1.8)
 pan = hero.get_center()-world_anchor()-bounds.get_center()*zoom_level

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
 game_hud.update_selection(self,delta)
 if not suspended and not photo_mode and not model.state.settings.reduced_motion:
  ambient_time += minf(delta,0.1)
  cosmetic_clock += delta
  if cosmetic_clock >= 1.0/30.0:
   cosmetic_clock = 0.0
   queue_redraw()
 notice_time = maxf(0,notice_time-delta)
 notice_toast.visible = notice_time > 0 and not launch_menu and not photo_mode and not modal.visible
 if not launch_menu and not photo_mode and not modal.visible and not reveal_queue.is_empty(): show_discovery(reveal_queue.pop_front())
 if suspended or launch_menu: return
 if discard_resume_delta:
  discard_resume_delta = false
  return
 model.advance_time(delta)
 if save_dirty:
  dirty_elapsed += delta
  if dirty_elapsed >= 0.35: persist()
 if model.state.settings.reduced_motion:
  presentation.animations.clear()
  if presentation.advance(delta): queue_redraw()
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
 sky_backdrop.display(palette,ambient_time)
 if palette not in ["day","sakura"]:
  for i in range(28):
   draw_circle(Vector2(fmod(i*137.0,get_viewport_rect().size.x),30+fmod(i*97.0,get_viewport_rect().size.y*0.65)),1.0+float(i%2),Color(0.95,0.9,0.76,0.5))
 var visible_frontier: Array = [] if photo_mode or launch_menu or targeting != "" or placement_blueprint != "" else model.frontier()
 for k in visible_frontier:
  var p := screen(model.coord(k))
  preload("res://scripts/TileArtwork.gd").draw_tile(self,"cloud",p,132.0/418.0*zoom_level*0.72,Color(0.82,0.92,1,0.5))
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
  var still: bool = model.state.settings.reduced_motion or photo_mode
  preload("res://scripts/WorldAmbience.gd").draw_tile(self,t.type,p,132.0/418.0*zoom_level*size*pose.scale,tint,t.evolution,t.ready > model.state.time,ambient_time,t.id,still)
  preload("res://scripts/WorldAmbience.gd").draw_effects(self,t,p,zoom_level*size,ambient_time,still)
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
  if not photo_mode and not launch_menu and (selected == k or affected(k)): draw_arc(p,38*s*size,0,TAU,32,ThemeKit.ACCENT,2*s)

 # Draw expansion controls above the art they operate, matching their input priority.
 for key in visible_frontier:
  var at := screen(model.coord(key))
  var breath := 1.0 if model.state.settings.reduced_motion else 1.0+0.07*sin(model.state.time*2.4)
  draw_circle(at,13*breath,Color(0.14,0.19,0.24,0.85))
  draw_arc(at,13*breath,0,TAU,24,Color(0.67,0.78,0.88,0.7),1.2,true)
  draw_line(at-Vector2(6,0),at+Vector2(6,0),ThemeKit.INK,1.7,true)
  draw_line(at-Vector2(0,6),at+Vector2(0,6),ThemeKit.INK,1.7,true)
 for key in fusion_preview:
  var at := screen(model.coord(key))
  var diamond := PackedVector2Array([at+Vector2(0,-30)*zoom_level,at+Vector2(60,0)*zoom_level,at+Vector2(0,30)*zoom_level,at+Vector2(-60,0)*zoom_level,at+Vector2(0,-30)*zoom_level])
  draw_colored_polygon(diamond,Color(0.67,0.65,0.83,0.22))
  draw_polyline(diamond,ThemeKit.ACCENT,2.5,true)
 draw_weather()
 for effect in presentation.harvests:
  var at := entity_screen(effect.key)+Vector2(-24,-55-effect.elapsed*30)*zoom_level
  var flight: float = clampf(effect.elapsed/0.4,0,1)
  var destination: Control = game_hud.resource_values.get(effect.resource,game_hud.selected_art)
  var icon_at: Vector2 = entity_screen(effect.key).lerp(destination.get_global_rect().get_center(),1-pow(1-flight,2))
  if flight < 1: preload("res://scripts/UIIcons.gd").draw(self,effect.resource,icon_at,32,Color(1,1,1,1-flight*0.6))
  draw_string_outline(ThemeDB.fallback_font,at,effect.text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,3,Color(0.09,0.2,0.23,1-effect.elapsed/0.8))
  draw_string(ThemeDB.fallback_font,at,effect.text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(0.95,0.83,0.56,1-effect.elapsed/0.8))
 if photo_mode:
  draw_string(ThemeDB.fallback_font,Vector2(22,get_viewport_rect().size.y-25),"POCKET BIOME · TINY EXPANSION",HORIZONTAL_ALIGNMENT_LEFT,-1,14,hud_ink())

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
 open_inspector(key)

func open_inspector(key: String) -> void:
 if key == "" or not model.state.tiles.has(key): return
 selected = key
 var tile: Dictionary = model.state.tiles[key]
 var box := modal_content(tile_title(tile))
 inspection_mode = true
 var image = sheets.art(self,box,tile.type,tile.evolution,180)
 inspection_view = {"key":key,"title":modal_title,"image":image,"bars":{},"conditions":[]}
 var production: Dictionary = model.production(tile)
 if production.resource != "": inspection_view["production"] = label("%d %s · %ds cycle · ready in %ds" % [production.amount,production.resource.replace("_"," ").capitalize(),production.cooldown,ceili(maxf(0,tile.ready-model.state.time))],16,box)
 else: label(card_hint(tile.type),16,box)
 var reserve: Dictionary = model.config.tiles[tile.type].get("automation_reserve",{})
 if not reserve.is_empty():
  var held := PackedStringArray()
  for resource in reserve: held.append("%d %s" % [reserve[resource],resource.capitalize()])
  label("Automatic production keeps "+", ".join(held)+" for construction. Manual crafting can use this reserve.",15,box)
 var readings := GridContainer.new(); readings.columns = 2; readings.add_theme_constant_override("h_separation",16); readings.add_theme_constant_override("v_separation",10); box.add_child(readings)
 for attribute in model.config.attributes:
  var group := VBoxContainer.new(); group.size_flags_horizontal = Control.SIZE_EXPAND_FILL; readings.add_child(group)
  inspection_view.bars[attribute] = dna_bar(group,attribute,tile.dna[attribute])
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
  var source_row := HBoxContainer.new(); box.add_child(source_row)
  var source_art = sheets.art(self,source_row,source.type,source.evolution,52); source_art.custom_minimum_size.x = 60
  var source_text: Label = label(text,14,source_row); source_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  count += 1
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
  widgets.caption.text = "%s · %d / 100" % [attribute.capitalize(),tile.dna[attribute]]
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
 services.telemetry.model = model
 services.telemetry.reconcile_consent()
 if services.bridge != null:
  services.bridge.setDiagnosticsEnabled(model.state.settings.analytics)
 audio_feedback.process_mode = Node.PROCESS_MODE_INHERIT
 var effects: float = model.state.audio_levels.sfx if model.state.settings.sfx else 0.0
 for player in audio_feedback.players: player.volume_db = -80 if effects <= 0 else -10+linear_to_db(effects)
 if audio_feedback.ambience != null:
  var music: float = model.state.audio_levels.music if model.state.settings.music else 0.0
  audio_feedback.ambience.volume_db = -80 if music <= 0 else -20+linear_to_db(music)
  audio_feedback.ambience.stream_paused = music <= 0
 if ui_root != null: update_fonts(ui_root)
 update_stacked_buttons()
 update_pulse_width()
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
 sheets.art(self,box,"shrine","",144)
 label("Your world plays offline",21,box)
 sheets.caption(self,"Optional extras. Core progression needs no purchase. Development test services only.",box)
 sheets.caption(self,services.status,box)
 sheets.primary(self,"Connect optional services",func(): services.initialize_online(),box).disabled = services.bridge == null
 var rewards := GridContainer.new(); rewards.columns = 2; rewards.add_theme_constant_override("h_separation",10); box.add_child(rewards)
 for offer in [{"kind":"coins","icon":"coins","amount":25,"title":"25 Coins"},{"kind":"pulse","icon":"rain","amount":100,"title":"100 Pulse energy"}]:
  var content: VBoxContainer = sheets.card(rewards)
  sheets.icon(content,offer.icon,72)
  label(offer.title,18,content)
  var ad: Button = sheets.primary(self,"Watch test ad",func(): services.request_reward(offer.kind); modal.hide(),content)
  ad.disabled = not services.ad_ready or not services.reward_available()
 for product in services.products:
  var content: VBoxContainer = sheets.card(box)
  sheets.art(self,content,"lantern" if "founder" in str(product.id) else "shrine","",112)
  label(str(product.name),20,content)
  sheets.primary(self,str(product.price),func(): services.purchase(product.id),content)
 button("Restore purchases",func(): services.restore(),box).disabled = services.bridge == null
 if model.state.entitlements.has("moon") or model.state.entitlements.has("founders"):
  button("Select Moonlit theme",func(): model.state.cosmetic = "moon"; persist(); refresh(),box)
 if model.state.entitlements.has("founders"):
  button("Select Celestial founder theme",func(): model.state.cosmetic = "celestial"; persist(); refresh(),box)
 button("Use daylight palette",func(): model.state.cosmetic = "day"; persist(); refresh(),box)
 campaign_ui.close_button(self,box)

func world_art_bounds(include_frontier: bool) -> Rect2:
 var bounds := Rect2()
 var first := true
 for key in model.state.tiles:
  var tile: Dictionary = model.state.tiles[key]
  if tile.has("owner"): continue
  var footprint: float = 2.0 if tile.size == 4 else 1.0
  var at := Vector2(model.coord(key))+(Vector2(0.5,0.5) if footprint == 2 else Vector2.ZERO)
  var spec: Dictionary = preload("res://scripts/TileArtwork.gd").appearance(tile.type,tile.evolution)
  var scale: float = 132.0/418.0*spec.normalization*footprint
  var visual := Rect2(project(at)-spec.pivot*scale,spec.region.size*scale)
  if first: bounds = visual; first = false
  else: bounds = bounds.merge(visual)
 if include_frontier:
  var cloud: Dictionary = preload("res://scripts/TileArtwork.gd").appearance("cloud","")
  var scale: float = 132.0/418.0*cloud.normalization*0.72
  for key in model.frontier():
   var visual := Rect2(project(model.coord(key))-cloud.pivot*scale,cloud.region.size*scale)
   bounds = bounds.merge(visual)
 if first: bounds = Rect2(-66,-66,132,132)
 return bounds.grow(24)

func frame_world() -> void:
 var bounds := world_art_bounds(not photo_mode)
 var area := world_rect()
 zoom_level = clampf(minf(area.size.x/bounds.size.x,area.size.y/bounds.size.y),0.04 if photo_mode else 0.5,2.0)
 pan = area.get_center()-world_anchor()-bounds.get_center()*zoom_level
 queue_redraw()

func begin_photo() -> void:
 if photo_mode: return
 photo_saved_view = {"zoom":zoom_level,"pan":pan}
 photo_lighting = model.state.cosmetic
 photo_mode = true
 hud.hide(); bottom.hide(); photo_controls.show()
 frame_world()

func end_photo() -> void:
 photo_mode = false
 if not photo_saved_view.is_empty():
  zoom_level = photo_saved_view.zoom
  pan = photo_saved_view.pan
  photo_saved_view.clear()
 hud.show(); bottom.show(); photo_controls.hide()
 call_deferred("apply_layout")
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
 var hints := {"forest":"Shares fertility · evolves with water","fiber":"Gather Fiber for blueprints and new terrain","water":"Shares moisture · place beside Oak","crystal":"Shares magic · enchanted reactions","vent":"Shares heat · thermal reactions","glacier":"Cools neighbors · frozen discoveries","grass":"An open meadow for crafting and sanctuary fusion","stone":"Gather Stone · strengthens neighboring ground","clay":"Gather Clay · furnace construction","iron":"Gather Iron · awaken a Golem","workbench":"Craft blueprints from your materials","furnace":"Processes Stone + Wood into Brick; emits heat","windmill":"Generates a Coin every five seconds","golem":"Harvests nearby ready Stone and Iron nodes","totem":"Moisture and faster harvest cooldowns","compost":"Enriches neighboring plants","shrine":"Cultivates fertility and magic","dirt":"Ploughed soil waiting for a new ecology","lantern":"A warm decorative light for your world"}
 return hints.get(type,"Discover a new corner of your world.")

func start_screen() -> void:
 launch_menu = true
 hud.hide(); bottom.hide(); modal.hide(); notice_toast.hide()
 if launch_screen != null: launch_screen.queue_free()
 launch_screen = VBoxContainer.new()
 launch_screen.position = Vector2(22,52)
 launch_screen.size.x = get_viewport_rect().size.x-44
 launch_screen.add_theme_constant_override("separation",12)
 ui_root.add_child(launch_screen)
 var title := label("Pocket Biome",38,launch_screen)
 title.add_theme_font_override("font",ThemeKit.DISPLAY)
 title.add_theme_color_override("font_color",hud_ink())
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var subtitle := label("T I N Y   E X P A N S I O N",14,launch_screen)
 subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 subtitle.add_theme_color_override("font_color",hud_ink())
 var promise := label("An ecosystem in balance.",18,launch_screen)
 promise.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 promise.add_theme_color_override("font_color",hud_ink())
 menu_spacer = Control.new()
 menu_spacer.custom_minimum_size.y = get_viewport_rect().size.y*0.36
 launch_screen.add_child(menu_spacer)
 var play := button("Continue your world" if model.state.harvests > 0 else "Start exploring",start_play,launch_screen)
 play.custom_minimum_size.y = 60*logical_per_dp()
 play.add_theme_stylebox_override("normal",panel_style(ThemeKit.ACCENT))
 play.add_theme_color_override("font_color",ThemeKit.PRIMARY_INK)
 var secondary := HBoxContainer.new()
 launch_screen.add_child(secondary)
 button("Settings",func(): campaign_ui.settings(self),secondary)
 button("About",func():
  var box := modal_content("Pocket Biome · Tiny Expansion")
  label("An offline miniature-world discovery game. Version %s. Original synthesized sound and generated diorama artwork. No purchase is needed to finish." % ProjectSettings.get_setting("application/config/version","development"),17,box)
  campaign_ui.close_button(self,box),secondary)
 button("New world",new_world_dialog,secondary)
 ui_motion.reveal(launch_screen,model.state.settings.reduced_motion)
 call_deferred("apply_layout")
 queue_redraw()

func new_world_dialog() -> void:
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
  if entitlements.has("founders"): model.state.blueprints["lantern"] = 1
  services.model = model
  presentation = preload("res://scripts/WorldPresentation.gd").new()
  selected = "0,0"; pan = Vector2.ZERO; zoom_level = 1.0; view_turn = 0
  apply_settings(); persist(); refresh(); start_play(),box)
 campaign_ui.close_button(self,box)

func start_play() -> void:
 launch_menu = false
 if launch_screen != null: launch_screen.hide()
 hud.show(); bottom.show(); modal.hide()
 ui_motion.reveal(hud,model.state.settings.reduced_motion)
 ui_motion.reveal(bottom,model.state.settings.reduced_motion)
 frame_on_layout = true
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
  var ca: Vector2 = camera_coord(Vector2(model.coord(a))+(Vector2(0.5,0.5) if model.state.tiles[a].size == 4 else Vector2.ZERO))
  var cb: Vector2 = camera_coord(Vector2(model.coord(b))+(Vector2(0.5,0.5) if model.state.tiles[b].size == 4 else Vector2.ZERO))
  var da: float = ca.x+ca.y
  var db: float = cb.x+cb.y
  return ca.x < cb.x if is_equal_approx(da,db) else da < db)
 return keys

func pick_frontier(position: Vector2) -> String:
 var nearest := ""
 # Overlapping mobile touch areas resolve to the closest visible marker.
 var reach := maxf(22,22*logical_per_dp())
 var distance := reach*reach
 for key in model.frontier():
  var current: float = position.distance_squared_to(screen(model.coord(key)))
  if current <= distance:
   distance = current; nearest = key
 return nearest

func pick(position: Vector2) -> String:
 if targeting == "" and placement_blueprint == "":
  var cloud := pick_frontier(position)
  if cloud != "": return cloud
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

func update_pulse_width() -> void:
 if not is_instance_valid(pulse_button): return
 pulse_button.custom_minimum_size.x = 0

func button_icon(target: Button, id: String, stacked: bool = false) -> void:
 var texture: Texture2D = preload("res://scripts/UIIcons.gd").texture(id)
 if not stacked:
  if is_sheet(target) and not preload("res://scripts/UIIcons.gd").LINE.has(id):
   for state in ["icon_normal_color","icon_hover_color","icon_pressed_color"]: target.add_theme_color_override(state,Color.WHITE)
  target.icon = texture
  target.expand_icon = true
  target.add_theme_constant_override("icon_max_width",roundi(24*logical_per_dp()))
  return
 var text: String = target.text
 target.text = ""
 target.tooltip_text = text
 var content := VBoxContainer.new()
 content.mouse_filter = Control.MOUSE_FILTER_IGNORE
 target.add_child(content)
 content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var inset := 2*logical_per_dp()
 content.offset_left = inset; content.offset_right = -inset
 content.offset_top = inset; content.offset_bottom = -inset
 content.alignment = BoxContainer.ALIGNMENT_CENTER
 content.add_theme_constant_override("separation",5)
 var medallion := PanelContainer.new()
 medallion.mouse_filter = Control.MOUSE_FILTER_IGNORE
 medallion.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
 var primary: bool = target.get_meta("primary_dock",false)
 var disc := ThemeKit.floating(ThemeKit.BUILD if primary else Color("3b434e"),32)
 disc.shadow_size = 3
 disc.content_margin_top = 7; disc.content_margin_bottom = 7
 disc.content_margin_left = 8; disc.content_margin_right = 8
 disc.border_color = Color("f0d39e") if primary else Color("626b77")
 medallion.add_theme_stylebox_override("panel",disc)
 content.add_child(medallion)
 var icon := TextureRect.new()
 icon.texture = texture
 icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.custom_minimum_size = Vector2.ONE*24*minf(1.25,logical_per_dp())
 icon.modulate = ThemeKit.PRIMARY_INK if primary else ThemeKit.INK
 icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
 medallion.add_child(icon)
 var caption: Label = label(text,12,content)
 caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
 caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 caption.autowrap_mode = TextServer.AUTOWRAP_WORD
 target.set_meta("icon_caption",caption)
 target.set_meta("icon_image",icon)
 stacked_buttons.append(target)
 update_stacked_buttons()

func hud_ink() -> Color:
 return Color("173844") if visible_palette() in ["day","sakura"] else ThemeKit.INK

func update_stacked_buttons() -> void:
 for action in stacked_buttons:
  if not is_instance_valid(action): continue
  action.custom_minimum_size.y = maxf(touch_height(),64*logical_per_dp()*model.state.text_scale)
  action.get_meta("icon_caption").modulate = ThemeKit.MUTED if action.disabled else hud_ink()
  action.get_meta("icon_image").modulate.a = 0.5 if action.disabled else 1.0

func draw_weather() -> void:
 for effect in presentation.weather:
  var elapsed: float = effect.elapsed
  var fade: float = clampf((effect.duration-elapsed)/0.6,0,1)*clampf(elapsed/0.12,0,1)
  var color: Color = {"rain":Color("a9d8fa"),"heat":Color("f2a56d"),"frost":Color("d3f4ff")}[effect.power]
  color.a = fade*0.9
  var targets: Array = effect.targets if not effect.targets.is_empty() else [effect.key]
  for key in targets:
   if model.origin(key) == "": continue
   var center := entity_screen(key)
   var span: float = maxf(0.65,zoom_level)
   if model.state.settings.reduced_motion:
    draw_arc(center,34*span,0,TAU,32,color,3,true)
    continue
   draw_arc(center+Vector2(0,2),32*span,0,TAU,32,Color(color,fade*0.25),2,true)
   for i in range(22):
    var phase := fposmod(elapsed*1.8+float(i)*0.137,1.0)
    var x := (fposmod(float(i)*0.618,1.0)-0.5)*100*span
    if effect.power == "rain":
     var at := center+Vector2(x+phase*12*span,(-105+phase*125)*span)
     draw_line(at,at+Vector2(3,14)*span,color,maxf(1.6,2*span),true)
     if phase > 0.82:
      var ripple := Vector2(x+12*span,8*span)
      draw_arc(center+ripple,(phase-0.82)*38*span,0,TAU,16,Color(color,fade*(1-phase)*3),1.4,true)
    else:
     var angle := TAU*float(i)/22
     var at := center+Vector2(cos(angle)*42,(sin(angle)*18-65*phase))*span
     if effect.power == "frost":
      draw_line(at-Vector2(3,0)*span,at+Vector2(3,0)*span,color,1.6,true)
      draw_line(at-Vector2(0,3)*span,at+Vector2(0,3)*span,color,1.6,true)
     else: draw_circle(at,(2+sin(phase*PI))*span,Color(color,fade*(1-phase)))
