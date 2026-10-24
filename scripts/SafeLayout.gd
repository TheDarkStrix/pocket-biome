extends RefCounted
# Physical display coordinates -> logical viewport coordinates. Pure for QA fixtures.
static func logical_safe_rect(viewport: Vector2, physical: Vector2, safe: Rect2) -> Rect2:
 var full := Rect2(Vector2.ZERO,viewport)
 if physical.x <= 0 or physical.y <= 0 or safe.size.x <= 0 or safe.size.y <= 0: return full
 var clipped := safe.intersection(Rect2(Vector2.ZERO,physical))
 if not clipped.has_area(): return full
 var scale := viewport/physical
 return Rect2(clipped.position*scale,clipped.size*scale)

static func regions(safe: Rect2, header_height: float = 185, footer_height: float = 305) -> Dictionary:
 var content := safe.grow(-20)
 var top := Rect2(content.position,Vector2(content.size.x,header_height))
 var bottom := Rect2(Vector2(content.position.x,content.end.y-footer_height),Vector2(content.size.x,footer_height))
 var world := Rect2(Vector2(content.position.x,top.end.y+8),Vector2(content.size.x,maxf(100,bottom.position.y-top.end.y-16)))
 var modal := Rect2(Vector2(content.position.x,top.end.y),Vector2(content.size.x,maxf(180,content.end.y-top.end.y)))
 return {"top":top,"bottom":bottom,"world":world,"modal":modal}
