extends CanvasLayer

class_name HUD

@export var player_cards: Array[PlayerCard]
@export var PlayerManagers: PlayerManagers
@export var hand: Hand
@export var your_turn_label : Control
@export var other_player_turn_label : Control

signal mute_music

func _ready():
    $YouWinLabel.visible = false
    $YouLostLabel.visible = false
    your_turn_label.visible = false
    other_player_turn_label.visible = false

func _process(delta):
    var slider1 = get_node("ColorChoicePlayer1/HSlider").value
    get_node("ColorChoicePlayer1/ColorRect").material.set_shader_parameter("Shift_Hue", slider1)
    set_turn_label()

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
