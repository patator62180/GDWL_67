extends CanvasLayer

@export var player_cards: Array[PlayerCard]

func set_winning_label(isWinning : bool):
    $YouWinLabel.visible = isWinning
    $YouLostLabel.visible = !isWinning

func _ready():
    $YouWinLabel.visible = false
    $YouLostLabel.visible = false
