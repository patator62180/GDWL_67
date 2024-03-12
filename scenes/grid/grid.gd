extends Node2D

class_name Grid

@export var tile_map: TileMap
@export var selection_tile_map: TileMap
@export var wall_tile_map: TileMap
@export var selection_wall_tile_map: TileMap

signal cell_click
signal wall_click

var grid_size

var selected_wall_tile = null
var current_wall_index = 0

var cardinal = [
    Vector2.UP,
    Vector2.DOWN,
    Vector2.RIGHT,
    Vector2.LEFT
]

var octo = [
    Vector2.UP,
    Vector2.DOWN,
    Vector2.RIGHT,
    Vector2.LEFT,
    Vector2.UP + Vector2.RIGHT,
    Vector2.UP + Vector2.LEFT,
    Vector2.DOWN + Vector2.RIGHT,
    Vector2.DOWN + Vector2.LEFT
]

var selected_tile = null
var previous_hovered_tile = null

# Called when the node enters the scene tree for the first time.
func _ready():
    grid_size = tile_map.tile_set.tile_size.x
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("mouse_select"):
        if try_create_wall():
            return
        try_move_player()
    
    check_wall_input_pressed()
    check_wall_input_released()
        
    manage_highlight_arows()
        
func get_grid_pos(position: Vector2):
    return Vector2(floor(position.x / grid_size), floor(position.y / grid_size))

func get_screen_pos(grid_pos: Vector2):
    return Vector2(grid_pos.x, grid_pos.y) * grid_size
    
func show_possible_selection(grid_pos: Vector2, player_managers: PlayerManagers):
    selected_tile = grid_pos
    selection_tile_map.clear()
    
    for direction in cardinal:
        var pos = Vector2(grid_pos + direction)
        if is_possible_tile(pos) and is_possible_movement(grid_pos, direction) and player_managers.check_for_player(self, pos) == null:
            selection_tile_map.set_cell(0, pos, 0, Vector2(0,0))

func clear_possible_selections():
    selected_tile = null
    previous_hovered_tile = null
    selection_tile_map.clear()
    
func is_possible_tile(grid_pos: Vector2):
    return tile_map.get_cell_tile_data(0, grid_pos) != null

func is_possible_movement(grid_pos: Vector2, direction: Vector2):
    var top_right_wall = wall_tile_map.get_cell_source_id(0, grid_pos + Vector2(0,-1))
    var top_left_wall = wall_tile_map.get_cell_source_id(0, grid_pos + + Vector2(-1,-1))
    var bottom_right_wall = wall_tile_map.get_cell_source_id(0, grid_pos)
    var bottom_left_wall = wall_tile_map.get_cell_source_id(0, grid_pos + Vector2(-1, 0))
    
    match direction:
        Vector2.UP:
            return top_right_wall != 0 and top_right_wall != 2 and top_left_wall != 0 and top_left_wall != 2
        Vector2.DOWN:
            return bottom_right_wall != 0 and bottom_right_wall != 2 and bottom_left_wall != 0 and bottom_left_wall != 2
        Vector2.RIGHT:
            return top_right_wall != 1 and top_right_wall != 2 and bottom_right_wall != 1 and bottom_right_wall != 2
        Vector2.LEFT:
            return top_left_wall != 1 and top_left_wall != 2 and bottom_left_wall != 1 and bottom_left_wall != 2
    
    
func add_wall(grid_pos: Vector2, tile_index: int):
    wall_tile_map.set_cell(0, grid_pos, tile_index, Vector2.ZERO)
    
    
func try_move_player():
    var mouse_pos = get_local_mouse_position()
    var grid_pos = get_grid_pos(mouse_pos)
        
    is_possible_movement(grid_pos, Vector2.ZERO)
                
    var cell_tile_data = tile_map.get_cell_source_id(0, grid_pos)
    if cell_tile_data != -1:
        cell_click.emit(grid_pos)        
    
func try_create_wall():
    if selected_wall_tile != null:
        var wall_id = wall_tile_map.get_cell_source_id(0, selected_wall_tile)
        var next_index = current_wall_index if wall_id == -1 or wall_id == current_wall_index else 2
        
        wall_click.emit(selected_wall_tile, next_index)
        return true
    return false     

func check_wall_input_pressed():
    if Input.is_action_pressed("ui_accept"):
        var mouse_pos = get_local_mouse_position()
        var grid_pos_offset = get_grid_pos(mouse_pos - Vector2.ONE * grid_size / 2)
        
        if selected_wall_tile != grid_pos_offset:
            selected_wall_tile = grid_pos_offset
            selection_wall_tile_map.clear()
            selection_wall_tile_map.set_cell(0, selected_wall_tile, current_wall_index, Vector2.ZERO)
            
        if Input.is_action_just_pressed("mouse_right"):
            current_wall_index = 1 if current_wall_index == 0 else 0
            selection_wall_tile_map.clear()
            selection_wall_tile_map.set_cell(0, selected_wall_tile, current_wall_index, Vector2.ZERO)  
            
func check_wall_input_released():  
    if Input.is_action_just_released("ui_accept"):
        selection_wall_tile_map.clear()
        selected_wall_tile = null
            
func manage_highlight_arows():
    if selected_tile != null:
        if previous_hovered_tile != null:
            selection_tile_map.set_cell(0, previous_hovered_tile, 0, Vector2.ZERO)
        
        var mouse_pos = get_local_mouse_position()
        var grid_pos = get_grid_pos(mouse_pos)
        
        var highlight_id = selection_tile_map.get_cell_source_id(0, grid_pos)
        
        if highlight_id == 0:
            var direction = grid_pos - selected_tile
            var atlas_id = Vector2.ZERO
            match direction:
                Vector2.LEFT:
                    atlas_id = Vector2.RIGHT
                Vector2.UP:
                    atlas_id = Vector2(2,0)
                Vector2.RIGHT:
                    atlas_id = Vector2(3,0)
                    
            selection_tile_map.set_cell(0, grid_pos, 1, atlas_id)
            previous_hovered_tile = grid_pos
