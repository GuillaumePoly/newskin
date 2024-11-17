shader_type canvas_item;

uniform vec3 color : source_color = vec3(0.0);
uniform float fade : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform vec2 focus_coord = vec2(0.5);

void fragment() {
	vec2 base_uv = UV;
	base_uv = base_uv - focus_coord;
	base_uv = base_uv * vec2(SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x, 1.0) * 0.25;

	float circle = length(base_uv);
	circle = smoothstep(fade - 0.05, fade, circle);

	COLOR = vec4(color, circle);
}
