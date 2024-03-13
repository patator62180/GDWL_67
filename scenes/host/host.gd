extends Character

class_name Host


func move_host(grid: Grid, character_managers: CharacterManagers):
    var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
    var grid_pos = grid.get_grid_pos(position)
    var moved = false
    directions.shuffle()

    for direction in directions:
        var next_grid_pos = grid_pos + direction

        if can_move_to(next_grid_pos, grid, character_managers):
            var next_pos = grid.get_screen_pos(next_grid_pos)
            move_to(next_pos)
            %HostAnimationPlayer.play("idle")
            moved = true
            break
    
    if not moved:
        played.emit()
