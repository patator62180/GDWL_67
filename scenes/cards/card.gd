extends Control

class_name Card

signal card_clicked

@export var outline : Control
@export var icon : TextureRect

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


func _on_mouse_exited():
    scale = Vector2.ONE


func get_type():
    return resource.type
