extends Node2D

@export var identification_label: Label

var players = []
var player_index: int

func _ready():
    if multiplayer and multiplayer.is_server():
        Immersive.client.peer_player_joined.connect(on_peer_player_joined)
    elif multiplayer and not multiplayer.is_server():
        Immersive.client.joined


@rpc('authority')
func assign_player(player_index: int):
    self.player_index = player_index
    identification_label.text = 'I AM PLAYER %d' % player_index

func on_peer_player_joined(id: int):
    players.append(id)
    assign_player.rpc_id(id, len(players) - 1)
    
    if len(players) == 2:
        Immersive.client.starts_playing()

func _process(delta):
    if multiplayer and not multiplayer.is_server() and Input.is_action_just_pressed("left"):
        print('left')
