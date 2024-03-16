extends CanvasLayer

class_name HUD

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
    var game = get_parent() as Game
    game.p1_scored.connect(score_card._on_game_p_1_scored)
    game.p2_scored.connect(score_card._on_game_p_2_scored)
    game.game_finished.connect(set_winning_label)
    mute_button.toggled.connect(_on_mute_sound_toggled)
    

func _process(delta):
    set_turn_label()
    #uncomment when implemented
    #set_player_color()


func set_winning_label():
    var isWinning = PlayerController.instance.can_play()
    win_label.visible = isWinning
    lose_label.visible = !isWinning

func _on_mute_sound_toggled(toggled_on):
    if toggled_on:
        get_parent().get_node("/root/BackgroundMusic/BGMusic").volume_db = -1000
    else: get_parent().get_node("/root/BackgroundMusic/BGMusic").volume_db = -3.5

func set_turn_label():
    your_turn_label.visible = PlayerController.instance.can_play()
    other_player_turn_label.visible = not PlayerController.instance.can_play()

func set_player_color():
    var slider1 = get_node("ColorChoicePlayer1/HSlider").value
    if not OS.has_feature('dedicated_server'):
        get_node("ColorChoicePlayer1/ColorRect").material.set_shader_parameter("Shift_Hue", slider1)
