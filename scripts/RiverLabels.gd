extends RefCounted
const River=preload("res://scripts/LivingCorridors.gd")
var bar: HFlowContainer
var badges: Array=[]
var signature:=""
var fitted:=-1.0
func build(h) -> void:
 bar=HFlowContainer.new();bar.add_theme_constant_override("h_separation",6);bar.add_theme_constant_override("v_separation",4);bar.mouse_filter=Control.MOUSE_FILTER_IGNORE;h.ui_root.add_child(bar);bar.hide()
func entries(h) -> Array:
 var s: Dictionary=River.record(h.model)
 if River.tile(h.model,s.get("source","")).get("type","")!="water":return []
 var result: Array=[{"text":"1 · Spring (pond)","cell":s.source,"number":"1"}]
 var flow:=River.delivered(h.model)
 for role in River.ROLES:
  if not s.routes.has(role):continue
  result.append({"text":"%s · %s: %d water" % ["2" if role=="grove" else "3","Trees" if role=="grove" else "Flowers",flow[role]],"cell":River.end_of(h.model,role),"number":"2" if role=="grove" else "3"})
 return result
func layout(h) -> void:
 if not is_instance_valid(bar):return
 var items:=entries(h)
 bar.visible=not items.is_empty() and not h.launch_menu and not h.photo_mode and not h.modal.visible and not h.guidance_ui.opening(h)
 if not bar.visible:return
 var next:=JSON.stringify([items,h.scaled_font(12)])
 if signature!=next:
  for old in bar.get_children():bar.remove_child(old);old.queue_free()
  badges.clear()
  for item in items:
   var plaque:=PanelContainer.new();plaque.mouse_filter=Control.MOUSE_FILTER_IGNORE
   plaque.add_theme_stylebox_override("panel",preload("res://scripts/GameTheme.gd").floating(Color("203c42"),10));bar.add_child(plaque)
   var label: Label=h.label(item.text,12,plaque);label.autowrap_mode=TextServer.AUTOWRAP_OFF;label.mouse_filter=Control.MOUSE_FILTER_IGNORE;badges.append(plaque)
  signature=next
 bar.size=Vector2(h.layout.world.size.x-16,0);bar.position=h.layout.world.position+Vector2(8,4)
 if absf(fitted-bar.get_combined_minimum_size().y)>1:
  fitted=bar.get_combined_minimum_size().y;h.call_deferred("frame_world")
func draw(h) -> void:
 if not is_instance_valid(bar) or not bar.visible:return
 var font: Font=ThemeDB.fallback_font
 var size: int=h.scaled_font(11)
 var radius: float=maxf(9*h.logical_per_dp(),size*0.6)
 for item in entries(h):
  var at: Vector2=preload("res://scripts/CorridorArtwork.gd").ground(h,item.cell)
  h.draw_circle(at,radius+2,Color("c0e5dc"));h.draw_circle(at,radius,Color("203c42"))
  var span:=font.get_string_size(item.number,HORIZONTAL_ALIGNMENT_LEFT,-1,size)
  h.draw_string(font,at+Vector2(-span.x/2,(font.get_ascent(size)-font.get_descent(size))/2),item.number,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("eef8dd"))
