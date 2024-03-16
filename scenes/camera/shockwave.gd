extends CanvasLayer

class_name Shockwave

@export var shockwave_player: AnimationPlayer
@export var shockwave_shader: ColorRect

func play_shockwave_anim(screen_ratio: Vector2):
    if not OS.has_feature('dedicated_server'):
        shockwave_shader.material.set_shader_parameter("global_position", screen_ratio)
    shockwave_player.play("shockwave")
