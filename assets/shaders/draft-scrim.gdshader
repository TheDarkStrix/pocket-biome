shader_type canvas_item;
render_mode unshaded;
void fragment() {
 float shade = mix(0.22, 0.88, smoothstep(0.12, 0.72, UV.y));
 COLOR = vec4(0.025, 0.045, 0.05, shade);
}
