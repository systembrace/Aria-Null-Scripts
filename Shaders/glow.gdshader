shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform float intensity;
uniform float opacity;
uniform vec4 glow_color : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Get the pixel color from the texture
	vec4 pixel_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// Calculate the distance between the pixel color and the first source color
	float distance = length(pixel_color - color1);
	
	
	// Create a new variable to store the modified glow color
	//vec4 modified_glow_color = glow_color;
	
	// Set the alpha value of the modified glow color to the specified opacity
	//modified_glow_color.a = opacity;
	
	// If the distance to either source color is below the threshold, set the output color to a blend of the pixel color and the modified glow color
	if (distance<.2) {
		COLOR = glow_color*vec4(2,2,2,1);
	}
	// Otherwise, set the output color to the pixel color
	else {
		COLOR = pixel_color;
	}
}