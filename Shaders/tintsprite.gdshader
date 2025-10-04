shader_type canvas_item;

uniform float amt=.25;
uniform vec4 tint : source_color = vec4(1.0,1.0,1.0,0.0);
uniform float tint_amt=0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	if (texture_color.a>0.0){
    	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV,0.0);
		if (tint_amt>0.0){
			COLOR = mix(COLOR,tint,tint_amt);
		}
		COLOR = mix(texture_color, COLOR, amt);
	}
}
//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
