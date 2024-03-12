extends CanvasLayer

class_name Shockwave

@export var shockwave_player: AnimationPlayer
@export var shockwave_shader: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func play_shockwave_anim(screen_ratio: Vector2):
    shockwave_shader.material.set_shader_parameter("global_position", screen_ratio)
    shockwave_player.play("shockwave")
