shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(1.0,1.0,1.0,1.0);
uniform float amt=.25;
uniform float alpha=1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	float value=random(UV+random(UV*TIME));
	COLOR = mix(vec4(value,value,value,alpha), color1, amt);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
