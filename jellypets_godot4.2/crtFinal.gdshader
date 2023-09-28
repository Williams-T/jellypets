shader_type canvas_item;

//updated

uniform float screen_width = 1024;
uniform float screen_height = 600;

// Curvature
uniform float BarrelPower =1.1;
uniform float dynamic_curvature : hint_range(0.0, 2.0) = 1.0; // Dynamic control for curvature


// Color bleeding
uniform float color_bleeding = 1.2;
uniform float bleeding_range_x = 3.0;
uniform float bleeding_range_y = 3.0;
// Scanline
uniform float lines_distance = 4.0;
uniform float scan_size = 2.0;
uniform float scanline_alpha = 0.9;
uniform float lines_velocity = 30.0;

// Noise settings
uniform float noise_intensity = 0.1;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec2 distort(vec2 p) 
{
	float angle = p.y / p.x;
	float theta = atan(p.y,p.x);
	//float radius = pow(length(p), BarrelPower);
	float radius = pow(length(p), BarrelPower * dynamic_curvature);
	p.x = radius * cos(theta);
	p.y = radius * sin(theta);
	
	return 0.5 * (p + vec2(1.0,1.0));
}

/*void get_color_bleeding(inout vec4 current_color,inout vec4 color_left){
	current_color = current_color*vec4(color_bleeding,0.5,1.0-color_bleeding,1);
	color_left = color_left*vec4(1.0-color_bleeding,0.5,color_bleeding,1);
}
*/

/* Function for color bleeding effect
void get_advanced_color_bleeding(inout vec4 current_color, vec2 xy, float pixel_size_x, float pixel_size_y)
{
    vec4 total_color = vec4(0.0, 0.0, 0.0, 0.0);
    for (float x = -bleeding_range_x; x <= bleeding_range_x; x += pixel_size_x) {
        for (float y = -bleeding_range_y; y <= bleeding_range_y; y += pixel_size_y) {
            vec4 sample_color = texture(SCREEN_TEXTURE, xy + vec2(x, y));
            total_color += sample_color;
        }
    }
    total_color /= (2.0 * bleeding_range_x / pixel_size_x + 1.0) * (2.0 * bleeding_range_y / pixel_size_y + 1.0);
    current_color = mix(current_color, total_color, color_bleeding);
}
*/
//new version
void get_advanced_color_bleeding(inout vec4 current_color, vec2 xy, float pixel_size_x, float pixel_size_y)
{
    vec4 total_color = vec4(0.0, 0.0, 0.0, 0.0);
    total_color += texture(SCREEN_TEXTURE, xy + vec2(-pixel_size_x, -pixel_size_y));
    total_color += texture(SCREEN_TEXTURE, xy + vec2( pixel_size_x, -pixel_size_y));
    total_color += texture(SCREEN_TEXTURE, xy + vec2(-pixel_size_x,  pixel_size_y));
    total_color += texture(SCREEN_TEXTURE, xy + vec2( pixel_size_x,  pixel_size_y));
    total_color *= 0.25;
    current_color = mix(current_color, total_color, color_bleeding);
}


void get_color_scanline(vec2 uv,inout vec4 c,float time){
	float line_row = floor((uv.y * screen_height/scan_size) + mod(time*lines_velocity, lines_distance));
	float n = 1.0 - ceil((mod(line_row,lines_distance)/lines_distance));
	c = c - n*c*(1.0 - scanline_alpha);
	c.a = 1.0;
}
// Function to generate grainy, Risograph-like noise
float generate_riso_noise(vec2 uv, float scale, float intensity) {
    // Create a more complex pattern by combining sin and cos functions
    float pattern = sin(uv.x * scale * 3.14159) * cos(uv.y * scale * 3.14159);
    
    // Mix it with a basic fractal noise
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    
    // Combine the pattern and noise to create the final Risograph-like texture
    float riso_noise = mix(pattern, noise, 0.5);
    
    return riso_noise * intensity;
}
void fragment()
{
	vec2 xy = SCREEN_UV * 2.0;
	xy.x -= 1.0;
	xy.y -= 1.0;
	
	float d = length(xy);
	if(d < 1.5){
		xy = distort(xy);
	}
	else{
		xy = SCREEN_UV;
	}
	
	float pixel_size_x = 1.0/screen_width*bleeding_range_x;
	float pixel_size_y = 1.0/screen_height*bleeding_range_y;
	//vec4 color_left = texture(SCREEN_TEXTURE,xy - vec2(pixel_size_x, pixel_size_y));
	vec4 current_color = texture(SCREEN_TEXTURE,xy);
	//get_color_bleeding(current_color,color_left);
	//vec4 c = current_color+color_left;
	get_advanced_color_bleeding(current_color, xy, pixel_size_x, pixel_size_y);
    vec4 c = current_color;
	
	get_color_scanline(xy,c,TIME);
	COLOR = c;

}