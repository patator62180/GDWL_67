extends Control

class_name ConnectedPlayer

@export var label: Label


var nickname: String = "":
    set(value):
        label.text = value
