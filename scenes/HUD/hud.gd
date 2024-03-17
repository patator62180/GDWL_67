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
@export var confetti_launcher : ConfettiLauncher


func _ready():
    win_label.visible = false
    lose_label.visible = false
    your_turn_label.visible = false
    other_player_turn_label.visible = false
    game.game_finished.connect(on_game_over)
    game.game_finished.connect(confetti_launcher.on_game_finished)

func on_game_over(player_won : bool):
    win_label.visible = player_won
    lose_label.visible = !player_won
    
    hand.visible = false
    your_turn_label.visible = false
    other_player_turn_label.visible = false

    
func set_turn_label():
    your_turn_label.visible = PlayerController.instance.can_play()
    other_player_turn_label.visible = not PlayerController.instance.can_play()
