extends Camera2D

class_name Camera

static var instance: Camera

@export var camera_drag : float = 25
@export var shockwave : Shockwave

func _init():
    instance = self
    
func _process(delta):    
    pass
    position = get_local_mouse_position()/camera_drag

func play_shockwave_anim(screen_ratio):
    shockwave.play_shockwave_anim(screen_ratio)
