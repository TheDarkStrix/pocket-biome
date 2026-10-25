extends Control
const Palette = preload("res://scripts/GameTheme.gd")
var stage := 1
var fraction := 0.0
func _ready() -> void:
 custom_minimum_size = Vector2(52,52)
 size_flags_vertical = Control.SIZE_SHRINK_CENTER
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 set_meta("base_font",18)
func display(model) -> void:
 stage = model.state.chapter
 var chapter: Dictionary = model.campaign.chapter_definition(model)
 fraction = 0.0
 for metric in chapter.checks:
  fraction += clampf(float(model.campaign.metric(model,metric))/float(chapter.checks[metric]),0,1)
 fraction /= maxi(1,chapter.checks.size())
 tooltip_text = "Chapter %d · %s · %d%%" % [stage,chapter.name,roundi(fraction*100)]
 queue_redraw()
func _draw() -> void:
 var center := size/2
 var radius := minf(size.x,size.y)/2-4
 draw_arc(center,radius,0,TAU,48,Palette.BORDER,2,true)
 if fraction > 0: draw_arc(center,radius,-PI/2,-PI/2+TAU*fraction,48,Palette.ACCENT,3,true)
 var font := get_theme_default_font()
 var font_size := get_theme_font_size("font_size")
 var text := str(stage)
 var span := font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
 draw_string(font,center+Vector2(-span.x/2,font.get_ascent(font_size)*0.35),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Palette.INK)
