extends Control

var cards = []
var card_loaded 
var card_width = 150

var card_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    card_loaded = preload("res://scenes/hand/card.tscn")
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        draw()
    pass
    
func draw():
    var card = card_loaded.instantiate() as Card
    add_child(card)
    
    card_id += 1
    card.card_id = card_id
    card.card_clicked.connect(play_card)
    
    cards.push_back(card)
    reposition_cards()

func play_card(card_id):
    for i in range(0, cards.size()):
        var card = cards[i]
            
        if card.card_id == card_id:
            cards.remove_at(i)
            card.queue_free()
            reposition_cards()
            break
  
func reposition_cards():
    for i in range(0, cards.size()):
        cards[i].position = Vector2(i * card_width - cards.size() * card_width / 2, 0)