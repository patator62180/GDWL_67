extends Control

class_name InputManager

static var instance: InputManager 

signal game_mouse_click(Vector2, bool)
signal game_mouse_move(Vector2)
signal game_mouse_exited

# Called when the node enters the scene tree for the first time.
func _ready():
    instance = self

func _on_gui_input(event):
    if event is InputEventMouseMotion:
        handle_mouse_move(event as InputEventMouseMotion)
        
    if event is InputEventMouseButton:
        handle_mouse_click(event as InputEventMouseButton)

func handle_mouse_move(event: InputEventMouseMotion):
    game_mouse_move.emit(center_position(event.position))

func handle_mouse_click(event: InputEventMouseButton):
    if event.is_pressed() and (event.button_index == 1 or 2):
        game_mouse_click.emit(center_position(event.position), event.button_index == 1)
        
func center_position(position: Vector2):
    var camera_zoom = Camera.instance.zoom.x
    var camera_offset = Camera.instance.position
    
    var centered_position = ((position + camera_offset) - size / 2) / camera_zoom 
    
    return centered_position    


func _on_mouse_exited():
    game_mouse_exited.emit()
