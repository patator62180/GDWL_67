extends CanvasLayer

class_name HUD

@export var player_cards: Array[PlayerCard]
@export var PlayerManagers: PlayerManagers
@export var hand: Hand

var player_controller: PlayerController

signal mute_music

func _ready():
    $YouWinLabel.visible = false
    $YouLostLabel.visible = false

func set_player_controller(player_controller: PlayerController):
    self.player_controller = player_controller
    hand.player_controller = player_controller

func _process(delta):
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
