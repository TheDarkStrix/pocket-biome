extends RefCounted
# Original ecological interface informed by Terra Nil's hierarchy, not copied assets.
const PAPER = Color("252a30")
const PAPER_ALT = Color("30373e")
const INK = Color("eef0e8")
const MUTED = Color("a5afb4")
const ACTION = Color("353f48")
const ACCENT = Color("aaa7c6")
const PRIMARY_INK = Color("242832")
const BORDER = Color("626e77")
const BODY = preload("res://assets/fonts/BiomeInterface.ttf")
const DISPLAY = preload("res://assets/fonts/BiomeDisplay.ttf")
static func theme() -> Theme:
 var result := Theme.new()
 result.default_font = BODY
 result.default_font_size = 17
 return result
static func panel(color: Color) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = color
 style.set_corner_radius_all(4)
 style.set_border_width_all(1)
 style.border_color = BORDER
 style.content_margin_left = 12
 style.content_margin_right = 12
 style.content_margin_top = 10
 style.content_margin_bottom = 10
 return style
