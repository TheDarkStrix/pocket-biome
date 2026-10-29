extends VBoxContainer
# Presentation only: quotes, offers and placement remain owned by WorldModel.
const CARD = preload("res://scripts/DraftCard.gd")
const BUTTON = preload("res://assets/ui/draft/place-button.png")
const PALETTE = preload("res://scripts/GameTheme.gd")
var host: Node
var stage: Control
var quote: Label
var hint: Label
var cards: Array[Button] = []
var place: Button
var info: Button
var reroll: Button
var selection := 1
var selection_hint := ""

func configure(h) -> void:
 host = h; selection = h.draft_selection
 add_theme_constant_override("separation",8)
 var badge := PanelContainer.new(); badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER; badge.custom_minimum_size.x = 104
 badge.add_theme_stylebox_override("panel",preload("res://scripts/MaterialUI.gd").frame(Color.WHITE,8)); add_child(badge)
 var cost := HBoxContainer.new(); cost.alignment = BoxContainer.ALIGNMENT_CENTER; cost.add_theme_constant_override("separation",4); badge.add_child(cost)
 var coin: TextureRect = h.sheets.icon(cost,"coins",32)
 coin.modulate = Color.WHITE
 quote = h.label("",17,cost); quote.add_theme_font_override("font",PALETTE.DISPLAY); quote.add_theme_color_override("font_color",Color("fff0ca")); quote.autowrap_mode = TextServer.AUTOWRAP_OFF
 stage = Control.new(); stage.name = "DraftHand"; stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
 stage.custom_minimum_size.y = 240+60*(h.model.state.text_scale-1)+maxf(0,h.scaled_font(15)-15)*4
 add_child(stage)
 for index in range(3):
  var card = CARD.new(); stage.add_child(card)
  card.configure(h,h.model.state.pending.cards[index])
  card.pressed.connect(func(): choose(index))
  cards.append(card)
 h.draft_cards.assign(cards)
 stage.resized.connect(func(): arrange(false))
 var detail := HBoxContainer.new(); detail.alignment = BoxContainer.ALIGNMENT_CENTER; add_child(detail)
 hint = h.label("",13,detail); hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL; hint.add_theme_color_override("font_color",Color("eee6ce"))
 info = h.button("Info",func(): h.inspect_card(selection),detail)
 info.size_flags_horizontal = Control.SIZE_SHRINK_END
 info.custom_minimum_size.x = h.touch_height()
 style_quiet(info)
 place = h.button("",confirm,self); h.confirm_card = place
 place.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
 place.custom_minimum_size.x = 360
 var skin := preload("res://scripts/MaterialUI.gd").primary()
 place.custom_minimum_size.y = maxf(64,host.touch_height())
 for state in ["normal","hover","pressed","disabled"]:
  var variant: StyleBoxTexture = skin.duplicate()
  variant.modulate_color = Color("d6decc") if state == "disabled" else Color("c5cbaa") if state == "pressed" else Color(1.12,1.12,1.04) if state == "hover" else Color.WHITE
  place.add_theme_stylebox_override(state,variant)
 place.add_theme_font_override("font",preload("res://assets/fonts/Title.tres"))
 for state in ["font_color","font_hover_color","font_pressed_color"]: place.add_theme_color_override(state,Color("fff0cc"))
 place.add_theme_color_override("font_disabled_color",Color("a7ad9d"))
 var secondary := HBoxContainer.new(); secondary.add_theme_constant_override("separation",12); add_child(secondary)
 var later: Button = h.button("Later",func(): h.modal.hide(); h.persist(),secondary); style_quiet(later)
 if not h.model.state.pending.get("ad_rerolled",false):
  reroll = h.button("Test ad · redraw",func(): h.services.request_reward("reroll"),secondary)
  reroll.tooltip_text = "Optional test advertisement: replace these three offers once."
  style_quiet(reroll)
 update_quote(); update_selection(); call_deferred("arrange",false)

func style_quiet(action: Button) -> void:
 for state in ["normal","hover","pressed","disabled"]: action.add_theme_stylebox_override(state,PALETTE.quiet())
 for state in ["font_color","font_hover_color","font_pressed_color"]: action.add_theme_color_override(state,Color("e4dac3"))
 action.add_theme_color_override("font_disabled_color",Color("979c94"))
 action.add_theme_font_size_override("font_size",host.scaled_font(13))

func choose(index: int) -> void:
 if index < 0 or index >= cards.size(): return
 selection = index; host.draft_selection = index
 host.audio_feedback.play("card")
 update_selection(); arrange(not host.model.state.settings.reduced_motion)

func update_selection() -> void:
 for index in range(cards.size()): cards[index].chosen = index == selection
 var type: String = host.model.state.pending.cards[selection]
 place.text = tr("Place ")+tr(type.capitalize())
 # Keep this concise; full neighbor effects and DNA remain reachable through Info.
 var short_hints := {"forest":"Enriches nearby plants","water":"Brings moisture to neighbors","crystal":"Shares magic with neighbors","vent":"Warms the surrounding land","glacier":"Cools the surrounding land"}
 var definition: Dictionary = host.model.config.tiles[type]
 selection_hint = tr(short_hints.get(type,"Gather "+definition.resource.capitalize() if definition.resource != "" else "A new home for nature"))
 update_quote()

func update_quote() -> void:
 if host.model.state.pending.is_empty(): return
 var cost: int = host.model.state.pending.cost
 quote.text = "%d" % cost
 quote.tooltip_text = "%d Coins to place the selected biome" % cost
 place.disabled = host.model.state.coins < cost
 hint.text = tr("Need %d more Coins") % (cost-host.model.state.coins) if place.disabled else selection_hint
 place.tooltip_text = "Place the selected biome for %d Coins" % cost
 quote.add_theme_color_override("font_color",Color("e3a890") if place.disabled else Color("fff0ca"))
 if is_instance_valid(reroll):
  reroll.disabled = not host.services.ad_ready or not host.services.reward_available()
  reroll.visible = not reroll.disabled

func arrange(animated: bool) -> void:
 if not is_instance_valid(stage): return
 var width := (stage.size.x-30)/3.0
 for index in range(cards.size()):
  var card: Button = cards[index]
  card.size = Vector2(width,stage.size.y-38)
  card.pivot_offset = card.size/2
  card.z_index = 1 if selection == index else 0
  var at := Vector2(8+index*(width+7),10 if index == selection else 24)
  var turn := 0.0 if index == selection else deg_to_rad(-3 if index == 0 else 3 if index == 2 else 0)
  host.ui_motion.stop(card)
  if animated:
   var tween: Tween = card.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
   card.set_meta("response_tween",tween)
   tween.tween_property(card,"position",at,0.17); tween.tween_property(card,"rotation",turn,0.17)
  else: card.position = at; card.rotation = turn

func confirm() -> void:
 if host.model.state.pending.is_empty(): return
 if host.model.place(selection):
  host.modal.hide(); host.haptic(22)
 host.persist(); host.refresh(); update_quote()
