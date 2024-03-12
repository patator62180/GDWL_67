shader_type canvas_item;

uniform sampler2D input_texture : filter_nearest;
uniform vec2 speed;
uniform float pixel_scale;
uniform float color_floor;
uniform float grid_size;
uniform vec4 grid_color;

void fragment() {
    vec2 pixelated_uv = (floor(FRAGCOORD.xy/pixel_scale)*pixel_scale)*SCREEN_PIXEL_SIZE;
    vec2 moving_uv = mod((pixelated_uv) + (TIME*speed), 1.0f);
	vec4 color = texture(input_texture, moving_uv);
    COLOR = floor(color*color_floor)/color_floor;
    
    vec2 uv_dist = abs(SCREEN_UV-pixelated_uv);
    if(uv_dist.x < grid_size && uv_dist.y < grid_size){
        COLOR = grid_color;
    }
}