extends Node2D

class_name HazardManager

@export var grid: Grid
@export var bounds: Vector4

var turnNumber = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        pass_turn()
    pass
    
func pass_turn():
    var rng = RandomNumberGenerator.new()
    var randomX = rng.randi_range(bounds.x, bounds.z)
    var randomY = rng.randi_range(bounds.y, bounds.w)
    
    grid.tile_map.set_cell(0, Vector2(randomX, randomY), 0, Vector2(1,1))
