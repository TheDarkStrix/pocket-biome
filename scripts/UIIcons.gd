extends RefCounted
const REFERENCE_RESOURCES = preload("res://assets/ui/material/reference-resources.png")
const COMMON = preload("res://assets/ui/icons.png")
const TOOLS = preload("res://assets/ui/material/tool-icons.png")
const PAINTED = {"pack":Vector2i(0,0),"craft":Vector2i(1,0),"rain":Vector2i(2,0),"codex":Vector2i(3,0),"settings":Vector2i(0,1),"world":Vector2i(1,1),"ecology":Vector2i(2,1),"coins":Vector2i(3,1)}
const RESOURCES = preload("res://assets/nodes/harvest_states.png")
const CELLS = {"coins":Vector2i(0,0),"star_dew":Vector2i(1,0),"clay":Vector2i(2,0),"iron":Vector2i(0,1),"rain":Vector2i(1,1),"heat":Vector2i(2,1),"frost":Vector2i(0,2),"codex":Vector2i(1,2),"settings":Vector2i(2,2)}
const MATERIALS = {"wood":Vector2i(2,1),"stone":Vector2i(0,2),"fiber":Vector2i(1,2),"brick":Vector2i(2,2)}
const MATERIAL_BOUNDS = {"wood":Rect2(67,130,287,273),"stone":Rect2(93,112,256,221),"fiber":Rect2(61,69,325,283),"brick":Rect2(81,95,270,228)}
const STRUCTURES = preload("res://assets/structures/structures.png")
const ISLAND = preload("res://assets/app_icon.png")
const LINE = {
 "moisture":preload("res://assets/ui/line/moisture.svg"),
 "sound":preload("res://assets/ui/line/sound.svg"),
 "music":preload("res://assets/ui/line/music.svg"),
 "motion":preload("res://assets/ui/line/motion.svg"),
 "shield":preload("res://assets/ui/line/shield.svg"),
 "challenge":preload("res://assets/ui/line/challenge.svg"),

 "ecology":preload("res://assets/ui/line/ecology.svg"),
 "camera":preload("res://assets/ui/line/camera.svg"),
 "codex":preload("res://assets/ui/line/codex.svg"),
 "craft":preload("res://assets/ui/line/craft.svg"),
 "world":preload("res://assets/ui/line/world.svg"),
 "settings":preload("res://assets/ui/line/settings.svg"),
 "rain":preload("res://assets/ui/line/rain.svg"),
 "heat":preload("res://assets/ui/line/heat.svg"),
 "frost":preload("res://assets/ui/line/frost.svg")}
static var textures := {}
static func texture(id: String) -> Texture2D:
 if textures.has(id): return textures[id]
 if id in ["wood","stone","coins"]:
  var atlas := AtlasTexture.new(); atlas.atlas = REFERENCE_RESOURCES
  var cell: int = ["wood","stone","coins"].find(id)
  var factor := Vector2(REFERENCE_RESOURCES.get_size())/Vector2(2172,724)
  atlas.region = Rect2(Vector2(cell*724+50,55)*factor,Vector2(624,614)*factor)
  atlas.filter_clip = true; textures[id] = atlas
  return atlas
 if PAINTED.has(id):
  var result := AtlasTexture.new(); result.atlas = TOOLS
  var span := Vector2(TOOLS.get_size())/Vector2(4,2)
  result.region = Rect2(Vector2(PAINTED[id])*span,span)
  result.filter_clip = true; textures[id] = result
  return result
 if LINE.has(id): return LINE[id]
 if id == "world": return ISLAND
 if id == "craft":
  var workbench := AtlasTexture.new()
  workbench.atlas = STRUCTURES
  workbench.region = Rect2(0,0,418,445)
  workbench.filter_clip = true
  textures[id] = workbench
  return workbench
 if not CELLS.has(id) and not MATERIALS.has(id): return null
 var common := CELLS.has(id)
 var cell: Vector2i = CELLS[id] if common else MATERIALS[id]
 var atlas := AtlasTexture.new()
 atlas.atlas = COMMON if common else RESOURCES
 atlas.region = Rect2(cell.x*418,cell.y*418,418,418)
 if MATERIAL_BOUNDS.has(id):
  var bounds: Rect2 = MATERIAL_BOUNDS[id]
  atlas.region = Rect2(atlas.region.position+bounds.position,bounds.size)
 atlas.filter_clip = true
 textures[id] = atlas
 return atlas
static func draw(canvas: CanvasItem, id: String, position: Vector2, extent: float, tint: Color = Color.WHITE) -> void:
 var icon := texture(id)
 if icon != null: canvas.draw_texture_rect(icon,Rect2(position-Vector2.ONE*extent/2,Vector2.ONE*extent),false,tint)
