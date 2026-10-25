extends Control
var type := "forest"
var evolution := "grove"
var matches := 4
func _ready() -> void:
 custom_minimum_size = Vector2(0,148)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var left := Vector2(size.x*0.24,size.y*0.57)
 for index in range(4):
  var at := Vector2i(index%2,index/2)
  var point := left+Vector2((at.x-at.y)*23,(at.x+at.y)*12)-Vector2(0,10)
  preload("res://scripts/TileArtwork.gd").draw_tile(self,type,point,0.12,Color.WHITE if index < matches else Color("72908a"),"")
 var font := get_theme_default_font()
 draw_string(font,Vector2(size.x*0.48,size.y*0.57),"→",HORIZONTAL_ALIGNMENT_CENTER,-1,24,Color("42796d"))
 var spec: Dictionary = preload("res://scripts/TileArtwork.gd").appearance(type,evolution)
 var scale := minf(size.x*0.40/spec.region.size.x,(size.y-12)/spec.region.size.y)
 var center := Vector2(size.x*0.77,size.y*0.5)
 preload("res://scripts/TileArtwork.gd").draw_tile(self,type,center+(spec.pivot-spec.region.size/2)*scale,scale/spec.normalization,Color.WHITE,evolution)
