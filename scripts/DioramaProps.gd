extends RefCounted
const Geometry = preload("res://scripts/DioramaGeometry.gd")
static var PROFILES:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/diorama.json")).profiles
const GREEN = Color("6fa44d")
const WOOD = Color("91623b")
const STONE = Color("879488")
const CREAM = Color("efe6bc")
static func tree(g, at: Vector3, seed: int, kind: String = "oak", palette: Color = GREEN, height: float = 1.0) -> void:
 var trunk := Color("825738")
 g.cylinder(at+Vector3(0,height*0.34,0),0.055*height,height*0.68,trunk,0.55)
 for i in range(3):
  var angle: float = i*TAU/3+seed
  var tip := at+Vector3(cos(angle)*0.25,height*0.72,sin(angle)*0.25)
  g.beam(at+Vector3(0,height*0.4,0),tip,0.043*height,trunk)
 if kind == "pine":
  for tier in range(3):
   var r: float = height*(0.35-tier*0.065)
   g.cylinder(at+Vector3(0,height*(0.55+tier*0.22),0),r,height*0.53,palette.lightened(tier*0.045),0.0,"leaf")
   # Branch whorls soften the tapered evergreen silhouette.
   for branch in range(5):
    var angle: float = branch*TAU/5+tier*0.5
    var p := at+Vector3(cos(angle)*r*0.58,height*(0.38+tier*0.23),sin(angle)*r*0.58)
    g.lump(p,Vector3(r*0.46,height*0.085,r*0.46),palette.lightened(tier*0.045),seed+tier*5+branch,"leaf")
 else:
  for branch in range(18):
   var angle: float = branch*2.39996+seed
   var r:float=height*(0.2+0.11*sin(branch*1.7))
   var p := at+Vector3(cos(angle)*r,height*(0.83+0.16*sin(branch*2.1)),sin(angle)*r)
   g.lump(p,Vector3(0.22,0.16,0.22)*height,palette.lightened(float(branch%3)*0.045),seed+branch,"leaf")
 for root in range(4):
  var a: float = root*TAU/4+seed
  g.beam(at+Vector3(0,0.06,0),at+Vector3(cos(a)*0.19,0.014,sin(a)*0.19),0.045,trunk)
static func flowers(g, seed: int, tint: Color = CREAM, count: int = 8) -> void:
 for i in range(count):
  var a: float = i*2.39996+seed; var r := 0.2+0.22*float((i*7+seed)%11)/11.0
  var p := Vector3(cos(a)*r,0.025,sin(a)*r)
  g.beam(p,p+Vector3(0,0.11,0),0.012,Color("4d7b39"),"leaf")
  for petal in range(4):
   var angle: float = petal*TAU/4
   g.lump(p+Vector3(cos(angle)*0.023,0.12,sin(angle)*0.023),Vector3(0.028,0.012,0.028),tint,seed+i+petal,"petal")
static func rock(g, at: Vector3, size: Vector3, seed: int, color: Color = STONE) -> void:
 g.lump(at+Vector3(0,size.y*0.55,0),size*0.6,color,seed)
 g.lump(at+Vector3(size.x*0.27,0.035,-size.z*0.18),Vector3(size.x*0.22,0.035,size.z*0.21),Color("64844a"),seed+7,"leaf")
static func crystal(g, at: Vector3, height: float, color: Color, angle: float = 0.0) -> void:
 var r: float = height*0.18
 for side in range(6):
  var a: float = angle+side*TAU/6;var b: float = angle+(side+1)*TAU/6
  var p := at+Vector3(cos(a)*r,0.04,sin(a)*r);var q := at+Vector3(cos(b)*r,0.04,sin(b)*r)
  var u := p+Vector3(0,height*0.7,0);var v := q+Vector3(0,height*0.7,0)
  var tint := color.lightened(float(side%3)*0.09)
  g.triangle(p,u,v,tint,"crystal");g.triangle(p,v,q,tint,"crystal")
  g.triangle(u,at+Vector3(0,height,0),v,tint.lightened(0.1),"crystal")
static func shrub(g, at: Vector3, seed: int, tint: Color = GREEN) -> void:
 for i in range(7):
  var a: float = i*2.4+seed;var p := at+Vector3(cos(a)*0.12,0.07,sin(a)*0.12)
  g.lump(p,Vector3(0.17,0.16,0.11),tint.lightened(float(i%3)*0.04),seed+i,"leaf")
