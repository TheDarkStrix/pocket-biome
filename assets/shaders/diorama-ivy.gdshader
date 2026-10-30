shader_type spatial;
render_mode unshaded,cull_disabled,depth_prepass_alpha;
uniform sampler2D ivy_texture:source_color,filter_linear_mipmap;
uniform float clock=0.0;
void vertex(){VERTEX.x+=sin(clock*0.9+VERTEX.z*3.0)*0.012*clamp(-VERTEX.y,0.0,1.0);}
void fragment(){vec4 vine=texture(ivy_texture,UV);ALBEDO=vine.rgb;ALPHA=vine.a;}
