extends Sprite2D

func _process(delta):
    if PlayerController.instance == null:
        material.set_shader_parameter("tint_color", Color(1,1,1,1))
    elif  PlayerController.instance.can_play() and not OS.has_feature('dedicated_server'):
        material.set_shader_parameter("tint_color", Color(1,1,1,1))
    else:
        material.set_shader_parameter("tint_color", Color(1,0.3,0.3,1))
