shader_type canvas_item;

uniform bool enabled=true;
uniform vec4 tint : source_color = vec4(.0001,0.4,0.307,1.0);
uniform bool screen_texture = true;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	if (screen_texture){
    	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV,0.0);
	}else{
		COLOR = texture(TEXTURE, UV);
	}
	if (enabled){
		COLOR.rgb = vec3(COLOR.r*tint.x,COLOR.g*tint.y,COLOR.b*tint.z);
	}
}