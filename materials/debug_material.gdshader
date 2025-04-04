shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Set the color to bright red for the debug mesh
    ALBEDO = vec3(1.0, 0.0, 0.0);  // Red color
    EMISSION = vec3(1.0, 0.0, 0.0);  // Make it glow
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
