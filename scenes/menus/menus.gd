extends Node2D

@export var choices_screen: Control

func _ready():
    choices_screen.visible = true

func _process(delta):
    get_node("CanvasLayer/Viewport/GameTitle").position = (get_local_mouse_position())/25 + Vector2(208,71)
    get_node("CanvasLayer/Viewport/GameTitleShadow").position = (get_local_mouse_position())/60 + Vector2(585,210)
