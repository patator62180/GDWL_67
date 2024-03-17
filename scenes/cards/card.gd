extends Control

class_name Card

signal card_clicked

@export var outline : Control
@export var icon : TextureRect
@export var description : RichTextLabel
@export var animation_player : AnimationPlayer
@export var background_texture_rect: TextureRect
@export var selected_color = Color(0.4, 1, 0.2, 0.85)

var is_selectable = false
var is_selected = false

var selected_timer = 0.0
var selected_timer_max = 0.2
var selected_height = 75
var selected_size = 0.1

var resource : Resource

var card_id = -1

func init(_resource : Resource):
    resource = _resource
    icon.set_texture(resource.icon)
    description.text = "[center]" + resource.description + "[/center]"

func _process(delta):
    #this makes the card go up and down over time
    
    #going up
    if is_selectable and is_selected and selected_timer < selected_timer_max:
        selected_timer = min(selected_timer + delta, selected_timer_max)
        
        var ratio =  selected_timer / selected_timer_max;
        background_texture_rect.position.y = lerp(0, -selected_height, ratio)  
        background_texture_rect.scale = Vector2.ONE + Vector2(selected_size, selected_size) * ratio
        
    #going down    
    elif !is_selected and selected_timer > 0.0:
        selected_timer = max(selected_timer - delta, 0.0)
        
        var ratio = selected_timer / selected_timer_max;
        background_texture_rect.position.y = lerp(0, -selected_height, ratio)  
        background_texture_rect.scale = Vector2.ONE + Vector2(selected_size, selected_size) * ratio

func _on_gui_input(event):
    if !is_selectable:
        return
    
    if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT and event.is_pressed():
        select_card()
        
func _on_mouse_entered():
    is_selected = true
    
    if is_selectable:
        raise_card()
        
func _on_mouse_exited():
    is_selected = false
    
    if is_selectable:
        lower_card()
        
func select_card():
    if !is_my_turn():
        return
    
    card_clicked.emit(card_id)
    if not OS.has_feature('dedicated_server'):
        background_texture_rect.material.set_shader_parameter("color", selected_color)

func deselect_card():
    if not OS.has_feature('dedicated_server'):
        background_texture_rect.material.set_shader_parameter("color", Color.TRANSPARENT)
 
func raise_card():
    z_index = 1
    
func lower_card():
    z_index = 0
    
func get_type():
    return resource.type
    
func show_card_appear():
    animation_player.play("card_appear")
    
func show_card_back():
    animation_player.play("card_show_back")
    
func flip_card():
    animation_player.play("card_flip")
    
    await get_tree().create_timer(0.5).timeout
    
    is_selectable = true
    
    if is_selected:
        _on_mouse_entered()

func is_my_turn():
    return PlayerController.instance.can_play()
