shader_type canvas_item;

uniform sampler2D input_texture;
uniform vec2 speed;
uniform float zoom;

void fragment() {
    float uvx = mod((UV.x/zoom) + (TIME*speed.x), 1.0f);
    float uvy = mod((UV.y/zoom) + (TIME*speed.y), 1.0f);
	COLOR = texture(input_texture, vec2(uvx, uvy));
}