extends Control

@export var scoreJ1 = 0
@export var scoreJ2 = 0

func _ready():
    %"Score J1".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[0].modulateFaceColor)
    %"Score J1".text = "Player 1: " + str(scoreJ1) + " points"
    %"Score J2".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[1].modulateFaceColor)
    %"Score J2".text = "Player 2: " + str(scoreJ2) + " points"
