extends Node2D

const MAX_PLAYERS_COUNT = 4

@export var host_scene: PackedScene
@export var host_root: Node2D
@export var player_characters: Array[PlayerManager]
@export var player_cards: Array[PlayerCard]
@export var grid: Grid

var players = []
var hosts: Array[Host] = []
var player_index: int
var is_game_started: bool
var is_choice_step: bool
var selected_player: Player
var player_index_playing: int = -1


func _ready():
    if multiplayer and multiplayer.is_server():
        Immersive.client.peer_player_joined.connect(on_peer_player_joined)
        
        for player_character in player_characters:
            player_character.played.connect(on_player_played)

    grid.cell_click.connect(on_cell_click)
    
    for player in player_characters:
        player.setup_players(grid)

func on_player_played():
    player_index_playing = player_index_playing + 1 if player_index_playing < len(players) - 1 else 0
    if player_index_playing == 0:
        for host in hosts:
            host.move_after_players_turns()
    
    set_turn(player_index_playing)

func set_turn(player_index: int):
    propagate_turn.rpc(player_index)
    
    for index in range(MAX_PLAYERS_COUNT):
        player_cards[index].set_playing(player_index == index)
    
    player_index_playing = player_index

func is_player_active_turn():
    return player_index_playing == player_index

@rpc('authority')
func propagate_turn(player_index: int):
    player_index_playing = player_index

@rpc('any_peer')
func start_game():
    if multiplayer and multiplayer.is_server():
        propagate_start_game.rpc()
        is_game_started = true
        
        for player_index in range(MAX_PLAYERS_COUNT):
            if player_index > len(players) - 1:
                player_cards[player_index].visible = false
        
        spawn_host()
        set_turn(0)

func spawn_host():
    var host = host_scene.instantiate()
    var grid_pos = Vector2(0, -1)
    
    host_root.add_child(host)
    host.position = grid.get_screen_pos(grid_pos)
    hosts.append(host)

@rpc('authority')
func assign_player(player_index: int):
    self.player_index = player_index
    player_cards[player_index].assign()

@rpc('authority')
func give_start_game_permission():
    player_cards[player_index].set_start_game_button_enabled(true)
    player_cards[player_index].start_game_pressed.connect(request_start_game)

@rpc('authority')
func propagate_start_game():
    player_cards[player_index].set_start_game_button_enabled(false)

func request_start_game():
    start_game.rpc_id(1)

func on_peer_player_joined(id: int):
    var player_index = len(players)
    
    players.append(id)
    assign_player.rpc_id(id, player_index)
    player_cards[player_index].set_connected()
    
    if player_index == 1:
        give_start_game_permission.rpc_id(players[0])

func move_player(player_index: int, action: String):
    if multiplayer and multiplayer.is_server():
        player_characters[player_index].process_action(action)
        
func on_cell_click(grid_pos: Vector2):
    if multiplayer and not multiplayer.is_server() and is_player_active_turn():
        var player_manager = player_characters[player_index]
        var found_player = player_manager.get_character_at_position(grid_pos, grid)

        if found_player != null:
            selected_player = found_player
            grid.show_possible_selection(grid_pos)
            return
        elif selected_player != null:
            if selected_player.can_move_to(grid_pos):
                selected_player.move_to.rpc_id(1, grid.get_screen_pos(grid_pos))
                selected_player.grid_pos = grid_pos
                
            selected_player = null
            grid.clear_possible_selections()
            return
        else:
            selected_player = null
            grid.clear_possible_selections()
