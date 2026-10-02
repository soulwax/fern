shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform bool enabled = true;
uniform float grain_amount : hint_range(0.0, 0.2) = 0.042;
uniform float grain_speed : hint_range(0.0, 30.0) = 14.0;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.68;
uniform float vignette_radius : hint_range(0.1, 1.5) = 0.82;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.0022;
uniform float contrast_boost : hint_range(0.8, 1.5) = 1.06;
uniform float sepia_tone : hint_range(0.0, 0.5) = 0.06;

// Pseudo-random noise function for authentic silver halide grain
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	if (!enabled) {
		COLOR = texture(screen_texture, SCREEN_UV);
	} else {
		vec2 uv = SCREEN_UV;
		vec2 center_offset = uv - vec2(0.5);
		float dist = length(center_offset);
		
		// Radial chromatic aberration (stronger towards periphery)
		vec2 ca_offset = vec2(0.0);
		if (dist > 0.0001) {
			ca_offset = (center_offset / dist) * dist * chromatic_aberration;
		}
		float r = texture(screen_texture, uv - ca_offset).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv + ca_offset).b;
		vec3 col = vec3(r, g, b);
		
		// High-frequency animated film grain
		float frame_time = floor(TIME * grain_speed);
		float noise = (hash(uv * 1024.0 + vec2(frame_time, frame_time * 1.618)) - 0.5) * 2.0;
		col += noise * grain_amount;
		
		// Contrast adjustment (deepening blacks, rich chiaroscuro)
		col = pow(max(col, vec3(0.0)), vec3(contrast_boost));
		
		// Subtle 19th-century daguerreotype silver/charcoal patina
		float luma = dot(col, vec3(0.299, 0.587, 0.114));
		vec3 sepia_col = vec3(luma * 1.08, luma * 0.98, luma * 0.88);
		col = mix(col, sepia_col, sepia_tone);
		
		// Smooth radial vignette
		float vig = smoothstep(vignette_radius, vignette_radius - 0.45, dist);
		col *= mix(1.0 - vignette_intensity, 1.0, vig);
		
		COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
	}
}
