shader_type spatial;

void vertex() {
	float wave = sin(TIME + VERTEX.x * 2.0) * 0.1;
	
	VERTEX.y += wave;
}

void fragment() {
	// Called for every pixel the material is visible on.
}