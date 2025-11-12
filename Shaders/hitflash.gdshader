shader_type canvas_item;

uniform vec4 flash_color : source_color;
uniform float alpha = 1.0;
uniform float flash_value : hint_range(0.0, 1.0, 0.1) = 0;
uniform float no_normal : hint_range(0.0,1.0) = 1.0;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    COLOR = mix(texture_color, flash_color, flash_value);
	if (flash_value==1.0){
		COLOR*=100.0;
	}
    COLOR.a = texture_color.a;
	if (flash_value==0.0){
		COLOR.a*=alpha;
		NORMAL=vec3(0.0,0.0,1.0);
	}
	else{
		NORMAL=vec3(0.0,0.0,-1.0);
	}
}

void light() {
	if (NORMAL==vec3(0.0,0.0,-1.0)){
		LIGHT=vec4(1.0,1.0,1.0,1.0);
	}
	else{
		float cNdotL = max(no_normal, dot(NORMAL, LIGHT_DIRECTION));
		LIGHT = LIGHT_COLOR * COLOR * cNdotL * LIGHT_ENERGY;
	}
}