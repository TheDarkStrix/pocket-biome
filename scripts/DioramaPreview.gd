extends Control
# UI portraits come from the same modeled props as the playable island.
var tile_type := "grass"
var evolution := ""
var silhouette := false
var extent := 152.0
var host: Node
var world := false
var prop_only := false
var tint := Color("d8e6d8")
func _ready() -> void:
 custom_minimum_size = Vector2(0,extent)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 if world: texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
func _process(_delta:float) -> void:
 if world and is_visible_in_tree() and is_instance_valid(host) and host.orbit_enabled:queue_redraw()
func _draw() -> void:
 if not world and preload("res://scripts/DioramaPortraits.gd").paint(self,tile_type,evolution,Rect2(Vector2(6,6),size-Vector2(12,12)),silhouette):return
 if world and is_instance_valid(host) and host.orbit_enabled:
  var view=host.orbit_world
  var crop:Rect2=view.projected_bounds(false).intersection(view.frame)
  if crop.size.x<=0 or crop.size.y<=0:return
  var ratio:float=minf((size.x-12)/crop.size.x,(size.y-12)/crop.size.y)
  var target:=Rect2(size/2-crop.size*ratio/2,crop.size*ratio)
  var density:Vector2=Vector2(view.viewport.size)/view.frame.size
  draw_texture_rect_region(view.viewport.get_texture(),target,Rect2((crop.position-view.frame.position)*density,crop.size*density))
  return
 if world and is_instance_valid(host):
  var bounds: Rect2 = host.world_art_bounds(false)
  var scale := minf((size.x-18)/bounds.size.x,(size.y-12)/bounds.size.y)
  host.island_environment.paint_static(self,size/2-bounds.get_center()*scale,scale)
  for key in host.render_keys():
   var tile: Dictionary = host.model.state.tiles[key]
   var footprint: float = 2 if tile.size == 4 else 1
   var point: Vector2 = host.project(Vector2(host.model.coord(key))+(Vector2(0.5,0.5) if footprint == 2 else Vector2.ZERO))
   var at := size/2+(point-bounds.get_center())*scale
   preload("res://scripts/TileArtwork.gd").draw_joined(self,tile.type,at,132.0/418.0*scale*footprint,Color.WHITE,tile.evolution)
 else:
  var artwork = preload("res://scripts/TileArtwork.gd")
  var spec: Dictionary = artwork.appearance(tile_type,evolution)
  if spec.is_empty(): return
  var bounds: Rect2 = artwork.visual_bounds(spec,132.0/418.0)
  var scale := minf((size.x-18)/bounds.size.x,(size.y-12)/bounds.size.y)
  var at: Vector2 = size/2-bounds.get_center()*scale
  if prop_only: artwork.draw_joined(self,tile_type,at,132.0/418.0*scale,Color("355254") if silhouette else Color.WHITE,evolution)
  else: artwork.draw_tile(self,tile_type,at,132.0/418.0*scale,Color("355254") if silhouette else Color.WHITE,evolution)
