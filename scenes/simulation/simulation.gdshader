shader_type canvas_item;

const uint AGENT_COUNT = 4u;
const float MOVE_SPEED = 1.0;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2[AGENT_COUNT] positions;
uniform float[AGENT_COUNT] rotations;
uniform float delta_time;
uniform float height;
uniform float width;

uint hash(uint seed){
    seed ^= 2747636419u;
    seed *= 2654435769u;
    seed ^= seed >> 16u;
    seed *= 2654435769u;
    seed ^= seed >> 16u;
    seed *= 2654435769u;
    return seed;
}

float random(uint seed){
    seed = hash(seed);
    return float(seed)/4294967295.0;    
}

void fragment() {    
    uint pixelId = uint(FRAGCOORD.x * (1.0/SCREEN_PIXEL_SIZE.x) + FRAGCOORD.y);
    if(pixelId <= AGENT_COUNT){
        vec2 position = positions[pixelId];
        float rotation = rotations[pixelId]; 
        
        vec2 direction = vec2(cos(rotation), sin(rotation));
        position = position + direction * MOVE_SPEED * delta_time;
        
        if(position.x < 0.0 || position.x >= width || position.y < 0.0 || position.y >= height){
            position.x = min(width-0.01, max(0, position.x));
            position.y = min(height-0.01, max(0, position.y));
            rotation = random(pixelId) * 2.0 * PI;
        }
        
        positions[pixelId] = position;
        rotations[pixelId] = rotation;
    }    
    
    COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
    for(uint i = 0u; i< AGENT_COUNT; i++){
        if(positions[i].x == FRAGCOORD.x && positions[i].y == FRAGCOORD.y){
            COLOR.rgb = vec3(1.0);
        }
    }
    
}