static func workbench(g) -> void:
 for x in [-0.28,0.28]:
  for z in [-0.17,0.17]: g.box(Vector3(x,0.18,z),Vector3(0.075,0.36,0.075),WOOD.darkened(0.15))
 for plank in range(4):g.box(Vector3(0,0.39,-0.22+plank*0.145),Vector3(0.77,0.08,0.14),WOOD.lightened(plank*0.035))
 g.box(Vector3(-0.06,0.436,0.015),Vector3(0.4,0.01,0.32),Color("4d9eae"))
 for line in range(3):g.box(Vector3(-0.12+line*0.11,0.443,0.015),Vector3(0.007,0.005,0.23),CREAM)
 g.beam(Vector3(0.15,0.46,-0.16),Vector3(0.29,0.46,0.12),0.027,WOOD.darkened(0.2))
 g.box(Vector3(0.25,0.48,0.11),Vector3(0.14,0.05,0.07),STONE)
static func windmill(g) -> void:
 g.cylinder(Vector3(0,0.31,0),0.25,0.62,Color("a18b66"),0.72)
 for z in range(3):
  for i in range(7):
   var angle: float = i*TAU/7+z*0.3
   g.box(Vector3(sin(angle)*0.21,0.1+z*0.15,cos(angle)*0.21),Vector3(0.12,0.025,0.04),STONE.darkened(0.08),"solid",Vector3(0,angle,0))
 # Pitched roof, with a real back face visible during orbit.
 for side in [-1.0,1.0]:
  var a := Vector3(-0.34,0.59,side*0.31);var b := Vector3(0.34,0.59,side*0.31)
  var c := Vector3(0.34,0.97,0);var d := Vector3(-0.34,0.97,0)
  g.triangle(a,b,c,Color("516575"));g.triangle(a,c,d,Color("63788a"))
  g.beam(a,b,0.04,WOOD);g.beam(a,d,0.04,WOOD);g.beam(b,c,0.04,WOOD)
 g.beam(Vector3(-0.35,0.98,0),Vector3(0.35,0.98,0),0.045,WOOD.lightened(0.12))
 g.box(Vector3(0,0.18,0.224),Vector3(0.16,0.35,0.035),WOOD.darkened(0.25))
 g.lump(Vector3(0.046,0.19,0.25),Vector3.ONE*0.015,Color("e9c47a"),3)
 for x in [-0.24,0.24]:
  g.box(Vector3(x,0.32,0.22),Vector3(0.06,0.09,0.06),Color("ffd586"),"glow")
static func rotor(g) -> void:
 for i in range(4):
  var angle: float = i*TAU/4+PI/4
  var a := Vector3(sin(angle)*0.06,cos(angle)*0.06,0)
  var b := Vector3(sin(angle)*0.59,cos(angle)*0.59,0)
  g.beam(a,b,0.035,WOOD)
  var sideways := Vector3(cos(angle),-sin(angle),0)
  var tip := b+sideways*0.12;var root := a+sideways*0.07
  g.triangle(a,b,tip,CREAM,"cloth");g.triangle(a,tip,root,CREAM,"cloth")
  g.beam(root,tip,0.025,WOOD)
 g.cylinder(Vector3.ZERO,0.065,0.055,Color("bd894b"))
