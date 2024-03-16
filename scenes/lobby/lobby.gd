extends CanvasLayer

class_name Lobby

signal started_game

@export var start_button: Button
@export var screen_title: Label
@export var connected_player_scene: PackedScene
@export var connected_players_list: Control

func _ready():
    if Mediator.instance.is_server(false):
        close()

func close():
    queue_free()

func update_connected_player(index: int, nickname: String):
    var list_items = connected_players_list.get_children()
    
    if index > len(list_items) - 1:
        add_connected_player(nickname)

func add_connected_player(nickname: String):
    var list_item = connected_player_scene.instantiate() as ConnectedPlayer
    
    list_item.nickname = nickname
    connected_players_list.add_child(list_item)

func set_can_start_game():
    start_button.pressed.connect(func(): started_game.emit())
    start_button.disabled = false
   
func initialize(room_code: String):
    screen_title.text = 'ROOM: %s' % room_code
    visible = true
    start_button.disabled = true
