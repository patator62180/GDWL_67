extends Control

class_name Hand

var cards = []
var cards_loaded = []
var card_width = 150

var card_count = 0
var selected_card_index = -1
var selected_card

signal card_selected(cardType : String)

# Called when the node enters the scene tree for the first time.
func _ready():
    cards_loaded.append(preload("res://scenes/cards/movement_card.tscn"))
    cards_loaded.append(preload("res://scenes/cards/wall_card.tscn"))
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        draw()
    if Input.is_action_just_pressed("escape"):
        unselect_selected_card()
    pass
    
func draw():
    var card_index = randi_range(0,cards_loaded.size()-1)
    var card = cards_loaded[card_index].instantiate() as Card
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
