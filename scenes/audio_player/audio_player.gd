extends Node

class_name AudioPlayer

@export var game: Game
@export var defeat_sound: AudioStreamPlayer
@export var victory_sound: AudioStreamPlayer
@export var card_selection_sound: AudioStreamPlayer
@export var shockwave_sound: AudioStreamPlayer
@export var hover_tile: AudioStreamPlayer
@export var wall_place: AudioStreamPlayer

func _ready():
    game.grid.cell_hovered.connect(play_sound_hovered_tile)
    game.grid.wall_placed.connect(wall_place.play)
    game.game_finished.connect(on_game_finished)
    game.camera.shockwave.played.connect(shockwave_sound.play)

func play_sound_hovered_tile():
    hover_tile.play()
    var rng = RandomNumberGenerator.new()
    hover_tile.pitch_scale = rng.randf_range(0.70,1.30)

func on_game_finished(player_won : bool):    
    if player_won:
        victory_sound.play()
    else: 
        defeat_sound.play()
