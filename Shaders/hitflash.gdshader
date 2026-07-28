shader_type canvas_item;

uniform vec4 flash_color : source_color;
uniform float alpha = 1.0;
uniform float flash_value : hint_range(0.0, 1.0, 0.1) = 0;
uniform float no_normal : hint_range(0.0,1.0) = 1.0;
uniform vec4 tint_color : source_color;
uniform float tint_amt : hint_range(0.0, 1.0, 0.1) = 0;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    COLOR = mix(texture_color, flash_color, flash_value);
	if (flash_value==1.0){
		COLOR*=100.0;
	}
	if (flash_value==0.0){
		if (COLOR.a>0.0){
			COLOR = mix(COLOR, tint_color, tint_amt);
		}
	}
	COLOR.a = texture_color.a * alpha;
}

void light() {
	if (flash_value!=0.0){
		LIGHT=vec4(1.0,1.0,1.0,1.0);
	}
	else{
		//vec4 true_color=texture(TEXTURE, UV);
		//vec4 diff = true_color - COLOR;
		float cNdotL = max(no_normal, dot(NORMAL, LIGHT_DIRECTION));
		LIGHT += LIGHT_COLOR * COLOR * cNdotL * LIGHT_ENERGY;
		//LIGHT.a*=0.25;
		//if (LIGHT.r>diff.r){
			//LIGHT.r=diff.r;
		//}
		//if (LIGHT.g>diff.g){
			//LIGHT.g=diff.g;
		//}
		//if (LIGHT.b>diff.b){
			//LIGHT.b=diff.b;
		//}
	}
}