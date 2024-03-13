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

signal card_selected(cardType : String)

# Called when the node enters the scene tree for the first time.
func _ready():
    card_ressources.append(preload("res://scenes/cards/movement_card.tres"))
    card_ressources.append(preload("res://scenes/cards/wall_card.tres"))
    card_scene = preload("res://scenes/cards/card.tscn")
    for ressource in card_ressources:
        total_weight += ressource.weight
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        draw()
    if Input.is_action_just_pressed("escape"):
        unselect_selected_card()
    pass
    
func get_card_index() -> int:
    var rand = randi_range(0,total_weight-1)
    var weight = 0
    for i in range(0, card_ressources.size()):
        weight += card_ressources[i].weight
        print(weight)
        if(rand<weight):
            return i
    assert(false, "total_weight < rand")
    return 0
    
func draw():
    var card_index = get_card_index()
    var card_ressource = card_ressources[card_index]
    var card = card_scene.instantiate() as Card
    card.init(card_ressource)
    
    add_child(card)
    
    card_count += 1
    card.card_id = card_count
    card.card_clicked.connect(select_card)
    
    cards.push_back(card)
    reposition_cards()

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
    selected_card.unselect()
    selected_card_index = -1
    selected_card = null    
    card_selected.emit("")  
    
func reposition_cards():
    for i in range(0, cards.size()):
        cards[i].position = Vector2(i * card_width - cards.size() * card_width / 2, 0)

func consume_selected_card():
    cards.remove_at(selected_card_index)
    selected_card.queue_free()
    unselect_selected_card()
    reposition_cards()
