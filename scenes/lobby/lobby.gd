extends CanvasLayer

class_name Lobby

signal started_game
signal nickname_edited

@export var start_button: Button
@export var screen_title: Label
@export var connected_player_scene: PackedScene
@export var connected_players_list: Control
@export var nickname_edit: TextEdit
@export var color_slider: HSlider
@export var color_picker_player_preview: Player

var nickname: String = "":
	set(value):
		if value != nickname_edit.text:
			nickname_edit.text = value

func _ready():
	if Mediator.instance and Mediator.instance.is_server(false):
		close()
	else:
		nickname_edit.text_changed.connect(on_text_changed)
		color_slider.value_changed.connect(on_color_slider_changed)

func close():
	queue_free()

func on_color_slider_changed(value: float):
	color_picker_player_preview.color = value / 1000

func on_text_changed():
	if len(nickname_edit.text) >= 1:
		nickname_edited.emit(nickname_edit.text)

func update_connected_player(index: int, nickname: String):
	var list_items = connected_players_list.get_children()
	
	if index > len(list_items) - 1:
		add_connected_player(nickname)
	else:
		var connected_player = list_items[index] as ConnectedPlayer
		connected_player.nickname = nickname

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
