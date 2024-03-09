extends Node2D

class_name Grid

@export var tile_map: TileMap
signal cell_click

var grid_size

# Called when the node enters the scene tree for the first time.
func _ready():
    grid_size = tile_map.tile_set.tile_size.x
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if (Input.is_action_just_pressed("mouse_select")):
        var mouse_pos = get_local_mouse_position()
        var grid_pos = get_grid_pos(mouse_pos)
                
        var cell_tile_data = tile_map.get_cell_tile_data(0, grid_pos)
        if cell_tile_data != null:
            cell_click.emit(grid_pos)

func get_grid_pos(position: Vector2):
    return Vector2(floor(position.x / grid_size), floor(position.y / grid_size))

func get_screen_pos(grid_pos: Vector2):
    return Vector2(grid_pos.x, grid_pos.y) * grid_size
