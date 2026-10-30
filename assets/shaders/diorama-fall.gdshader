shader_type spatial;
render_mode unshaded,cull_disabled,depth_prepass_alpha;
uniform sampler2D flow_texture : source_color,filter_linear_mipmap;
uniform float clock=0.0;
void fragment(){
 vec2 uv=UV;uv.x+=sin(uv.y*11.0+clock*1.4)*0.008;
 vec4 painted=texture(flow_texture,uv);
 float strands=0.87+0.13*sin(uv.y*95.0-clock*8.0+sin(uv.x*26.0));
 ALBEDO=painted.rgb*strands;ALPHA=painted.a*0.88;
}
