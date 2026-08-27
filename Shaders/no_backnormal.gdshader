shader_type canvas_item;

void light() {
	float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	LIGHT += LIGHT_COLOR * COLOR * cNdotL * LIGHT_ENERGY;
}
