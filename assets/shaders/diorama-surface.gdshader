shader_type spatial;
render_mode cull_disabled;
uniform sampler2D grain : source_color, repeat_enable, filter_linear_mipmap;
uniform float clock = 0.0;
uniform float wind = 0.0;
uniform float polish = 0.86;
uniform float glow = 0.0;
uniform float texture_mix = 0.2;
uniform bool foliage = false;
varying vec3 local_position;
void vertex() {
 local_position = VERTEX;
 float strength = max(0.0, VERTEX.y);
 VERTEX.x += sin(clock*1.6 + VERTEX.y*2.5 + VERTEX.z*3.0)*wind*strength;
 VERTEX.z += cos(clock*1.2 + VERTEX.x*3.0)*wind*strength*0.45;
}
void fragment() {
 vec3 painted = texture(grain,UV*1.8).rgb;
 float variation = dot(painted,vec3(0.3,0.55,0.15));
 ALBEDO = pow(COLOR.rgb,vec3(1.6)) * mix(vec3(1.0),painted*1.25,texture_mix);
 if (foliage) ALBEDO = mix(pow(COLOR.rgb,vec3(1.6)),painted*COLOR.rgb/vec3(0.435,0.643,0.302),texture_mix);
 ROUGHNESS = polish;
 EMISSION = COLOR.rgb*glow*(0.75+0.25*sin(clock*1.8+local_position.y*5.0));
}
