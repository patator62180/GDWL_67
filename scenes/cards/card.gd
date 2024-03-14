extends Control

class_name Card

signal card_clicked

@export var outline : Control
@export var icon : TextureRect
@export var animation_player : AnimationPlayer

var resource : Resource

var card_id = -1

func init(_resource : Resource):
    resource = _resource
    icon.set_texture(resource.icon)

func _on_gui_input(event):
    if event is InputEventMouseButton:
        card_clicked.emit(card_id)
        
func _on_mouse_entered():
    scale = Vector2.ONE * 1.1
    z_index = 1
    position.y = position.y - 50

func _on_mouse_exited():
    scale = Vector2.ONE
    z_index = 0
    position.y = position.y + 50
    
func get_type():
    return resource.type
    
func show_card_appear():
    animation_player.play("card_appear")
    
func show_card_back():
    animation_player.play("card_show_back")
    
func flip_card():
    animation_player.play("card_flip")
