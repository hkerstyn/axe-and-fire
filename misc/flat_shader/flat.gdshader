shader_type spatial;
uniform sampler2D sunLit : source_color;
uniform sampler2D lampLit : source_color;
uniform sampler2D unLit : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
}

void light() {
	bool lightHits = (ATTENUATION > 0.0f);
	if(!lightHits)
		if(DIFFUSE_LIGHT == vec3(0.0f))
			DIFFUSE_LIGHT = texture(unLit, UV).rgb;
	
	if(lightHits && LIGHT_IS_DIRECTIONAL)
		if(DIFFUSE_LIGHT == vec3(0.0f) 
		|| DIFFUSE_LIGHT == texture(unLit, UV).rgb)
			DIFFUSE_LIGHT = texture(sunLit, UV).rgb;
	
	if(lightHits && !LIGHT_IS_DIRECTIONAL)
		DIFFUSE_LIGHT = texture(lampLit, UV).rgb;


}
