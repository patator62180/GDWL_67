extends Node2D

@export var identification_label: Label
@export var player_status_labels: Array[Label]


var players = []
var player_index: int
var is_game_started: bool
var is_choice_step: bool
var player_choices: Dictionary

func _ready():
    if multiplayer and multiplayer.is_server():
        Immersive.client.peer_player_joined.connect(on_peer_player_joined)
        player_status_labels[0].text = 'Waiting for player 0'
        player_status_labels[1].text = 'Waiting for player 1'
    elif multiplayer and not multiplayer.is_server():
        Immersive.client.joined

@rpc('authority')
func assign_player(player_index: int):
    self.player_index = player_index
    identification_label.text = 'I AM PLAYER %d' % player_index

@rpc('any_peer')
func choose_action(player_index: int, action: String):
    if multiplayer and multiplayer.is_server():
        if is_choice_step and not player_index in player_choices:
            player_choices[player_index] = action
            player_status_labels[player_index].text = 'Player %d chose action' % player_index
            
            if len(player_choices) == 2:
                is_choice_step = false
                player_status_labels[0].text = 'Running actions...'
                player_status_labels[1].text = ''

func on_peer_player_joined(id: int):
    var player_index = len(players)
    
    players.append(id)
    assign_player.rpc_id(id, player_index)
    player_status_labels[player_index].text = 'Player %d connected' % player_index
    
    if len(players) == 2:
        Immersive.client.starts_playing()
        is_game_started = true
        start_choosing_step()

func start_choosing_step():
    is_choice_step = true
    player_choices = {}
    player_status_labels[0].text = 'Player 0 is choosing action'
    player_status_labels[1].text = 'Player 1 is choosing action'

func _process(delta):
    if multiplayer and not multiplayer.is_server() and Input.is_action_just_pressed("left"):
        choose_action.rpc(player_index, 'left')
