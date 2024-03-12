extends Player

class_name Host


func move_host(grid: Grid):
    var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
    var grid_pos = grid.get_grid_pos(position)
    directions.shuffle()

    for direction in directions:
        var next_grid_pos = grid_pos + direction

        if can_move_to(next_grid_pos, grid):
            var next_pos = grid.get_screen_pos(next_grid_pos)
            move_to(next_pos)
            %HostAnimationPlayer.play("idle")
            break

