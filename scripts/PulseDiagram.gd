extends Control
# A schematic preview of the real center-plus-four-neighbors footprint.
var power := "rain"
var reduced_motion := false
var clock := 0.0
func _process(delta: float) -> void:
 if reduced_motion or not is_visible_in_tree() or not get_global_rect().intersects(get_viewport_rect()): return
 clock += minf(delta,0.1)
 queue_redraw()
func _ready() -> void:
 custom_minimum_size = Vector2(120,116)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var colors := {"rain":Color("86bac4"),"heat":Color("e0b387"),"frost":Color("b4cbd9")}
 var center := size/2+Vector2(0,12)
 for at in [Vector2i.UP,Vector2i.LEFT,Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN]:
  var p := center+Vector2((at.x-at.y)*21,(at.x+at.y)*11)
  preload("res://scripts/TileArtwork.gd").draw_tile(self,"grass",p,0.105,Color.WHITE,"")
  var diamond := PackedVector2Array([p+Vector2(0,-10),p+Vector2(20,0),p+Vector2(0,10),p+Vector2(-20,0)])
  draw_colored_polygon(diamond,Color(colors[power],0.32))
 preload("res://scripts/UIIcons.gd").draw(self,power,center-Vector2(0,44),36,Color("356c72") if power == "rain" else Color("ad6744") if power == "heat" else Color("587c9a"))

 if not reduced_motion:
  for index in range(7):
   var phase := fposmod(clock*0.7+index*0.173,1.0)
   var at := center+Vector2(-38+index*12,-64+phase*70)
   if power == "rain": draw_line(at,at+Vector2(2,10),Color(0.25,0.59,0.7,0.5),1.5,true)
   elif power == "heat": draw_circle(center+Vector2(sin(index*2.0)*32,-phase*56),2,Color(0.82,0.43,0.2,(1-phase)*0.5))
   else: draw_circle(at,1.5,Color(0.7,0.86,0.9,0.6))
