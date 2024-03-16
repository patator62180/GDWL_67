shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 global_position;
uniform float force;
uniform float size;
uniform float thickness;

void fragment() {
    vec2 center = global_position;
    //center.x = center.x / SCREEN_PIXEL_SIZE.x;
    //center.y = (SCREEN_PIXEL_SIZE.y - center.y) / SCREEN_PIXEL_SIZE.y;
    
    //float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    //vec2 scaled_UV = ( SCREEN_UV - vec2(0.5, 0.0) ) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
    
    float mask = (1.0 - smoothstep(size - 0.1, size, length(SCREEN_UV - center))) *
            smoothstep(size - thickness - 0.1, size - thickness, length(SCREEN_UV - center));
    
    vec2 disp = normalize(SCREEN_UV - center) * force * mask;
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}