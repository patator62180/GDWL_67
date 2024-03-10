extends CanvasLayer

@export var player_cards: Array[PlayerCard]
@export var PlayerManager0: PlayerManager
@export var PlayerManager1: PlayerManager


func set_winning_label(isWinning : bool):
    $YouWinLabel.visible = isWinning
    $YouLostLabel.visible = !isWinning

func _ready():
    $YouWinLabel.visible = false
    $YouLostLabel.visible = false
