shader_type canvas_item;

uniform vec3 tint = vec3(.0001,0.4,0.307);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV,0.0);
	COLOR.rgb = vec3(COLOR.r*tint.x,COLOR.g*tint.y,COLOR.b*tint.z);
}