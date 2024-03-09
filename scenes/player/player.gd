extends Node2D

var tile_size = 32

var current_position = Vector2.ZERO

@export var raycast: RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var direction = Vector2.ZERO
    
    if Input.is_action_just_pressed("ui_left"):
        direction += Vector2.LEFT
    if Input.is_action_just_pressed("ui_right"):
        direction += Vector2.RIGHT
    if Input.is_action_just_pressed("ui_up"):
        direction += Vector2.UP
    if Input.is_action_just_pressed("ui_down"):
        direction += Vector2.DOWN
        
    if direction != Vector2.ZERO:
        move(direction)
        
func move(direction):
    raycast.rotation = atan2(-direction.x, direction.y)
    raycast.force_raycast_update()
    
    if !raycast.is_colliding():
        position += direction * tile_size
