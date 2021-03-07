//This shader assigns the mesh's color based on it's UVs and the palette texture.

shader_type spatial;

const float PI = 3.14159265359;

uniform sampler2D palette_tex:hint_albedo;
uniform float tex_size = 16.0;


uniform sampler2D dithering_matrix_tex : hint_albedo; //The dithering matrix pattern to look up. Must be a square texture.
uniform float dithering_matrix_size = 8.0; //The size of the dithering matrix. The default is an 8x8 texture.

//Takes in coordinate in pixels and returns what it's corresponding matrix value is.
float index_value(vec2 pixel_coord){
	float x = mod(pixel_coord.x, dithering_matrix_size);
	float y = mod(pixel_coord.y, dithering_matrix_size);
	return texture(dithering_matrix_tex, vec2(x, y) / dithering_matrix_size).r;
}

float linear_to_srgb(float linear){
	if(linear > 0.0031308){
		return 1.055 * (pow(linear, (1.0 / 2.4))) - 0.055;
	}else{
		return 12.92 * linear;
	}
}

vec3 linear_vec_to_srgb(vec3 l){
	return vec3(linear_to_srgb(l.r), linear_to_srgb(l.g), linear_to_srgb(l.b));
}

void fragment(){
	ALBEDO = texture(palette_tex, UV).rgb;
	
	//AO gets set to 0 so the lighting has full control over the final output color.
	AO = 0.0;
}

//Takes in the light color, normalizes it, and uses it's R value as an index between 0-1 to sample the palette.
//This is why a custom script is used for each light, so that the R value represents the correct index.
//The light color must be converted when using GLES3, as it uses linear space and not srgb
vec3 parse_light_color(vec3 light_color, bool srgb){
	float d = 0.0;
	
	if(!srgb){
		light_color = linear_vec_to_srgb(light_color);
	}
	
	d = (normalize(light_color)).r;
	
	//A small buffer is added when sampling the texture, so we avoid weird behavior when sampling edges.
	return texture(palette_tex, vec2(d + (1.0 / (tex_size * 2.0)), 0.0)).rgb;
}

void light(){
	float NdotL = dot(NORMAL, LIGHT);
	float atten = (1.0 - ATTENUATION.b); //Inverse the Attenuation for the light dispersal function
	float energy = length(LIGHT_COLOR) / 32.0; //Brings the energy of the light to a range between 0 and 1, assuming the light is > 0 and < 16
	
	bool unwritten = DIFFUSE_LIGHT == vec3(0.0);
	bool shadow = DIFFUSE_LIGHT == vec3(-1.0);
	
	if(energy == 0.0){
		DIFFUSE_LIGHT = vec3(-1.0); //If energy is zero, the light isn't shining. Setting this to shadow allows a work around to a problem where solo spotlights won't fully shade things outside of it's attenuation.
		return;
	}
	
	float diff;
	
	if((NdotL < 0.0 || ATTENUATION.b == 0.0)){
		diff = abs(NdotL);
		vec3 col_under = unwritten ? ALBEDO : DIFFUSE_LIGHT; //Only uses Albedo if another light hasn't written to this pixel yet.
		vec3 col_up = unwritten ? vec3(-1.0) : DIFFUSE_LIGHT; //Sets the shadow color to -1.0. It looks the same as black, however, it allows other lights to distinguish between an unwritten pixel and a shaded pixel.
		
		vec3 c = diff >= index_value(FRAGCOORD.xy) ? col_up : col_under; //Dither depending on the normal.
		DIFFUSE_LIGHT += c - DIFFUSE_LIGHT; //I've had issues in the past where just overwriting the diffuse gave weird behavior, but this seems to work well.
	}else{
		vec3 light_col = parse_light_color(LIGHT_COLOR, OUTPUT_IS_SRGB); //The light being passed to the shader is actually data containing the index and the energy of the light, so we don't want the light color itself.
		
		diff = 1.0 - (NdotL);
		diff = diff + (atten * NdotL) - ((energy - 1.0) * NdotL); //Take into account the normal, attenuation, and energy of the light for it's overall strength.
		
		if(diff > 1.0){
			diff = diff - 1.0;
			vec3 col_under = unwritten ? ALBEDO : DIFFUSE_LIGHT;
			vec3 col_up = unwritten ? vec3(-1.0) : DIFFUSE_LIGHT;
			vec3 c = diff >= index_value(FRAGCOORD.xy) ? col_up : col_under;
			DIFFUSE_LIGHT += c - DIFFUSE_LIGHT;
		}else{
			vec3 col_under = unwritten || shadow ? ALBEDO : DIFFUSE_LIGHT;
			vec3 c = diff <= index_value(FRAGCOORD.xy) ? light_col : col_under;
			DIFFUSE_LIGHT += c - DIFFUSE_LIGHT;
		}
	}
}