extends CanvasLayer

class_name HUD

@export var player_cards: Array[PlayerCard]
@export var PlayerManagers: PlayerManagers
@export var hand: Hand
@export var your_turn_label : Control
@export var other_player_turn_label : Control
@export var horizontal_slider: HSlider
@export var score_card : ScoreControl

signal mute_music

func _ready():
    $YouWinLabel.visible = false
    $YouLostLabel.visible = false
    your_turn_label.visible = false
    other_player_turn_label.visible = false
    var game = get_parent() as Game
    game.p1_scored.connect(score_card._on_game_p_1_scored)
    game.p1_scored.connect(score_card._on_game_p_1_scored)

func _process(delta):
    set_turn_label()
    var slider1 = get_node("ColorChoicePlayer1/HSlider").value
    if not OS.has_feature('dedicated_server'):
        get_node("ColorChoicePlayer1/ColorRect").material.set_shader_parameter("Shift_Hue", slider1)

func set_winning_label(isWinning : bool):
    $YouWinLabel.visible = isWinning
    $YouLostLabel.visible = !isWinning

func _on_mute_sound_toggled(toggled_on):
    if toggled_on:
        get_parent().get_node("/root/BackgroundMusic/BGMusic").volume_db = -1000
    else: get_parent().get_node("/root/BackgroundMusic/BGMusic").volume_db = -3.5

func set_turn_label():
    your_turn_label.visible = PlayerController.instance.can_play()
    other_player_turn_label.visible = not PlayerController.instance.can_play()
