extends Control

var scoreJ1 = 0
var scoreJ2 = 0
@export var scoreObjectif = 3

signal scoreAtteint

func _ready():
    %"Score J1".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[0].modulateFaceColor)
    %"Score J2".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[1].modulateFaceColor)



func _on_game_p_1_scored():
    scoreJ1+=1 
    %"Score J1".text = "Player 1: " + str(scoreJ1) + " points"
    if scoreJ1==scoreObjectif:
        emit_signal("scoreAtteint")
    
func _on_game_p_2_scored():
    scoreJ2+=1
    %"Score J2".text = "Player 2: " + str(scoreJ2) + " points"
    if scoreJ2==scoreObjectif:
        emit_signal("scoreAtteint")
