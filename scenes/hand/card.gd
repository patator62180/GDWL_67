extends Control

class_name Card

signal card_clicked

var card_id = -1

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_gui_input(event):
    if event is InputEventMouseButton:
        card_clicked.emit(card_id)


func _on_mouse_entered():
    scale = Vector2.ONE * 1.1


func _on_mouse_exited():
    scale = Vector2.ONE
