extends Control
var tile_type := "grass"
var evolution := ""
var silhouette := false
var extent := 76.0
func _ready() -> void:
 custom_minimum_size = Vector2.ONE*extent
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var span := minf(size.x,size.y)
 preload("res://scripts/TileArtwork.gd").draw_tile(self,tile_type,Vector2(size.x/2,size.y*0.67),span/560.0,Color(0.2,0.28,0.31) if silhouette else Color.WHITE,evolution)
