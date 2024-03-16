extends Camera2D

@export var camera_drag : float = 25
@export var shockwave : Shockwave


func _process(delta):    
    position = get_local_mouse_position()/camera_drag

func play_shockwave_anim(screen_ratio):
    shockwave.play_shockwave_anim(screen_ratio)
