extends Node2D

class_name CharacterManager

@export var characters_root: Node2D
@export var character_scene: PackedScene
@export var initial_grid_pos: Vector2i
@export var modulateFaceColor = 0
@export var character_spawner: MultiplayerSpawner

var characters: Array[Character]:
    get:
        var _characters: Array[Character] = []
        for child in characters_root.get_children():
            if child is Character:
                _characters.append(child)

        return _characters

signal played

func _ready():
    character_spawner.spawn_function = spawn_player_client        

func spawn_initial_player(grid: Grid):
    spawn_player(grid, initial_grid_pos)

func spawn_player(grid: Grid, grid_pos: Vector2):   
    character_spawner.spawn(grid.get_screen_pos(grid_pos))

func spawn_player_client(position):
    var character = character_scene.instantiate() 
    character.position = position
    character.played.connect(func(): played.emit())
    
    return character
    
func kill_player(grid: Grid, grid_pos: Vector2):
    var character = get_character_at_position(grid_pos, grid)
    
    if character != null:
        character.queue_free()
    
func process_action(action: String):
    for character in characters:
        character.process_action(action)

func get_character_at_position(grid_position: Vector2, grid: Grid):
    for character in characters:
        if grid_position == grid.get_grid_pos(character.position):
            return character
