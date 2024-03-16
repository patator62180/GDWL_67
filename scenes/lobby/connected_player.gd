extends Control

class_name ConnectedPlayer

@export var label: Label
@export var player: Player

var nickname: String = "":
	set(value):
		label.text = value

var color: float = 0:
	set(value):
		player.color = value

