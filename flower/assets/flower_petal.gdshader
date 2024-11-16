shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert_wrap, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01) = 1.0;

uniform vec2 uv1_scale = vec2(1.0);
uniform vec2 uv1_offset = vec2(0.0);


uniform vec2 grab_mouse_position;
uniform vec2 deform;

varying vec3 view_pos;
varying vec2 screen_pos;

vec2 get_uv_from_view_position(vec3 position_view, mat4 proj_m)
{
	vec4 position_cs = proj_m * vec4(position_view.xyz, 1.0);
	vec2 ndc = position_cs.xy / position_cs.w;
	return ndc.xy * 0.5 + 0.5;
}

vec3 get_view_position_from_uv(vec2 uv, float depth, mat4 inv_proj_m)
{
	vec4 ndc = vec4((uv * 2.0) - 1.0, depth, 1.0);
	vec4 view_p = inv_proj_m * ndc;
	return view_p.xyw / view_p.w;
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	view_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	screen_pos = get_uv_from_view_position(view_pos, PROJECTION_MATRIX);

	float dist_to_mouse = length(screen_pos - grab_mouse_position);
	dist_to_mouse = smoothstep(0.2, 0.0, dist_to_mouse);

	vec2 deformed_view_pos = view_pos.xy + deform * dist_to_mouse;

	VERTEX = (inverse(MODELVIEW_MATRIX) * vec4(deformed_view_pos.x, deformed_view_pos.y, view_pos.z, 1.0)).xyz;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	//ALBEDO = vec3(dist_to_mouse / 1.0);
	//ALBEDO = fract(vec3(screen_pos.x, screen_pos.y, 0.0));

	ROUGHNESS = 1.0;

	float dist_to_mouse = length(screen_pos - grab_mouse_position);
	dist_to_mouse = smoothstep(0.075, 0.0, dist_to_mouse);

	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	EMISSION = (emission.rgb + emission_tex) * emission_energy * dist_to_mouse;
}
