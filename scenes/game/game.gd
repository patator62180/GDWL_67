extends Node2D

func _ready():
    pass


func _process(delta):
    if multiplayer and not multiplayer.is_server() and Input.is_action_just_pressed("left"):
        print('left')
