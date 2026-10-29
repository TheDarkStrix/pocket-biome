shader_type canvas_item;
render_mode unshaded;
uniform sampler2D painted_sky : source_color, filter_linear;
uniform sampler2D cloud_noise : repeat_enable, filter_linear;
uniform vec2 cover_scale = vec2(1.0);
uniform float drift = 0.0;
uniform vec4 grade : source_color = vec4(1.0);
uniform vec4 zenith : source_color;
uniform vec4 horizon : source_color;
uniform vec4 cloud_color : source_color;
void fragment() {
 vec2 uv = (UV-vec2(0.5))*cover_scale+vec2(0.5);
 uv += vec2(sin(drift*0.025)*0.002,cos(drift*0.018)*0.001);
 vec3 painted = texture(painted_sky,uv).rgb*grade.rgb;
 float haze = texture(cloud_noise,UV*vec2(1.8,1.1)+vec2(drift*0.003,0.0)).r;
 painted = mix(painted,cloud_color.rgb*grade.rgb,smoothstep(0.65,0.9,haze)*0.055);
 COLOR = vec4(painted,1.0);
}
