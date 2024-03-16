extends Control

class_name ScoreControl

@export var scoreObjectif = 3
@export var score_label_j1 : Label
@export var score_label_j2 : Label

signal scoreAtteint

func _ready():
    if not OS.has_feature('dedicated_server'):
        score_label_j1.material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[0].modulateFaceColor)
        score_label_j2.material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[1].modulateFaceColor)


func on_player_scored(index : int, score : int):
    if(index == 0):
        score_label_j1.text = "Player 1: " + str(score) + " points"
    else:
        score_label_j2.text = "Player 2: " + str(score) + " points"   
