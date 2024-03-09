extends Node2D

class_name Player

signal played

var tile_size = 32

var current_position = Vector2.ZERO

@export var raycast: RayCast2D

func move(direction):
    raycast.rotation = atan2(-direction.x, direction.y)
    raycast.force_raycast_update()
    
    if !raycast.is_colliding():
        position += direction * tile_size

@rpc("any_peer")
func move_to(position):
    if multiplayer and multiplayer.is_server():
        self.position = position
        played.emit()
        
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
