extends CanvasLayer

class_name HUD

@export var game: Game
@export var player_cards: Array[PlayerCard]
@export var PlayerManagers: PlayerManagers
@export var hand: Hand
@export var your_turn_label : Control
@export var other_player_turn_label : Control
@export var win_label : Label
@export var lose_label : Label
@export var horizontal_slider: HSlider
@export var score_card : ScoreControl
@export var mute_button : BaseButton

signal mute_music

func _ready():
    win_label.visible = false
    lose_label.visible = false
    your_turn_label.visible = false
    other_player_turn_label.visible = false
    game.player_scored.connect(score_card.on_player_scored)
    game.game_finished.connect(set_winning_label)
    mute_button.toggled.connect(_on_mute_sound_toggled)

func _process(delta):
	set_turn_label()
	#uncomment when implemented
	#set_player_color()


func set_winning_label(player_won : bool):
	win_label.visible = player_won
	lose_label.visible = !player_won

func _on_mute_sound_toggled(toggled_on):
	if toggled_on:
		get_parent().get_node("/root/BackgroundMusic/BGMusic").volume_db = -1000
	else: get_parent().get_node("/root/BackgroundMusic/BGMusic").volume_db = -3.5

func set_turn_label():
	your_turn_label.visible = PlayerController.instance.can_play()
	other_player_turn_label.visible = not PlayerController.instance.can_play()
