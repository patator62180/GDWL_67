extends Control

class_name Hand

var cards = []
var card_ressources = []
var card_width = 150

var card_count = 0
var selected_card_index = -1
var selected_card
var card_scene
var total_weight = 0

@export var cards_parent: Control
@export var max_width: int
@export var max_card_angle: float
@export var deck: TextureRect

signal card_selected(cardType : String)
signal draw_card_for_turn

# Called when the node enters the scene tree for the first time.
func _ready():
    card_ressources.append(preload("res://scenes/cards/resources/movement_card.tres"))
    card_ressources.append(preload("res://scenes/cards/resources/wall_card.tres"))
    card_ressources.append(preload("res://scenes/cards/resources/hammer_card.tres"))
    card_scene = preload("res://scenes/cards/card.tscn")
    for ressource in card_ressources:
        total_weight += ressource.weight
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("escape"):
        unselect_selected_card()
    pass
    
func get_card_index() -> int:
    var rand = randi_range(0,total_weight-1)
    var weight = 0
    for i in range(0, card_ressources.size()):
        weight += card_ressources[i].weight
        if(rand<weight):
            return i
    assert(false, "total_weight < rand")
    return 0

func draw_multiple(count : int):
    for i in range(0,count):
        draw()
    
func draw():
    var card_index = get_card_index()
    var card_ressource = card_ressources[card_index]
    var card = card_scene.instantiate() as Card
    card.init(card_ressource)
    
    cards_parent.add_child(card)
    
    card_count += 1
    card.card_id = card_count
    card.card_clicked.connect(select_card)
    
    cards.push_back(card)
    reposition_cards()
    
    play_card_appear_anims(card)
    
    unselect_selected_card()

func select_card(card_id):
    unselect_selected_card()
    for i in range(0, cards.size()):
        var card = cards[i]
            
        if card.card_id == card_id:
            card_selected.emit(card.get_type())
            selected_card_index = i
            selected_card = card
            break
            
func unselect_selected_card():
    if selected_card_index == -1:
        return

    selected_card.deselect_card()
    selected_card_index = -1
    selected_card = null    
    card_selected.emit("")  
    
func reposition_cards():
    var authorized_card_width = card_width
    if cards.size() > 1: 
        authorized_card_width = (max_width - card_width) as float / (cards.size() - 1)
    
    var actual_width = min(card_width, authorized_card_width)
    
    #actual magic (do not interfere)
    for i in range(0, cards.size()):
        cards[i].position = Vector2(i * actual_width - (cards.size() - 1) * actual_width / 2 - card_width / 2, 0)
        cards[i].rotation_degrees = ((i+0.5) as float / cards.size()) * max_card_angle - max_card_angle / 2

func consume_selected_card():
    cards.remove_at(selected_card_index)
    selected_card.queue_free()
    unselect_selected_card()
    reposition_cards()

func _on_deck_gui_input(event):
    if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT and event.is_pressed():
        if PlayerController.instance.can_play():
            draw_multiple(2)
            draw_card_for_turn.emit()
            

func play_card_appear_anims(card: Card):
    card.show_card_appear()
    await get_tree().create_timer(0.3).timeout
    card.flip_card()


func _on_deck_mouse_entered():
    deck.scale = Vector2.ONE * 1.1


func _on_deck_mouse_exited():
    deck.scale = Vector2.ONE
