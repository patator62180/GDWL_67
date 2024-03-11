shader_type canvas_item;

uniform sampler2D input_texture : filter_nearest;
uniform sampler2D input_texture_dot : filter_nearest;
uniform vec2 speed;
uniform float pixel_scale;
uniform float color_floor;

void fragment() {
    vec2 pixelated_uv = (floor(FRAGCOORD.xy/pixel_scale)*pixel_scale)*SCREEN_PIXEL_SIZE;
    float uvx = mod((pixelated_uv.x) + (TIME*speed.x), 1.0f);
    float uvy = mod((pixelated_uv.y) + (TIME*speed.y), 1.0f);
	vec4 color = texture(input_texture, vec2(uvx, uvy));
    COLOR = floor(color*color_floor)/color_floor;
    COLOR = texture(input_texture_dot, UV);
}