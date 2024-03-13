extends Node2D

class_name CharacterManagers

@export var array: Array[CharacterManager]

func check_for_player(grid: Grid, grid_pos:Vector2):
    for player_manager in array:
        for player in player_manager.player_characters:
            var player_grid_pos = grid.get_grid_pos(player.position)
                
            if (player_grid_pos == grid_pos):
                return player
    
    return null