static func build(tile: Dictionary, materials: Dictionary) -> Node3D:
 var root := Node3D.new();var g = Geometry.new()
 var type: String = tile.type;var evolution: String = tile.get("evolution","");var seed: int = tile.get("id",1)
 var profile:Dictionary=PROFILES.get(evolution,{})
 var features:Array=profile.get("features",[])
 var foliage:Color=Color(profile.get("foliage",GREEN.to_html(false)))

 match type:
  "oak":tree(g,Vector3.ZERO,seed,"oak",foliage,1.12)
  "forest":
   for i in range(3):tree(g,Vector3(-0.22+i*0.22,0,-0.12 if i==1 else 0.12),seed+i,"pine",foliage,0.8+0.12*(i%2))
  "fiber":shrub(g,Vector3.ZERO,seed)
  "stone","iron","clay":
   rock(g,Vector3(-0.1,0,0),Vector3(0.62,0.53,0.58),seed,Color("b98a64") if type=="clay" else STONE)
   rock(g,Vector3(0.23,0,0.18),Vector3(0.25,0.18,0.23),seed+2)
   if type=="iron":
    for i in range(3):crystal(g,Vector3(-0.18+i*0.14,0.08,0.19),0.2,Color("d5a264"),i)
  "crystal","glacier":
   for i in range(5):
    var a: float = i*2.4;crystal(g,Vector3(sin(a)*0.21,0,cos(a)*0.21),0.8 if i==0 else 0.3+i*0.07,Color("83cde0") if type=="glacier" else Color("ab8cde"),a)
  "vent":
   rock(g,Vector3.ZERO,Vector3(0.7,0.5,0.7),seed,Color("655e59"))
   g.cylinder(Vector3(0,0.31,0),0.13,0.025,Color("f5a35c"),1,"glow")
  "workbench":workbench(g)
  "windmill":windmill(g)
  "furnace":
   g.cylinder(Vector3(0,0.28,0),0.29,0.56,Color("9e7460"),0.7)
   g.box(Vector3(0,0.6,-0.035),Vector3(0.22,0.35,0.22),Color("8d695a"))
   g.box(Vector3(0,0.2,0.265),Vector3(0.22,0.21,0.03),Color("ffad61"),"glow")
   for i in [-1,0,1]:g.box(Vector3(i*0.07,0.2,0.29),Vector3(0.015,0.23,0.025),Color("594e48"))
  "golem":
   g.lump(Vector3(0,0.31,0),Vector3(0.23,0.26,0.18),STONE,seed)
   g.lump(Vector3(0,0.7,0),Vector3(0.21,0.21,0.18),STONE.lightened(0.1),seed+1)
   for x in [-1.0,1.0]:
    g.lump(Vector3(x*0.28,0.32,0),Vector3(0.09,0.2,0.1),STONE,seed+2)
    g.lump(Vector3(x*0.13,0.08,0.04),Vector3(0.11,0.08,0.13),STONE.darkened(0.1),seed+3)
    g.lump(Vector3(x*0.075,0.71,0.17),Vector3(0.035,0.04,0.02),Color("97e4d5"),seed,"glow")
  "totem","shrine","lantern":
   g.cylinder(Vector3(0,0.36,0),0.11,0.72,WOOD,0.88)
   for y in [0.2,0.4,0.6]:
    g.cylinder(Vector3(0,y,0),0.118,0.025,Color("85d1d0"),1,"glow")
   g.beam(Vector3(-0.23,0.56,0),Vector3(0.23,0.56,0),0.07,WOOD)
   shrub(g,Vector3(0.2,0,0.12),seed)
  "compost","dirt":
   for row in range(4):g.box(Vector3(0,0.035,-0.27+row*0.18),Vector3(0.72,0.05,0.11),Color("835c3d"))
   if type=="compost":
    for side in [-1,1]:g.box(Vector3(side*0.39,0.08,0),Vector3(0.05,0.15,0.78),WOOD)
  "water":
   # True water geometry; reeds and bank stones are separate from its surface.
   for i in range(4):
    var a: float = 0.5+i*1.7;rock(g,Vector3(sin(a)*0.37,0,cos(a)*0.37),Vector3(0.17,0.12,0.17),seed+i)
   for i in range(6):g.beam(Vector3(-0.32+i*0.025,0,-0.27),Vector3(-0.34+i*0.03,0.3+(i%3)*0.06,-0.24),0.012,Color("71934b"),"leaf")
  _:pass
 if evolution == "grove":
  tree(g,Vector3.ZERO,seed,"oak",Color("41884c"),1.45)
 elif evolution == "verdant":
  tree(g,Vector3(-0.2,0,-0.15),seed,"oak",Color("77ad57"),0.75)
 elif evolution == "quarry":
  for i in range(4):crystal(g,Vector3(sin(i*1.8)*0.27,0,cos(i*1.8)*0.27),0.35+i*0.11,Color("91c9bd"),i)
 elif evolution in ["ember","sunstone","obsidian"]:
  for i in range(3):crystal(g,Vector3(sin(i*2.4)*0.25,0.06,cos(i*2.4)*0.25),0.18,Color("f4b173"),i)
 elif evolution in ["crystalforest","moonflower","celestial"]:
  for i in range(3):crystal(g,Vector3(sin(i*2.4)*0.3,0,cos(i*2.4)*0.3),0.24,Color("b7a4df"),i)
 if evolution in ["rainforest","steam","ironwood"]:shrub(g,Vector3(0.28,0,-0.21),seed,foliage)
 if type=="water" or "pool" in features:
  var water_tint:=Color("b6c9ff") if evolution in ["lake","lagoon","celestial"] else Color.WHITE
  for edge in range(20):
   var a:float=edge*TAU/20;var b:float=(edge+1)*TAU/20
   var p:=Vector3(sin(a)*0.41,0.018,cos(a)*0.37);var q:=Vector3(sin(b)*0.41,0.018,cos(b)*0.37)
   g.triangle(Vector3(0,0.018,0),p,q,water_tint,"water")
  for lily in range(3):
   var a:float=lily*2.4+seed
   g.cylinder(Vector3(sin(a)*0.2,0.032,cos(a)*0.2),0.06,0.012,Color("81a959"),1,"leaf")
 if "oasis_tree" in features:tree(g,Vector3(0.28,0,-0.22),seed,"oak",foliage,0.75)
 if "reeds" in features:
  for i in range(9):g.beam(Vector3(0.24+(i%3)*0.035,0,-0.18+(i/3)*0.03),Vector3(0.27+(i%3)*0.035,0.32+(i%2)*0.12,-0.17+(i/3)*0.03),0.016,Color("8b994a"),"leaf")
 if "ice" in features:
  for i in range(4):crystal(g,Vector3(sin(i*2.4)*0.3,0,cos(i*2.4)*0.3),0.17,Color("c2e1df"),i)
 if "moss" in features:shrub(g,Vector3(0.16,0,0.17),seed,Color("6c9c4e"))
 if "obsidian" in features:
  rock(g,Vector3(0.2,0,0),Vector3(0.4,0.4,0.4),seed,Color("514a55"))
 if "blue_crystals" in features:
  for i in range(3):crystal(g,Vector3(sin(i*2.3)*0.29,0,cos(i*2.3)*0.29),0.18,Color("89c7d6"),i)
 var flower_color := Color("d6c3ee") if evolution in ["moonflower","celestial"] else CREAM
 if type not in ["vent","glacier","dirt","compost"]:flowers(g,seed,flower_color,6 if evolution=="" else 12)
 if type not in ["water","glacier","vent","dirt","compost"]:
  for tuft in range(12):
   var angle:float=tuft*2.39996+seed
   var distance:float=0.25+0.17*float(tuft%3)/2
   var base:=Vector3(sin(angle)*distance,0.005,cos(angle)*distance)
   for blade in range(3):
    var side:=Vector3(cos(blade*2.1),0,sin(blade*2.1))*0.018
    var tip:=base+Vector3(side.x*1.4,0.08+(tuft%3)*0.018,side.z*1.4)
    g.triangle(base-side,base+side,tip,foliage.lightened(0.12),"leaf")
 var form:=Node3D.new();form.name="HarvestForm";root.add_child(form)
 g.finish(form,materials)
 if type in ["oak","forest","stone","iron","fiber","clay"]:
  var depleted:=Node3D.new();depleted.name="Depleted";root.add_child(depleted);depleted.hide()
  var d=Geometry.new()
  if type in ["oak","forest"]:
   d.cylinder(Vector3(0,0.1,0),0.14,0.2,WOOD,0.88)
   d.cylinder(Vector3(0,0.205,0),0.123,0.012,Color("c9a16b"))
  elif type=="fiber":shrub(d,Vector3.ZERO,seed,Color("82945a"));depleted.scale=Vector3(0.6,0.35,0.6)
  else:
   for piece in range(5):rock(d,Vector3(sin(piece*2.4)*0.18,0,cos(piece*2.4)*0.18),Vector3(0.15,0.08,0.12),seed+piece)
  d.finish(depleted,materials)
 if type=="windmill":
  var moving := Node3D.new();moving.name="Rotor";root.add_child(moving);moving.position=Vector3(0,0.71,0.26)
  var sails = Geometry.new();rotor(sails);sails.finish(moving,materials)
 return root
