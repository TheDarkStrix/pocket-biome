extends CanvasLayer
# Original low-cost atmosphere: three texture samples, no full-screen blur or scene reads.
var material_sky: ShaderMaterial
var elapsed := 0.0
func _ready() -> void:
 layer = -2
 var noise := FastNoiseLite.new()
 noise.seed = 9423
 noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
 noise.frequency = 0.025
 var cloud := NoiseTexture2D.new()
 cloud.width = 256; cloud.height = 256
 cloud.seamless = true
 cloud.noise = noise
 material_sky = ShaderMaterial.new()
 material_sky.shader = preload("res://assets/shaders/sky.gdshader")
 material_sky.set_shader_parameter("cloud_noise",cloud)
 var sky := ColorRect.new()
 sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
 sky.material = material_sky
 sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(sky)
func display(palette: String, time: float) -> void:
 if material_sky == null: return
 elapsed = time
 var colors: Array = {
  "day":[Color("67adbf"),Color("d6e4d3"),Color("f3f5e8")],
  "dusk":[Color("695d8d"),Color("735f79"),Color("968795")],
  "moon":[Color("142e50"),Color("294254"),Color("60778a")],
  "celestial":[Color("24495b"),Color("345867"),Color("6b8c93")],
  "sakura":[Color("a28aaf"),Color("edd7ce"),Color("f5e6dd")]
 }.get(palette,[Color("67adbf"),Color("d6e4d3"),Color("f3f5e8")])
 material_sky.set_shader_parameter("zenith",colors[0])
 material_sky.set_shader_parameter("horizon",colors[1])
 material_sky.set_shader_parameter("cloud_color",colors[2])
 material_sky.set_shader_parameter("drift",elapsed)
