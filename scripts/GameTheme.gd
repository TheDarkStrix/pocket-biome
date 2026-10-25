extends RefCounted
# Original Pocket Diorama interface: parchment, brass and ink, independent of world palettes.
const PAPER = Color("fff5dd")
const PAPER_ALT = Color("f1e4c6")
const INK = Color("294b50")
const MUTED = Color("62736b")
const ACTION = Color("427f79")
const GOLD = Color("e8b351")
const BORDER = Color("c5a66f")
const BODY = preload("res://assets/fonts/Nunito.ttf")
const DISPLAY = preload("res://assets/fonts/Fredoka.ttf")
static func theme() -> Theme:
 var result := Theme.new()
 var body := FontVariation.new()
 body.base_font = BODY
 body.variation_opentype = {"wght":650}
 result.default_font = body
 result.default_font_size = 17
 return result
static func panel(color: Color) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = color
 style.set_corner_radius_all(20)
 style.set_border_width_all(2)
 style.border_color = BORDER
 style.shadow_color = Color(0.13,0.24,0.25,0.18)
 style.shadow_size = 5
 style.shadow_offset = Vector2(0,4)
 style.content_margin_left = 16
 style.content_margin_right = 16
 style.content_margin_top = 12
 style.content_margin_bottom = 12
 return style
