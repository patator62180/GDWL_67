extends Player

class_name Host

func _ready():
    get_node("AnimationTree").set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func move_host(grid: Grid, player_managers: PlayerManagers):
    var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
    var grid_pos = grid.get_grid_pos(position)
    var moved = false
    directions.shuffle()

    for direction in directions:
        var next_grid_pos = grid_pos + direction

        if can_move_to(next_grid_pos, grid, player_managers):
            var next_pos = grid.get_screen_pos(next_grid_pos)
            move_to(next_pos)
            moved = true
            break
    
    if not moved:
        played.emit()
