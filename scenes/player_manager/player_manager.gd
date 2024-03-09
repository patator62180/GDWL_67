extends Node2D

class_name PlayerManager

@export var player_characters: Array[Player]

signal played

# Called when the node enters the scene tree for the first time.
func _ready():
    for player_character in player_characters:
        player_character.played.connect(func(): played.emit())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func process_action(action: String):
    for player in player_characters:
        player.process_action(action)

func get_character_at_position(grid_position: Vector2, grid: Grid):
    for player in player_characters:
        if grid_position == grid.get_grid_pos(player.position):
            return player
