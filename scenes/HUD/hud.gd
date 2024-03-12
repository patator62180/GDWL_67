extends CanvasLayer

class_name HUD

@export var player_cards: Array[PlayerCard]
@export var PlayerManagers: PlayerManagers
@export var hand: Hand

func _ready():
    $YouWinLabel.visible = false
    $YouLostLabel.visible = false
    
    #print(get_parent().player_index)  

func _process(delta):
    var slider1 = get_node("ColorChoicePlayer1/HSlider").value
    get_node("ColorChoicePlayer1/ColorRect").material.set_shader_parameter("Shift_Hue", slider1)

func set_winning_label(isWinning : bool):
    $YouWinLabel.visible = isWinning
    $YouLostLabel.visible = !isWinning

