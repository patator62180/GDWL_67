extends Node

class_name AudioPlayer

@export var game: Game
@export var hud: HUD
@export var defeat_sound: AudioStreamPlayer
@export var victory_sound: AudioStreamPlayer
@export var card_selection_sound: AudioStreamPlayer
@export var shockwave_sound: AudioStreamPlayer
@export var hover_tile: AudioStreamPlayer
@export var wall_place: AudioStreamPlayer

var rng = RandomNumberGenerator.new()

func _ready():
    game.grid.cell_hovered.connect(play_sound_hovered_tile)
    game.grid.wall_placed.connect(wall_place.play)
    game.game_finished.connect(on_game_finished)
    game.camera.shockwave.played.connect(shockwave_sound.play)
    hud.hand.card_selected.connect(on_card_selected)

func play_sound_hovered_tile():
    hover_tile.pitch_scale = rng.randf_range(0.70,1.30)
    hover_tile.play()

func on_game_finished(player_won : bool):    
    if player_won:
        victory_sound.play()
    else: 
        defeat_sound.play()

func on_card_selected(cardType : String):
    card_selection_sound.pitch_scale = rng.randf_range(0.70,1.30)
    card_selection_sound.play()
