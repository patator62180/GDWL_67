extends Node2D

class_name Player

signal played

var tile_size = 100

var grid_pos = Vector2.ZERO

var is_moving = false
var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO

var timer = 0.0
var timer_max = 0.25

@export var raycast: RayCast2D

func move(direction):
    raycast.rotation = atan2(-direction.x, direction.y)
    raycast.force_raycast_update()
    
    if !raycast.is_colliding():
        position += direction * tile_size
        return true
    
    return false

@rpc("any_peer")
func move_to(position: Vector2):
    if multiplayer and multiplayer.is_server():
        is_moving = true
        start_pos = self.position
        target_pos = position
        timer = 0
        
func _process(delta):
    if is_moving and multiplayer and multiplayer.is_server():
        self.position = lerp(start_pos, target_pos, timer/timer_max)
        timer += delta
        
        if timer >= timer_max:
            self.position = target_pos
            is_moving = false
            played.emit()
        
func can_move_to(grid_pos: Vector2):
    return self.grid_pos.distance_to(grid_pos) <= 1
        
func process_action(action: String):
    match action:
        "left":
            move(Vector2.LEFT)
        "right":
            move(Vector2.RIGHT)
        "up":
            move(Vector2.UP)
        "down":
            move(Vector2.DOWN)
