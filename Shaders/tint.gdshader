shader_type canvas_item;

uniform bool enabled=true;
uniform vec4 tint : source_color = vec4(.0001,0.4,0.307,1.0);
uniform bool screen_texture = true;
uniform float glitch = -1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

float randomvec (vec2 uv) {
    return fract(sin(dot(uv,
        vec2(12.9898,78.233))) * 43758.5453123);
}

float random (float seed) {
    return randomvec(vec2(seed,seed));
}

void fragment() {
	vec2 uv = SCREEN_UV;
	if (!screen_texture){
		uv=UV;
	}
	if (glitch>0.0){
		float r = trunc(random(TIME)*32.0)+32.0;
		uv.x+=random(trunc(UV.y*r)/r+trunc(TIME*12.0))/2.0*glitch-.25*glitch;
	}
	if (screen_texture){
    	COLOR = textureLod(SCREEN_TEXTURE, uv,0.0);
	}else{
		COLOR = texture(TEXTURE, uv);
	}
	if (enabled){
		COLOR.rgb = vec3(COLOR.r*tint.x,COLOR.g*tint.y,COLOR.b*tint.z);
	}
	if (glitch>0.0){
		float value=randomvec(uv.xy+randomvec(uv.xy*TIME))*glitch;
		COLOR = mix(vec4(value,value,value,.5),COLOR,.85);
	}
}