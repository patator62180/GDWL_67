extends Node2D

class_name ConfettiLauncher

@export var left_confetti : CPUParticles2D
@export var right_confetti : CPUParticles2D


func on_game_finished(is_winning : bool):
    if(is_winning):
        fire_confetti()

func fire_confetti():
    left_confetti.emitting = true
    right_confetti.emitting = true
