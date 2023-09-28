shader_type canvas_item;

// Uniforms for screen dimensions and settings
uniform float screen_width = 1024;
uniform float screen_height = 600;

// Curvature settings
uniform float BarrelPower = 1.1;
uniform float dynamic_curvature : hint_range(0.0, 2.0) = 1.0; // Dynamic control for curvature

// Color bleeding settings
uniform float color_bleeding = 1.2;
uniform float bleeding_range_x = 3;
uniform float bleeding_range_y = 3;

// Scanline settings
uniform float lines_distance = 4.0;
uniform float scan_size = 2.0;
uniform float scanline_alpha = 0.9;
uniform float lines_velocity = 30.0;

// Noise settings
uniform float noise_intensity = 0.1;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Function for barrel distortion
vec2 distort(vec2 p) 
{
    float angle = p.y / p.x;
    float theta = atan(p.y, p.x);
    float radius = pow(length(p), BarrelPower * dynamic_curvature);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    return 0.5 * (p + vec2(1.0, 1.0));
}

// Function for color bleeding effect
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

// Function for scanline effect
void get_color_scanline(vec2 uv, inout vec4 c, float time)
{
    float line_row = floor((uv.y * screen_height / scan_size) + mod(time * lines_velocity, lines_distance));
    float n = 1.0 - ceil((mod(line_row, lines_distance) / lines_distance));
    c = c - n * c * (1.0 - scanline_alpha);
    c.a = 1.0;
}

// Main fragment shader function
void fragment()
{
    vec2 xy = SCREEN_UV * 2.0 - vec2(1.0, 1.0);
    float d = length(xy);
    if (d < 1.5) {
        xy = distort(xy);
    } else {
        xy = SCREEN_UV;
    }
    float pixel_size_x = 1.0 / screen_width * bleeding_range_x;
    float pixel_size_y = 1.0 / screen_height * bleeding_range_y;
    vec4 current_color = texture(SCREEN_TEXTURE, xy);
    get_advanced_color_bleeding(current_color, xy, pixel_size_x, pixel_size_y);
    vec4 c = current_color;
    
    // Adding noise for CRT static
    float noise = noise_intensity * fract(sin(dot(xy, vec2(12.9898, 78.233))) * 43758.5453);
    c.rgb += noise;
    
    get_color_scanline(xy, c, TIME);
    COLOR = c;
}
