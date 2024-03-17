extends CanvasLayer

class_name Lobby

signal started_game
signal nickname_edited
signal color_changed
signal win_score_changed

@export var start_button: Button
@export var screen_title: Label
@export var connected_player_scene: PackedScene
@export var connected_players_list: Control
@export var nickname_edit: TextEdit
@export var color_slider: HSlider
@export var color_picker_player_preview: Player
@export var win_score_edit : TextEdit
@export var win_score_container : Control

var nickname: String = "":
    set(value):
        if value != nickname_edit.text:
            nickname_edit.text = value

var color: float = 0:
    set(value):
        color_picker_player_preview.color = value

func _ready():
    if Mediator.instance and Mediator.instance.is_server(false):
        close()
    else:
        nickname_edit.text_changed.connect(on_text_changed)
        color_slider.value_changed.connect(on_color_slider_changed)
        win_score_edit.text_changed.connect(on_win_score_changed)

func close():
    queue_free()

func on_color_slider_changed(value: float):
    var color = value / 1000

    color_picker_player_preview.color = color
    color_changed.emit(color)

func on_text_changed():
    if len(nickname_edit.text) >= 1:
        nickname_edited.emit(nickname_edit.text)

func on_win_score_changed():
    var new_win_score = int(win_score_edit.text)
    if(new_win_score != 0):
        win_score_changed.emit(new_win_score)

func update_connected_player(index: int, nickname: String, color: float):
    var list_items = connected_players_list.get_children()
    
    if index > len(list_items) - 1:
        add_connected_player(nickname, color)
    else:
        var connected_player = list_items[index] as ConnectedPlayer
        connected_player.nickname = nickname
        connected_player.color = color

func add_connected_player(nickname: String, color: float):
    var list_item = connected_player_scene.instantiate() as ConnectedPlayer
    
    list_item.nickname = nickname
    list_item.color = color
    connected_players_list.add_child(list_item)

func set_can_start_game():
    start_button.pressed.connect(func(): started_game.emit())
    start_button.disabled = false
   
func initialize(room_code: String):
    screen_title.text = 'ROOM: %s' % room_code
    visible = true
    start_button.disabled = true
