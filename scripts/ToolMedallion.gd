extends Control
# Painted physical tool socket; its enclosing Button owns touch and focus.
const BASE = preload("res://assets/ui/material/tool-medallion.png")
const Icons = preload("res://scripts/UIIcons.gd")
var symbol := "pack"
var primary := false
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)
func _draw() -> void:
 var side := minf(size.x,size.y)
 var box := Rect2((size-Vector2.ONE*side)/2,Vector2.ONE*side)
 draw_texture_rect(BASE,box,false,Color(1.1,1.06,0.91) if primary else Color.WHITE)
 if primary:
  draw_arc(size/2,side*0.465,0,TAU,64,Color("f0d39e"),1.5,true)
 if symbol != "": Icons.draw(self,symbol,size/2,side*0.79)
