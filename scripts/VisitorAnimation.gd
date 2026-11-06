extends RefCounted
# Visitor behaviour is cosmetic and depends only on habitat route time and local reactions.
static func pose(id: String, clock: float, still: bool, reaction: float = 0.0) -> Dictionary:
 var t := 0.0 if still else clock
 var response := 0.0 if still else clampf(reaction,0,1)
 var cycle := fposmod(t,6.0)
 var hop := sin(clampf((cycle-3.8)/0.65,0,1)*PI)*9+response*7
 return {"time":t,"flight":maxf(response,sin(clampf((cycle-3.6)/2.4,0,1)*PI)),"reaction":response,"hop":hop,"blink":not still and fposmod(t+0.4,4.9) > 4.72,"wing":0.8 if still else 0.18+absf(sin(t*(8+response*6)))*0.82,"perched":still or (cycle < 3.6 and response < 0.1)}
static func ellipse(canvas: CanvasItem, at: Vector2, radius: Vector2, color: Color) -> void:
 var points := PackedVector2Array()
 for i in range(16): points.append(at+Vector2(cos(i*TAU/16),sin(i*TAU/16))*radius)
 canvas.draw_colored_polygon(points,color)
static func draw(canvas: CanvasItem, id: String, at: Vector2, scale: float, clock: float, still: bool, reaction: float = 0.0) -> void:
 var state := pose(id,clock,still,reaction)
 var t: float = state.time
 if id == "sanctuary_network":
  for i in range(5):
   var p := at+Vector2(sin(t*0.7+i*1.3)*(30+state.reaction*9),-20+cos(t*0.8+i)*15-state.reaction*8)*scale
   canvas.draw_circle(p,5*scale,Color(0.9,0.9,0.55,0.09))
   canvas.draw_circle(p,(1.2+absf(sin(t+i))*0.9)*scale,Color("e8e49d"))
 elif id == "shaded_pond":
  var base := at+Vector2(14,-9)*scale
  ellipse(canvas,base+Vector2(0,4)*scale,Vector2(7,2)*scale,Color(0.12,0.24,0.18,0.18))
  var p := base-Vector2(0,state.hop)*scale
  for side in [-1,1]:
   ellipse(canvas,p+Vector2(side*5,3)*scale,Vector2(3,1.7)*scale,Color("58843b"))
  ellipse(canvas,p,Vector2(6,4.5)*scale,Color("6d9f43"))
  ellipse(canvas,p+Vector2(0,1.5)*scale,Vector2(3,2)*scale,Color("b7d97b"))
  for side in [-1,1]:
   var eye := p+Vector2(side*3.6,-3.5)*scale
   canvas.draw_circle(eye,2.5*scale,Color("b7d97b"))
   if state.blink: canvas.draw_line(eye-Vector2(1,0)*scale,eye+Vector2(1,0)*scale,Color("233a26"),maxf(0.8,scale))
   else: canvas.draw_circle(eye,1*scale,Color("233a26"))
  if state.hop > 1:
   for side in [-1,1]: canvas.draw_line(base+Vector2(side*8,0)*scale,base+Vector2(side*11,-3)*scale,Color(0.65,0.89,0.91,0.7),scale,true)
 elif id == "pollinator_patch":
  for i in range(2):
   var p := at+Vector2(sin(t*0.8+i*2)*18,-26+cos(t+i*2)*8-state.reaction*10)*scale
   var wing: float = state.wing*scale
   var color := Color("f1b963") if i == 0 else Color("9acde3")
   for side in [-1,1]:
    ellipse(canvas,p+Vector2(side*3.8*state.wing,-1)*scale,Vector2(4.5*wing,5.2*scale),color.darkened(0.17))
    ellipse(canvas,p+Vector2(side*3.8*state.wing,-2)*scale,Vector2(3.4*wing,3.9*scale),color)
    ellipse(canvas,p+Vector2(side*2.8*state.wing,3)*scale,Vector2(2.8*wing,3.2*scale),color.lightened(0.15))
   canvas.draw_line(p-Vector2(0,4)*scale,p+Vector2(0,5)*scale,Color("554a39"),maxf(1,scale),true)
   for side in [-1,1]: canvas.draw_line(p-Vector2(0,3)*scale,p+Vector2(side*2,-6)*scale,Color("554a39"),maxf(0.6,scale),true)
 else:
  var p := at+Vector2(12+sin(t*1.4)*8*state.flight,-42-14*state.flight)*scale
  if state.perched:
   for side in [-1,1]: canvas.draw_line(p+Vector2(side*2,3)*scale,p+Vector2(side*3,7)*scale,Color("ae7946"),scale,true)
  var lift: float = 2.0 if state.perched else (state.wing*10)
  canvas.draw_colored_polygon(PackedVector2Array([p+Vector2(-2,1)*scale,p+Vector2(-10,-lift)*scale,p+Vector2(-5,4)*scale]),Color("8db5af"))
  ellipse(canvas,p,Vector2(5,3.6)*scale,Color("f4ebd2"))
  canvas.draw_circle(p+Vector2(4,-2)*scale,3.1*scale,Color("8db5af"))
  canvas.draw_circle(p+Vector2(5,-2.8)*scale,0.8*scale,Color("233a26"))
  canvas.draw_colored_polygon(PackedVector2Array([p+Vector2(6,-2)*scale,p+Vector2(10,-1)*scale,p+Vector2(6,0)*scale]),Color("e7b76d"))
  if not state.perched: canvas.draw_line(p,p+Vector2(9,-lift)*scale,Color("c0d8c9"),2*scale,true)
