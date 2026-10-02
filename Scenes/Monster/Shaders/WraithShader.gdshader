shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float reveal_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 bark_color : source_color = vec4(0.08, 0.07, 0.06, 1.0);
uniform vec4 glow_color : source_color = vec4(0.45, 0.7, 1.0, 1.0);
uniform vec4 ember_color : source_color = vec4(1.0, 0.45, 0.1, 1.0);
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.025;

void fragment() {
	// Base UV coordinates
	vec2 screen_uv = SCREEN_UV;
	
	// Refractive distortion wave
	float wave = sin(TIME * 3.5 + VERTEX.y * 5.0) * cos(TIME * 2.8 + VERTEX.x * 4.0);
	vec2 offset = vec2(wave, -wave) * distortion_strength * (1.0 - reveal_amount * 0.7);
	
	vec4 bg = texture(screen_texture, screen_uv + offset);
	
	// Fresnel rim glow
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	
	// Color blending
	vec3 revealed_albedo = mix(bark_color.rgb, glow_color.rgb * 1.5, fresnel * 0.7);
	vec3 final_color = mix(bg.rgb, revealed_albedo, reveal_amount);
	
	ALBEDO = final_color;
	EMISSION = glow_color.rgb * fresnel * reveal_amount * 2.5;
	ROUGHNESS = 0.65;
	METALLIC = 0.1;
}
