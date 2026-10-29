extends RefCounted
# Blank production assets; all text, counts and states remain live.
const PLAQUE = preload("res://assets/ui/material/slate-plaque.png")
const GREEN = preload("res://assets/ui/draft/place-button.png")
const TITLE = preload("res://assets/fonts/Title.tres")
const CREAM = Color("fff2d2")
static var plaque_texture: ImageTexture
static var green_texture: ImageTexture
static func virtual_texture(source: Texture2D, extent: Vector2i) -> ImageTexture:
 # Virtual pixel density for nine-patch borders; original artwork pixels are untouched.
 var result := ImageTexture.create_from_image(source.get_image())
 result.set_size_override(extent)
 return result
static func frame(tint: Color = Color.WHITE, padding: float = 12) -> StyleBoxTexture:
 if plaque_texture == null: plaque_texture = virtual_texture(PLAQUE,Vector2i(272,91))
 var style := StyleBoxTexture.new()
 style.texture = plaque_texture
 var factor := Vector2(plaque_texture.get_size())/Vector2(2172,724)
 style.region_rect = Rect2(Vector2(10,162)*factor,Vector2(2152,390)*factor)
 style.modulate_color = tint
 for side in [SIDE_LEFT,SIDE_RIGHT]: style.set_texture_margin(side,18); style.set_content_margin(side,padding)
 for side in [SIDE_TOP,SIDE_BOTTOM]: style.set_texture_margin(side,12); style.set_content_margin(side,padding)
 return style
static func primary() -> StyleBoxTexture:
 if green_texture == null: green_texture = virtual_texture(GREEN,Vector2i(444,222))
 var style := StyleBoxTexture.new(); style.texture = green_texture
 var factor := Vector2(green_texture.get_size())/Vector2(1774,887)
 style.region_rect = Rect2(Vector2(22,276)*factor,Vector2(1730,334)*factor)
 for side in [SIDE_LEFT,SIDE_RIGHT]: style.set_texture_margin(side,24); style.set_content_margin(side,24)
 for side in [SIDE_TOP,SIDE_BOTTOM]: style.set_texture_margin(side,15); style.set_content_margin(side,14)
 return style
static func lettering(label: Label, display: bool = false) -> void:
 label.add_theme_color_override("font_color",CREAM)
 label.add_theme_color_override("font_shadow_color",Color(0.025,0.035,0.03,0.95))
 label.add_theme_constant_override("shadow_offset_x",0)
 label.add_theme_constant_override("shadow_offset_y",2)
 if display: label.add_theme_font_override("font",TITLE)
