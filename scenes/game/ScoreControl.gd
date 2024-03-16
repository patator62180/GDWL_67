extends Control

class_name ScoreControl

@export var scoreObjectif = 3
@export var score_label_j1 : Label
@export var score_label_j2 : Label

var score_j1 = 0
var score_j2 = 0

signal scoreAtteint

func _ready():
    if not OS.has_feature('dedicated_server'):
        score_label_j1.material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[0].modulateFaceColor)
        score_label_j2.material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[1].modulateFaceColor)


func _on_game_p_1_scored():
    score_j1+=1 
    score_label_j1.text = "Player 1: " + str(score_j1) + " points"
    if score_j1==scoreObjectif:
        emit_signal("scoreAtteint")
    
func _on_game_p_2_scored():
    score_j2+=1
    score_label_j2.text = "Player 2: " + str(score_j2) + " points"
    if score_j2==scoreObjectif:
        emit_signal("scoreAtteint")
