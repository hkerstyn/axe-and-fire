shader_type spatial;
render_mode unshaded;
uniform sampler2D texture2D :source_color, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(texture2D, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
