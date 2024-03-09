extends Node2D

const GAME_NAME = 'parasite'

@export var create_button: Button
@export var join_button: Button
@export var join_room_code: TextEdit
@export var game_scene: PackedScene


func _ready():
    create_button.pressed.connect(create_game_room)
    join_button.pressed.connect(join_game_room)


func create_game_room():
    Immersive.client.book_game_room(GAME_NAME)

    
func join_game_room():
    Immersive.client.join_game_room(join_room_code.text)
