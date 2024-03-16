extends CanvasLayer

class_name Lobby

signal started_game

@export var start_button: Button
@export var screen_title: Label

func _ready():
    if Mediator.instance.is_server(false):
        close()

func close():
    queue_free()

func set_can_start_game():
    start_button.pressed.connect(func(): started_game.emit())
    start_button.disabled = false
   
func initialize(room_code: String):
    screen_title.text = 'ROOM: %s' % room_code
    visible = true
    start_button.disabled = true
