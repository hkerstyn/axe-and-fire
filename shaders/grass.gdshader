shader_type spatial;
uniform vec3 player_position;
uniform vec3 player_velocity;
uniform sampler2D perlin_noise;

#include "flat.gdshaderinc"

float wave(float x) {
 	return sin(x) + 0.5*sin(x/2.) + 0.1*sin(x/5.-1.);
}

void vertex() {
	vec3 global_positon = NODE_POSITION_WORLD+VERTEX;
	float d = distance(global_positon, player_position);
	vec3 dir = normalize(global_positon-player_position);
	
	float h = VERTEX.y;
	float factor = 3.0 * exp( -d);
	VERTEX.xz += 0. *factor* dir.xz*h;
	
	
	VERTEX.xz += 0. * vec2(cos(TIME-global_positon.x*global_positon.z),
	 sin(TIME-global_positon.x*global_positon.z));
}