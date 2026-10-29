extends VBoxContainer
# Selection and layout only. CampaignSystem remains the transaction authority.
const Palette = preload("res://scripts/GameTheme.gd")
const Materials = preload("res://scripts/MaterialUI.gd")
var host: Node
var shelf: HBoxContainer
var catalog_scroll: ScrollContainer
var selection: VBoxContainer
var jobs: Label
var projects: Button
var signature := ""
var buttons := {}
func configure(h) -> void:
 host = h
 add_theme_constant_override("separation",8)
 var tabs := HBoxContainer.new(); tabs.add_theme_constant_override("separation",4); add_child(tabs)
 for family in ["Land","Structures","Craft"]:
  var tab: Button = h.sheets.tab(h,family,h.campaign_ui.build_family == family,func():
   h.campaign_ui.build_family = family; h.campaign_ui.build_choice = ""; h.campaign_ui.workshop(h),tabs)
  tab.custom_minimum_size.x = 0; tab.set_meta("build_family",family)
  tab.add_theme_font_size_override("font_size",h.scaled_font(13))
  tab.set_meta("base_font",13)
  h.button_icon(tab,{"Land":"ecology","Structures":"craft","Craft":"stone"}[family])
  tab.add_theme_constant_override("icon_max_width",roundi(18*minf(1.25,h.logical_per_dp())))
  tab.add_theme_stylebox_override("normal",Materials.frame(Color.WHITE if h.campaign_ui.build_family == family else Color("a2ada5"),8))
 var close: Button = h.button("×",func(): h.modal.hide(),tabs)
 close.custom_minimum_size.x = h.touch_height(); close.size_flags_horizontal = Control.SIZE_SHRINK_END
 close.tooltip_text = "Close Build"
 catalog_scroll = ScrollContainer.new(); catalog_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 catalog_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
 catalog_scroll.custom_minimum_size.y = 184+maxf(0,h.scaled_font(14)-14)*3
 add_child(catalog_scroll)
 shelf = HBoxContainer.new(); shelf.add_theme_constant_override("separation",8); catalog_scroll.add_child(shelf)
 var recipes := []
 for recipe in h.model.config.crafting:
  if category(h,recipe) != h.campaign_ui.build_family: continue
  recipes.append(recipe)
 if not recipes.any(func(r): return r.id == h.campaign_ui.build_choice):
  h.campaign_ui.build_choice = recipes[0].id
 var order := ["workbench","windmill","totem","furnace","golem","compost","shrine","lantern"]
 recipes.sort_custom(func(a,b):
  var pa: int = order.find(a.id); var pb: int = order.find(b.id)
  return (pa if pa >= 0 else 99) < (pb if pb >= 0 else 99))
 for recipe in recipes:
  var action: Button = h.button("",func(): choose(recipe.id),shelf)
  action.set_script(preload("res://scripts/ShelfCard.gd"))
  action.set_meta("recipe_id",recipe.id); action.tooltip_text = recipe.name
  action.custom_minimum_size = Vector2(146,catalog_scroll.custom_minimum_size.y-12)
  var body := VBoxContainer.new(); body.mouse_filter = Control.MOUSE_FILTER_IGNORE
  action.add_child(body); body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  body.offset_left = 8; body.offset_right = -8; body.offset_top = 8; body.offset_bottom = -8
  if recipe.has("tile"): h.sheets.art(h,body,recipe.tile,"",112)
  else: h.sheets.icon(body,recipe.output.keys()[0],84)
  var title: Label = h.label(recipe.get("tile",recipe.id).capitalize(),14,body)
  title.mouse_filter = Control.MOUSE_FILTER_IGNORE; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  Materials.lettering(title,true)
  buttons[recipe.id] = action
 selection = VBoxContainer.new(); selection.add_theme_constant_override("separation",6); add_child(selection)
 jobs = h.label("",12,self); jobs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; jobs.hide()
 projects = h.button("Projects & blueprints",func(): h.campaign_ui.workshop_details(h),self)
 projects.custom_minimum_size.y = h.touch_height()
 for state in ["normal","hover","pressed"]: projects.add_theme_stylebox_override(state,Palette.quiet())
 projects.add_theme_font_size_override("font_size",h.scaled_font(12))
 projects.tooltip_text = "All three project slots, batch controls and finished blueprints"
 h.button_icon(projects,"craft")
 update_selection(); update_live()
 call_deferred("reveal_selection")
func category(h, recipe: Dictionary) -> String:
 if not recipe.has("tile"): return "Craft"
 return "Structures" if h.model.config.tiles[recipe.tile].category == "structure" else "Land"
func reveal_selection() -> void:
 if buttons.has(host.campaign_ui.build_choice): catalog_scroll.ensure_control_visible(buttons[host.campaign_ui.build_choice])

func choose(id: String) -> void:
 host.campaign_ui.build_choice = id
 host.audio_feedback.play("card")
 update_selection()
