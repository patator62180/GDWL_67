extends Node2D

class_name PlayerManagers

@export var array: Array[PlayerManager]

signal player_spawned(player : Player)

func _ready():
    for player_manager in array:
        player_manager.player_spawned.connect(on_player_spawned)
        
func check_for_player(grid: Grid, grid_pos:Vector2):
    for player_manager in array:
        for player in player_manager.player_characters:
            var player_grid_pos = grid.get_grid_pos(player.position)
                
            if (player_grid_pos == grid_pos):
                return player
    
    return null
    
func on_player_spawned(player : Player):
    player_spawned.emit(player)
