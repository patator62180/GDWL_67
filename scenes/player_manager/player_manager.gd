extends Node2D

class_name PlayerManager

@export var players_root: Node2D
@export var player_scene: PackedScene
@export var initial_grid_pos: Vector2i
@export var modulateFaceColor = 0
@export var player_spawner: MultiplayerSpawner
@export var color: float = 0

var player_characters: Array[Player]:
    get:
        var _player_characters: Array[Player] = []
        for child in players_root.get_children():
            if child is Player:
                _player_characters.append(child)

        return _player_characters

signal player_spawned(player : Player)

func _ready():
    player_spawner.spawn_function = spawn_player_client        

func spawn_initial_player(grid: Grid):
    spawn_player(grid, initial_grid_pos)

func spawn_player(grid: Grid, grid_pos: Vector2):   
    player_spawner.spawn(grid.get_screen_pos(grid_pos))

func spawn_player_client(position):
    var player_character = player_scene.instantiate() 
    player_character.position = position
    player_character.color = color
    player_spawned.emit(player_character)
    return player_character
    
func kill_player(grid: Grid, grid_pos: Vector2):
    var player = get_character_at_position(grid_pos, grid)
    
    if player != null:
        player.queue_free()
    
func process_action(action: String):
    for player in player_characters:
        player.process_action(action)

func get_character_at_position(grid_position: Vector2, grid: Grid):
    for player in player_characters:
        if grid_position == grid.get_grid_pos(player.position):
            return player

func get_character_index_at_position(grid_position: Vector2, grid: Grid):
    for i in range(0, player_characters.size()):
        if grid_position == grid.get_grid_pos(player_characters[i].position):
            return i
    return 0
