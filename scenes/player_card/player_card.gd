extends Control

class_name PlayerCard

@export var player_index: int

@export var player_index_label: Label
@export var status_label: Label
@export var start_game_button: Button

signal start_game_pressed

func _ready():
    player_index_label.text = 'Player %d' % (player_index + 1)
    set_start_game_button_enabled(false)
    start_game_button.pressed.connect(func (): start_game_pressed.emit())
    set_connected()

func set_start_game_button_enabled(enabled: bool):
    start_game_button.disabled = not enabled
    start_game_button.visible = enabled

func set_playing(playing: bool):
    status_label.text = 'Playing' if playing else ''

func set_connected():
    status_label.text = 'Connected'

func assign():
    player_index_label.text = 'Player %d (You)' % (player_index + 1)