func update_selection() -> void:
 for id in buttons:
  var selected: bool = id == host.campaign_ui.build_choice
  buttons[id].chosen = selected
  for state in ["normal","hover","pressed"]:
   buttons[id].add_theme_stylebox_override(state,Materials.frame(Color("fff0ba") if selected else Color("a2ada5"),8))
  var focus := Palette.quiet()
  focus.set_corner_radius_all(6); focus.set_border_width_all(2 if selected else 0); focus.border_color = Color("ffdc85")
  buttons[id].add_theme_stylebox_override("focus",focus)
  buttons[id].queue_redraw()
 for child in selection.get_children(): child.hide(); child.queue_free()
 var recipe := {}
 for r in host.model.config.crafting:
  if r.id == host.campaign_ui.build_choice: recipe = r; break
 if recipe.is_empty(): return
 var quantity: int = host.campaign_ui.craft_quantity
 var cost := {}
 for resource in recipe.cost: cost[resource] = recipe.cost[resource]*quantity
 var missing := reasons(recipe,cost)
 var ready: int = host.model.state.blueprints.get(recipe.get("tile",""),0)
 var line := HBoxContainer.new(); line.add_theme_constant_override("separation",8); selection.add_child(line)
 var price: VBoxContainer = host.sheets.card(line); price.get_parent().size_flags_stretch_ratio = 1.1
 if ready > 0: host.sheets.caption(host,"%d ready to place" % ready,price)
 else:
  host.sheets.chips(host,price,cost)
  price.get_parent().tooltip_text = "Required materials · "+host.campaign_ui.cost_text(cost)
 var seconds: int = ceili(host.model.campaign.crafting_seconds(host.model,recipe)*quantity)
 var place_block := ""
 if ready > 0:
  if not host.model.state.pending.is_empty(): place_block = "Finish your saved land draft before placing"
  elif host.available_meadows().is_empty(): place_block = "Restore a plot to Meadow in Pack → World"
 var action: Button = host.sheets.primary(host,"PLACE" if ready > 0 else "BUILD" if recipe.has("tile") else "CRAFT",func():
  if ready > 0:
   host.placement_blueprint = recipe.tile
   host.model.message = "Tap an empty Grass tile to place "+recipe.tile.capitalize()+"."
   host.modal.hide(); host.refresh()
  else:
   host.model.craft(recipe.id,quantity); host.persist(); host.refresh(),line)
 action.set_meta("build_confirm",recipe.id)
 action.disabled = (ready < 1 and not missing.is_empty()) or place_block != ""
 action.tooltip_text = (place_block if place_block != "" else "Place "+recipe.get("tile","")) if ready > 0 else (", ".join(missing) if not missing.is_empty() else "%d × %s · %ds" % [quantity,recipe.name,seconds])
 var detail: Label = host.label((place_block if place_block != "" else "Tap an empty Grass plot on your island") if ready > 0 else (", ".join(missing) if not missing.is_empty() else "%d project%s · %ds" % [quantity,"s" if quantity > 1 else "",seconds]),12,selection)
 detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 # Stat changes refresh the selected item's quote, never its saved recipe choice.
 signature = stock_signature()
 host.queue_redraw()
func reasons(recipe: Dictionary, cost: Dictionary) -> PackedStringArray:
 var result := PackedStringArray()
 if not host.model.campaign.has_structure(host.model,recipe.requires): result.append("Needs "+recipe.requires.capitalize())
 if recipe.has("entitlement") and not host.model.state.entitlements.has(recipe.entitlement): result.append("Requires Founder’s Collection")
 for resource in cost:
  var owned: int = host.model.state.coins if resource == "coins" else host.model.state.inventory.get(resource,0)
  if owned < cost[resource]: result.append("%d more %s" % [cost[resource]-owned,resource.capitalize()])
 if host.model.state.jobs.size() >= 3: result.append("All three project slots are busy")
 return result
func stock_signature() -> String:
 return JSON.stringify([host.model.state.inventory,host.model.state.jobs,host.model.state.blueprints,host.model.state.entitlements,host.model.state.coins,host.campaign_ui.craft_quantity,host.campaign_ui.build_choice,host.model.state.pending,host.available_meadows()])
func update_live() -> void:
 if stock_signature() != signature: update_selection()
 var progress := PackedStringArray()
 for job in host.model.state.jobs: progress.append("%s %ds" % [job.recipe.capitalize(),ceili(maxf(0,job.until-host.model.state.time))])
 jobs.text = " · ".join(progress) if not progress.is_empty() else "Three project slots available"
 var ready := 0
 for amount in host.model.state.blueprints.values(): ready += amount
 projects.text = "Projects · %d/3 working" % host.model.state.jobs.size()+(" · %d ready" % ready if ready > 0 else "")
 projects.tooltip_text = jobs.text+" · Tap for queues, batches and blueprints"
