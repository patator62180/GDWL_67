extends Node2D

class_name PlayerManager

@export var players_root: Node2D
@export var player_scene: PackedScene
@export var initial_grid_pos: Vector2i

var player_characters: Array[Player]:
    get:
        var _player_characters: Array[Player] = []
        
        for child in players_root.get_children():
            if child is Player:
                _player_characters.append(child)

        return _player_characters

signal played

func spawn_initial_player(grid: Grid):
    spawn_player(grid, initial_grid_pos)

func spawn_player(grid: Grid, grid_pos: Vector2):
    var player_character = player_scene.instantiate() as Player
    players_root.add_child(player_character)
    player_character.position = grid.get_screen_pos(grid_pos)
    player_character.played.connect(func(): played.emit())
    
func process_action(action: String):
    for player in player_characters:
        player.process_action(action)

func get_character_at_position(grid_position: Vector2, grid: Grid):
    for player in player_characters:
        if grid_position == grid.get_grid_pos(player.position):
            return player
