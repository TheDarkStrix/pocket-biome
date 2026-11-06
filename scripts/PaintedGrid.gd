extends RefCounted
# Atlas cells include transparent gutters; only their painted caps should set pitch.
# This inset covers the narrowest ready/harvested opening cap with a small overlap.
const HALF_WIDTH := 58.0
const HALF_HEIGHT := 29.0
const SURFACE_Y := -7.0
static func project(cell: Vector2) -> Vector2:
 return Vector2((cell.x-cell.y)*HALF_WIDTH,(cell.x+cell.y)*HALF_HEIGHT)
static func unproject(point: Vector2) -> Vector2:
 return Vector2(point.x/(2*HALF_WIDTH)+point.y/(2*HALF_HEIGHT),point.y/(2*HALF_HEIGHT)-point.x/(2*HALF_WIDTH))
static func outline(at: Vector2, scale: float) -> PackedVector2Array:
 var result := PackedVector2Array()
 for point in [Vector2(0,-HALF_HEIGHT),Vector2(HALF_WIDTH,0),Vector2(0,HALF_HEIGHT),Vector2(-HALF_WIDTH,0),Vector2(0,-HALF_HEIGHT)]: result.append(at+(point+Vector2(0,SURFACE_Y))*scale)
 return result
