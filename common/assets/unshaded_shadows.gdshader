shader_type spatial;
render_mode ambient_light_disabled;

#include "res://common/assets/utility.gdshaderinc"

uniform vec3 color : source_color;

void vertex() {
	
}

void fragment() {
	ALBEDO = color;
	ROUGHNESS = 0.0;
}

void light() {
	DIFFUSE_LIGHT = vec3(ATTENUATION);
}
