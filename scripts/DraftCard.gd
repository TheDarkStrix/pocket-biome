extends Button
# A real focusable/touchable card; terrain is the same artwork used by the world.
const FRAME = preload("res://assets/ui/draft/card-frame.png")
var chosen := false:
 set(value):
  chosen = value
  queue_redraw()
var title: Label
var trait_label: Label
var trait_icon: TextureRect
var art: Control
var host: Node

func configure(h, type: String) -> void:
 host = h
 text = type.capitalize()
 tooltip_text = "Select "+text
 mouse_filter = Control.MOUSE_FILTER_STOP
 for state in ["normal","hover","pressed","disabled","focus"]:
  add_theme_stylebox_override(state,StyleBoxEmpty.new())
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
  add_theme_color_override(state,Color.TRANSPARENT)
 title = Label.new(); title.text = tr(text.to_upper())
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_override("font",preload("res://assets/fonts/Title.tres"))
 title.add_theme_font_size_override("font_size",h.scaled_font(15))
 title.add_theme_color_override("font_color",Color("fff1d1"))
 title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 title.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(title)
 art = preload("res://scripts/DioramaPreview.gd").new()
 art.tile_type = type; art.extent = 0; art.tint = Color("dac47e")
 add_child(art)
 trait_label = Label.new()
 var attributes := {"forest":"Growth","water":"Moisture","crystal":"Magic","vent":"Warmth","glacier":"Cooling","stone":"Stone","fiber":"Fiber","clay":"Clay","iron":"Iron"}
 trait_label.text = tr(attributes.get(type,"New life"))
 trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 trait_label.add_theme_font_size_override("font_size",h.scaled_font(12))
 trait_label.add_theme_color_override("font_color",Color("dedbc7"))
 trait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(trait_label)
 trait_icon = TextureRect.new()
 trait_icon.texture = preload("res://scripts/UIIcons.gd").texture({"forest":"ecology","water":"moisture","crystal":"star_dew","vent":"heat","glacier":"frost","stone":"stone","fiber":"fiber","clay":"clay","iron":"iron"}.get(type,"ecology"))
 trait_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 trait_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 trait_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(trait_icon)
 resized.connect(arrange)
 mouse_entered.connect(queue_redraw); mouse_exited.connect(queue_redraw)
 focus_entered.connect(queue_redraw); focus_exited.connect(queue_redraw)

func arrange() -> void:
 if not is_instance_valid(title): return
 var title_height: float = host.scaled_font(15)*2.2
 title.position = Vector2(12,16); title.size = Vector2(size.x-24,title_height)
 var trait_width: float = trait_label.get_theme_font("font").get_string_size(trait_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,host.scaled_font(12)).x
 var symbol_size := 17.0
 var total: float = minf(size.x-16,trait_width+symbol_size+4)
 trait_icon.position = Vector2((size.x-total)/2,size.y-host.scaled_font(12)-24)
 trait_icon.size = Vector2.ONE*symbol_size
 trait_label.position = Vector2(trait_icon.position.x+symbol_size+4,size.y-host.scaled_font(12)-22)
 trait_label.size = Vector2(maxf(0,total-symbol_size-4),host.scaled_font(12)+6)
 art.position = Vector2(5,title.position.y+title_height)
 art.size = Vector2(size.x-10,maxf(24,trait_label.position.y-art.position.y-8))
 art.queue_redraw()
 queue_redraw()

func outline(inset: float) -> PackedVector2Array:
 var box := Rect2(Vector2.ONE*inset,size-Vector2.ONE*inset*2)
 var cut := 8.0
 return PackedVector2Array([box.position+Vector2(cut,0),Vector2(box.end.x-cut,box.position.y),Vector2(box.end.x,box.position.y+cut),box.end-Vector2(0,cut),box.end-Vector2(cut,0),Vector2(box.position.x+cut,box.end.y),Vector2(box.position.x,box.end.y-cut),box.position+Vector2(0,cut),box.position+Vector2(cut,0)])

func _draw() -> void:
 if chosen:
  for band in range(5,0,-1):
   draw_polyline(outline(-float(band)),Color(1,0.72,0.28,0.035*float(6-band)),2,true)
 # Use an atlas region at runtime; the generated source remains intact.
 draw_texture_rect_region(FRAME,Rect2(Vector2.ZERO,size),Rect2(64,108,898,1320),Color.WHITE if chosen else Color(0.73,0.76,0.78))
 if chosen or has_focus(): draw_polyline(outline(1),Color("ffdb83"),2,true)
