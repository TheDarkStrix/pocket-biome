shader_type canvas_item;
render_mode unshaded;
uniform float flow_clock = 0.0;
varying vec4 strand_color;
void vertex() {
 strand_color = COLOR;
}
void fragment() {
 vec2 uv = UV;
 uv.x += sin(uv.y*31.0-flow_clock*3.2)*0.006*sin(uv.y*3.14159265);
 vec4 painted = texture(TEXTURE,uv);
 float streak = texture(TEXTURE,vec2(uv.x,fract(uv.y-flow_clock*0.23))).g;
 painted.rgb *= 0.91+0.16*streak;
 COLOR = painted*strand_color;
}
