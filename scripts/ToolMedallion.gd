extends Control
# Complete reference-matched objects, with live hit targets/captions outside art.
const ATLAS = preload("res://assets/ui/material/reference-tools.png")
var symbol := "pack"
var primary := false
static func paint(canvas: CanvasItem, id: String, box: Rect2) -> void:
 var index: int = ["pack","craft","rain"].find(id)
 if index < 0: return
 var span: float = ATLAS.get_width()/3.0
 canvas.draw_texture_rect_region(ATLAS,box,Rect2(index*span,0,span,ATLAS.get_height()))
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)
func _draw() -> void:
 var side := minf(size.x,size.y)
 paint(self,symbol,Rect2((size-Vector2.ONE*side)/2,Vector2.ONE*side))
