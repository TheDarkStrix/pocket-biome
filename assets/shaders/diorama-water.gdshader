shader_type spatial;
render_mode cull_disabled;
uniform float clock = 0.0;
uniform vec4 water_color : source_color = vec4(0.07,0.55,0.65,1.0);
varying vec3 surface_position;
void vertex(){surface_position=VERTEX;VERTEX.y+=sin(clock*2.0+VERTEX.x*13.0+VERTEX.z*8.0)*0.006;}
void fragment(){
 float ripples=sin(surface_position.x*26.0+surface_position.z*17.0-clock*2.3)*sin(surface_position.z*21.0-surface_position.x*11.0+clock*1.5);
 float caustics=pow(max(0.0,ripples),5.0);
 ALBEDO=water_color.rgb*COLOR.rgb+vec3(0.22,0.34,0.27)*caustics;
 ROUGHNESS=0.2;METALLIC=0.12;
 NORMAL=normalize(NORMAL+vec3(sin(surface_position.x*17.0-clock*1.8)*0.07,cos(surface_position.z*18.0+clock)*0.07,0.0));
}
