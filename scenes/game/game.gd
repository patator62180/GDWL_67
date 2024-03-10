extends Node2D

const MAX_PLAYERS_COUNT = 4

@export var host_scene: PackedScene
@export var host_root: Node2D
@export var player_characters: Array[PlayerManager]
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
    grid.wall_click.connect(on_wall_click)

func on_player_played():
    #check if a player is next to a host
    for player in player_characters[player_index_playing].player_characters:
        var host = check_octo_around_player(player)
        
        if host != null:
            var host_grid_pos = grid.get_grid_pos(host.position)
            var player_grid_pos = grid.get_grid_pos(player.position)
            
            player_characters[player_index_playing].spawn_player(grid, host_grid_pos)
            player_characters[player_index_playing].kill_player(grid, player_grid_pos)
            #spawn_host()
    
    player_index_playing = player_index_playing + 1 if player_index_playing < len(players) - 1 else 0
    #if player_index_playing == 0:
    for host in hosts:
        host.move_after_players_turns()
    
    #todo make the AI movement take time
    set_turn(player_index_playing)

    check_if_player_won()

func check_if_player_won():
    for host in hosts:
        var current_player_manager = player_characters[player_index_playing]
        for player in current_player_manager.player_characters:
            if(host.position == player.position):
                finish_game.rpc()
                

func set_turn(player_index: int):
    propagate_turn.rpc(player_index)
    
    for index in range(MAX_PLAYERS_COUNT):
        $HUD.player_cards[index].set_playing(player_index == index)
    
    player_index_playing = player_index

func is_player_active_turn():
    return player_index_playing == player_index

@rpc('authority')
func propagate_turn(player_index: int):
    player_index_playing = player_index

@rpc('authority')
func finish_game():
    $HUD.set_winning_label(is_player_active_turn())

@rpc('any_peer')
func start_game():
    if multiplayer and multiplayer.is_server():
        propagate_start_game.rpc()
        is_game_started = true
        
        for player_index in range(MAX_PLAYERS_COUNT):
            if player_index > len(players) - 1:
                $HUD.player_cards[player_index].visible = false
            else:
                player_characters[player_index].spawn_initial_player(grid)
        
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
    $HUD.player_cards[player_index].assign()

@rpc('authority')
func give_start_game_permission():
    $HUD.player_cards[player_index].set_start_game_button_enabled(true)
    $HUD.player_cards[player_index].start_game_pressed.connect(request_start_game)

@rpc('authority')
func propagate_start_game():
    $HUD.player_cards[player_index].set_start_game_button_enabled(false)

func request_start_game():
    start_game.rpc_id(1)

func on_peer_player_joined(id: int):
    var player_index = len(players)
    
    players.append(id)
    assign_player.rpc_id(id, player_index)
    $HUD.player_cards[player_index].set_connected()
    
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
            if selected_player.can_move_to(grid_pos, grid):
                selected_player.move_to.rpc_id(1, grid.get_screen_pos(grid_pos))
                
            selected_player = null
            grid.clear_possible_selections()
            return
        else:
            selected_player = null
            grid.clear_possible_selections()

func on_wall_click(grid_pos: Vector2, tile_index: int):
    if multiplayer and not multiplayer.is_server():
        add_wall.rpc_id(1, grid_pos, tile_index)

@rpc('any_peer')
func add_wall(grid_pos: Vector2, tile_index: int):
    if multiplayer and multiplayer.is_server():
        grid.add_wall(grid_pos, tile_index)
        propagate_add_wall.rpc(grid_pos, tile_index)
        
@rpc('authority')
func propagate_add_wall(grid_pos: Vector2, tile_index: int):
    grid.add_wall(grid_pos, tile_index)
    
func check_for_player(grid_pos:Vector2, playerIndex: int):
    for player in player_characters[playerIndex].player_characters:
        var player_grid_pos = grid.get_grid_pos(player.position)
            
        if (player_grid_pos == grid_pos):
            return player
    
    return null
    
func check_tile(grid_pos:Vector2):
    for i in range(0, players.size()):
        var player_is_present = check_for_player(grid_pos, i)
        if player_is_present != null:
            return player_is_present
    
    for host in hosts:
        var host_grid_pos = grid.get_grid_pos(host.position)
        if (host_grid_pos == grid_pos):
            return host
            
    return null

func check_octo_around_player(player: Player):
    var player_grid_pos = grid.get_grid_pos(player.position)
    
    for direction in grid.octo:
        var found_entity = check_tile(player_grid_pos + direction)
        
        if found_entity is Host:
            return found_entity as Host
        elif found_entity is Player:
            return null
            
    return null
