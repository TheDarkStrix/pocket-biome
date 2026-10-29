extends RefCounted
# Original ecological interface informed by Terra Nil's hierarchy, not copied assets.
const PAPER = Color("252a31")
const PAPER_ALT = Color("323942")
const INK = Color("f3f1eb")
const MUTED = Color("b6bdc5")
const ACTION = Color("3d4652")
const ACCENT = Color("ead09b")
const BUILD = Color("e2bd7d")
const WATER = Color("9fcdd9")
const READY = Color("bdd7b2")
const PRIMARY_INK = Color("242832")
const BORDER = Color("515963")
const SHEET_BG = Color("202d30")
const SHEET_CARD = Color("2b383a")
const SHEET_INK = Color("fff1d4")
const SHEET_MUTED = Color("c4c6b4")
const SHEET_CTA = Color("c8d6aa")
const BODY = preload("res://assets/fonts/Lato-Regular.ttf")
const DISPLAY = preload("res://assets/fonts/Title.tres")
static func theme() -> Theme:
 var result := Theme.new()
 result.default_font = BODY
 result.default_font_size = 17
 return result
static func panel(color: Color) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = color
 style.set_corner_radius_all(14)
 style.set_border_width_all(1)
 style.border_color = BORDER
 style.content_margin_left = 12
 style.content_margin_right = 12
 style.content_margin_top = 10
 style.content_margin_bottom = 10
 return style

static func floating(color: Color = PAPER, radius: int = 18) -> StyleBoxFlat:
 var style := panel(color)
 style.set_corner_radius_all(radius)
 style.border_color = Color("5a616b")
 style.shadow_color = Color(0.04,0.05,0.08,0.25)
 style.shadow_size = 6
 style.shadow_offset = Vector2(0,4)
 return style

static func quiet() -> StyleBoxFlat:
 var style := panel(Color(0,0,0,0))
 style.set_border_width_all(0)
 return style

static func sheet_panel(color: Color = SHEET_CARD) -> StyleBoxFlat:
 var style := panel(color)
 style.border_color = Color("8e7751")
 style.set_corner_radius_all(5)
 style.shadow_color = Color(0.12,0.24,0.23,0.09)
 style.shadow_size = 3
 style.shadow_offset = Vector2(0,2)
 return style
