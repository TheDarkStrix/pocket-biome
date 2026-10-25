extends Control
# Original presentation stage; uses the same atlas artwork as the playable island.
var tile_type := "grass"
var evolution := ""
var silhouette := false
var extent := 152.0
var host: Node
var world := false
var tint := Color("d8e6d8")
func _ready() -> void:
 custom_minimum_size = Vector2(0,extent)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var center := Vector2(size.x/2,size.y*0.64)
 var radius := minf(size.x*0.43,size.y*0.48)
 for band in range(8,0,-1):
  draw_circle(center-Vector2(0,12),radius*float(band)/8,Color(tint,0.025+0.018*(8-band)))
 if world and is_instance_valid(host):
  var bounds: Rect2 = host.world_art_bounds(false)
  var scale := minf((size.x-18)/bounds.size.x,(size.y-12)/bounds.size.y)
  for key in host.render_keys():
   var tile: Dictionary = host.model.state.tiles[key]
   var footprint: float = 2 if tile.size == 4 else 1
   var point: Vector2 = host.project(Vector2(host.model.coord(key))+(Vector2(0.5,0.5) if footprint == 2 else Vector2.ZERO))
   var at := size/2+(point-bounds.get_center())*scale
   preload("res://scripts/TileArtwork.gd").draw_tile(self,tile.type,at,132.0/418.0*scale*footprint,Color.WHITE,tile.evolution)
 else:
  var artwork = preload("res://scripts/TileArtwork.gd")
  var spec: Dictionary = artwork.appearance(tile_type,evolution)
  if spec.is_empty(): return
  var scale := minf((size.x-18)/spec.region.size.x,(size.y-12)/spec.region.size.y)
  var at: Vector2 = size/2+(spec.pivot-spec.region.size/2)*scale
  artwork.draw_tile(self,tile_type,at,scale/spec.normalization,Color("355254") if silhouette else Color.WHITE,evolution)
