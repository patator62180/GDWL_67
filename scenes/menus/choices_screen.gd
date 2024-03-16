extends Control

const GAME_NAME = 'parasite'

@export var create_button: Button
@export var join_button: Button
@export var play_local_button: Button
@export var join_room_code: TextEdit
@export var game_scene: PackedScene
@export var node_to_replace: Node

func _ready():
    Immersive.client.joined.connect(on_game_room_joined)
    
    create_button.pressed.connect(create_game_room)
    join_button.pressed.connect(join_game_room)
    play_local_button.pressed.connect(on_play_local)

func on_play_local():
    var game = game_scene.instantiate()
    
    Mediator.instance.is_couch = true
    node_to_replace.get_parent().add_child(game)
    node_to_replace.queue_free()

func on_game_room_joined(game_room_code: String, client_id: int):
    Mediator.instance.is_couch = false
    Immersive.client.joined.disconnect(on_game_room_joined)
    var game = game_scene.instantiate()
    node_to_replace.get_parent().add_child(game)
    node_to_replace.queue_free()
    game.player_controller.lobby.initialize(game_room_code)

func create_game_room():
    Immersive.client.book_game_room(GAME_NAME)
    visible = false

    
func join_game_room():
    Immersive.client.join_game_room(join_room_code.text)
    visible = false
