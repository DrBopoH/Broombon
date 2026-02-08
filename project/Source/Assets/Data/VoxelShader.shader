shader_type spatial;

render_mode blend_mix, depth_draw_alpha_prepass, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2DArray texture_array : hint_albedo;

void vertex() {
}

void fragment() {
	float texture_index = round(COLOR.r * 255.0);
	vec4 albedo_tex = texture(texture_array, vec3(UV, texture_index));
	
	ALBEDO = albedo_tex.rgb;
	
	if (albedo_tex.a < 0.5) {
		discard;
	}
	
	ALPHA = 1.0;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
}