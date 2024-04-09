uniform sampler2D sunlit : source_color;
uniform sampler2D lamplit : source_color;
uniform sampler2D unlit : source_color;

void light() {
	bool lightHits = (ATTENUATION > 0.0f);
	if(!lightHits)
		if(DIFFUSE_LIGHT == vec3(0.0f))
			DIFFUSE_LIGHT = texture(unlit, UV).rgb;
	
	if(lightHits && LIGHT_IS_DIRECTIONAL)
		if(DIFFUSE_LIGHT == vec3(0.0f) 
		|| DIFFUSE_LIGHT == texture(unlit, UV).rgb)
			DIFFUSE_LIGHT = texture(sunlit, UV).rgb;
	
	if(lightHits && !LIGHT_IS_DIRECTIONAL)
		DIFFUSE_LIGHT = texture(lamplit, UV).rgb;
}
