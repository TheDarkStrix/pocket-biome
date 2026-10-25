extends RefCounted
const COMMON = preload("res://assets/ui/icons.png")
const RESOURCES = preload("res://assets/nodes/harvest_states.png")
const CELLS = {"coins":Vector2i(0,0),"star_dew":Vector2i(1,0),"clay":Vector2i(2,0),"iron":Vector2i(0,1),"rain":Vector2i(1,1),"heat":Vector2i(2,1),"frost":Vector2i(0,2),"codex":Vector2i(1,2),"settings":Vector2i(2,2)}
const MATERIALS = {"wood":Vector2i(2,1),"stone":Vector2i(0,2),"fiber":Vector2i(1,2),"brick":Vector2i(2,2)}
const STRUCTURES = preload("res://assets/structures/structures.png")
const ISLAND = preload("res://assets/app_icon.png")
static var textures := {}
static func texture(id: String) -> Texture2D:
 if textures.has(id): return textures[id]
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
 atlas.filter_clip = true
 textures[id] = atlas
 return atlas
static func draw(canvas: CanvasItem, id: String, position: Vector2, extent: float, tint: Color = Color.WHITE) -> void:
 var icon := texture(id)
 if icon != null: canvas.draw_texture_rect(icon,Rect2(position-Vector2.ONE*extent/2,Vector2.ONE*extent),false,tint)
