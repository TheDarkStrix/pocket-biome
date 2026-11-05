extends Control
var tiles: Array = []
func _ready() -> void: custom_minimum_size = Vector2(0,210); mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 if tiles.is_empty(): return
 var points := []; var bounds := Rect2()
 for tile in tiles:
  var pair: PackedStringArray = tile.at.split(",")
  var c := Vector2(float(pair[0]),float(pair[1]))+Vector2.ONE*(0.5 if tile.size == 4 else 0.0)
  var p := Vector2((c.x-c.y)*49,(c.x+c.y)*24)
  points.append({"tile":tile,"point":p})
  var footprint: float = 2.0 if tile.size == 4 else 1.0
  var extent := Rect2(p-Vector2(70,100)*footprint,Vector2(140,135)*footprint)
  bounds = extent if points.size() == 1 else bounds.merge(extent)
 var scale: float = maxf(0.01,minf((size.x-20)/maxf(1,bounds.size.x),(size.y-12)/maxf(1,bounds.size.y)))
 points.sort_custom(func(a,b): return a.point.y < b.point.y)
 for item in points:
  var tile: Dictionary = item.tile
  var point: Vector2 = (item.point-bounds.get_center())*scale+size/2
  preload("res://scripts/TileArtwork.gd").draw_tile(self,tile.type,point,98.0/418.0*scale*(2 if tile.size == 4 else 1),Color.WHITE,tile.evolution)
