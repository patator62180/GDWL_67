extends Control

class_name PlayerCard

@export var nickname_label: Label
@export var score_label: Label

var nickname: String = '':
    set(value):
        nickname_label.text = value

var score: int = 0:
    set(value):
        score_label.text = 'Points: %d' % value

var color: float = 0:
    set(value):
        if not OS.has_feature('dedicated_server'):
            nickname_label.material.set_shader_parameter("Shift_Hue", value)
            score_label.material.set_shader_parameter("Shift_Hue", value)

func _ready():
    score = 0
