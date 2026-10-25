shader_type canvas_item;
render_mode unshaded;
uniform sampler2D cloud_noise : repeat_enable, filter_linear;
uniform float drift = 0.0;
uniform vec4 zenith : source_color = vec4(0.35,0.65,0.76,1.0);
uniform vec4 horizon : source_color = vec4(0.86,0.92,0.85,1.0);
uniform vec4 cloud_color : source_color = vec4(0.96,0.98,0.91,1.0);
float puff(vec2 uv, vec2 center, vec2 span) {
 vec2 d = (uv-center)/span;
 return 1.0-smoothstep(0.45,1.0,dot(d,d));
}
void fragment() {
 vec2 uv = UV;
 vec3 sky = mix(zenith.rgb,horizon.rgb,smoothstep(0.0,1.0,uv.y));
 float light = exp(-length((uv-vec2(0.78,0.22))*vec2(1.1,0.8))*5.0);
 sky += vec3(0.16,0.13,0.07)*light;
 float far_noise = texture(cloud_noise,uv*vec2(0.9,0.8)+vec2(drift*0.004,0.13)).r;
 float near_noise = texture(cloud_noise,uv*vec2(0.7,0.65)-vec2(drift*0.007,0.19)).r;
 float detail = texture(cloud_noise,uv*vec2(3.0,3.5)+vec2(drift*0.002,0.4)).r;
 float wisp = smoothstep(0.68,0.9,far_noise*0.75+detail*0.25);
 float far_bank = smoothstep(-0.04,0.14,uv.y-0.65+(far_noise-0.5)*0.58);
 float near_bank = smoothstep(-0.03,0.09,uv.y-0.86+(near_noise-0.5)*0.66);
 sky = mix(sky,cloud_color.rgb,wisp*0.10+far_bank*0.26+near_bank*0.48);
 float movement = sin(drift*0.012)*0.035;
 float high_cloud = max(puff(uv,vec2(0.06+movement,0.235),vec2(0.32,0.040)),puff(uv,vec2(0.10+movement,0.209),vec2(0.13,0.045)));
 high_cloud = max(high_cloud,puff(uv,vec2(-0.06+movement,0.216),vec2(0.15,0.040)));
 float low_cloud = max(puff(uv,vec2(0.98-movement,0.70),vec2(0.28,0.050)),puff(uv,vec2(0.88-movement,0.675),vec2(0.13,0.048)));
 sky = mix(sky,cloud_color.rgb,high_cloud*0.32+low_cloud*0.38);
 COLOR = vec4(sky,1.0);
}
