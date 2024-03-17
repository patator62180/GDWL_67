extends Node2D

class_name Game

const MAX_PLAYERS_COUNT = 4

@export var player_managers: PlayerManagers
@export var host_manager: HostManager
@export var grid: Grid
@export var player_controller: PlayerController
@export var camera: Camera2D
@export var win_score: int = 3

signal player_scored(player_index : int, score : int)
signal game_finished(bool)

class PeerPlayer:
    var peer_id: int
    var nickname: String
    var color: float
    
    func _init(player_index: int, peer_id: int):
        self.peer_id = peer_id
        self.nickname = 'Player %d' % peer_id
        self.color = 1 if player_index == 0 else 0.5

var peer_players: Array[PeerPlayer] = []
var is_game_over: bool = false
var is_choice_step: bool
var player_index_playing: int = -1

var turn_state = TurnState.NONE

var player_scores: Array[int] = [0,0,0,0]

func _ready():
    if Mediator.instance.is_server():
        Mediator.instance.listen_peer_player_connection(on_peer_player_joined)
    
@rpc('any_peer')
func draw_for_turn():
    if Mediator.instance.is_server():
        end_turn()

@rpc('any_peer')
func end_player_turn():
    if Mediator.instance.is_server():
        end_turn()
    
@rpc('any_peer')
func end_player_turn_move(selected_player_index: int, grid_pos: Vector2):
    if Mediator.instance.is_server():
        var selected_player = player_managers.array[player_index_playing].player_characters[selected_player_index]
        selected_player.move_to(grid_pos)
        
        end_turn(true)

@rpc('any_peer')
func end_player_turn_place_wall(grid_pos: Vector2, tile_index: int):
    if Mediator.instance.is_server():
        grid.add_wall(grid_pos, tile_index)
        Mediator.instance.call_on_players(propagate_add_wall, grid_pos, tile_index)
        end_turn()

@rpc('any_peer')
func end_player_turn_hammer(grid_pos: Vector2):
    if Mediator.instance.is_server():
        #grid.add_wall(grid_pos, tile_index)
        var hammer_hits = grid.get_hammer_hits(grid_pos)
        #grid.break_walls(grid_pos, hammer_hits)
        
        grid.add_wall(grid_pos, hammer_hits[0])
        Mediator.instance.call_on_players(propagate_add_wall, grid_pos, hammer_hits[0])
        
        for i in range(grid.cardinal.size()):
            var direction = grid.cardinal[i]
            grid.add_wall(grid_pos + direction, hammer_hits[i+1])
            Mediator.instance.call_on_players(propagate_add_wall, grid_pos + direction, hammer_hits[i+1])
            
        end_turn()

@rpc('any_peer')
func update_nickname(player_index: int, nickname: String):
    if player_index <= len(peer_players) - 1:
        peer_players[player_index].nickname = nickname
        Mediator.instance.call_on_players(player_controller.update_connected_player, player_index, nickname, peer_players[player_index].color)

@rpc('any_peer')
func update_color(player_index: int, color: float):
    if player_index <= len(peer_players) - 1:
        peer_players[player_index].color = color
        player_managers.array[player_index].color = color
        Mediator.instance.call_on_players(player_controller.update_connected_player, player_index, peer_players[player_index].nickname, color)

@rpc("any_peer")
func set_win_score(new_win_score : int):
    win_score = new_win_score
    

func respawn_host():
    spawn_host(grid.get_suitable_spawn())
    
func end_turn(try_parasiting: bool = false):
    if turn_state == TurnState.PLAYER_TURN:
        turn_state = TurnState.AI_TURN
    
    elif turn_state == TurnState.AI_TURN:
        turn_state = TurnState.PLAYER_TURN
        
        player_index_playing = player_index_playing + 1
        if player_index_playing >= len(peer_players):
            player_index_playing = 0
    
    start_turn(try_parasiting)

func start_turn(try_parasiting: bool = false):
    #players start moving here on their turn
    Mediator.instance.call_on_players(player_controller.propagate_turn, player_index_playing, turn_state)
    
    match turn_state:
        TurnState.PLAYER_TURN:
            pass
        TurnState.AI_TURN:
            #wait for player moving
            await get_tree().create_timer(0.5).timeout
            
            #wait for parasiting
            if try_parasiting:
                if await try_parasiting():
                    return
            
            #move and wait hosts
            for host in host_manager.get_hosts():
                host.move_host(grid, player_managers)
            
            await get_tree().create_timer(0.5).timeout
            
            #give control back to next player
            end_turn()
            pass
            
func try_parasiting():
    var players = player_managers.array[player_index_playing].player_characters
    for i in range(0, players.size()):
        var player = players[i]
        var host = check_octo_around_player(player)
        
        if host != null:
            var host_pos = grid.get_grid_pos(host.position)
            var player_pos = grid.get_grid_pos(player.position)
            Mediator.instance.call_on_players(player.shoot_your_shot, host.position)

            await get_tree().create_timer(1).timeout
            
            player_managers.array[player_index_playing].spawn_player(grid, host_pos)
            player_managers.array[player_index_playing].kill_player(grid, player_pos)
            
            Mediator.instance.call_on_players(play_shockwave_anim, host_pos)
                        
            host.queue_free()
            
            if score_point():
                return end_game()
                
            respawn_host()
            
            await get_tree().create_timer(0.5).timeout

            #if await try_parasiting():
                #return true
            

func score_point():
    player_scores[player_index_playing] += 1
    player_scored.emit(player_index_playing, player_scores[player_index_playing])
    
    return player_scores[player_index_playing] == win_score

@rpc('any_peer')
func start_game():
    if Mediator.instance.is_server():
        turn_state = TurnState.PLAYER_TURN
        Mediator.instance.call_on_players(player_controller.propagate_start_game)

        for player_index in range(MAX_PLAYERS_COUNT):
            if player_index <= len(peer_players) - 1:
                player_managers.array[player_index].spawn_initial_player(grid)

        for i in range(0, 3):
            respawn_host()
        #spawn_host(Vector2(0, -1))

        turn_state = TurnState.PLAYER_TURN
        player_index_playing = 0
        
        start_turn()
        Immersive.client.starts_playing()

func spawn_host(grid_pos: Vector2):    
    if !is_game_over:
        host_manager.host_spawner.spawn(grid.get_screen_pos(grid_pos))
        
    
func request_start_game():
    Mediator.instance.call_on_server(start_game)

func on_peer_player_joined(id: int):
    var player_index = len(peer_players)
    var peer_player = PeerPlayer.new(player_index, id)
    
    peer_players.append(peer_player)
    Mediator.instance.call_on_player(id, player_controller.assign_player, player_index)
    player_managers.array[player_index].color = peer_player.color
    
    for peer_player_index in range(len(peer_players)):
        Mediator.instance.call_on_players(player_controller.update_connected_player, peer_player_index, peer_players[peer_player_index].nickname, peer_players[peer_player_index].color)
    
    if player_index == 1:
        if Mediator.instance.is_couch:
            start_game()
        else:
            Mediator.instance.call_on_player(peer_players[0].peer_id, player_controller.give_start_game_permission)

func move_player(player_index: int, action: String):
    if Mediator.instance.is_server():
        player_managers.array[player_index].process_action(action)

@rpc('authority')
func propagate_add_wall(grid_pos: Vector2, tile_index: int):
    grid.add_wall(grid_pos, tile_index)

@rpc('authority')
func propagate_break_wall(grid_pos: Vector2, hammer_hits: Array[int]):
    grid.break_walls(grid_pos, hammer_hits)

func check_tile(grid_pos:Vector2, check_players: bool, check_host_destination: bool):
    if check_players:
        for i in range(0, peer_players.size()):
            var player_is_present = player_managers.check_for_player(grid, grid_pos)
            if player_is_present != null:
                return player_is_present
    
    for host in host_manager.get_hosts():
        var host_grid_pos = grid.get_grid_pos(host.position)
        if (host_grid_pos == grid_pos):
            return host
        
        if check_host_destination:
            var host_target_grid_pos = host.get_target_grid_pos()
            if (host_target_grid_pos == grid_pos):
                return host
            
    return null

func check_octo_around_player(player: Player):
    var player_grid_pos = grid.get_grid_pos(player.position)
    
    for direction in grid.octo:
        var found_entity = check_tile(player_grid_pos + direction, false, false)

        if found_entity is Host:
            return found_entity as Host
        elif found_entity is Player:
            return null
            
    return null
    
func end_game():
    turn_state = TurnState.PLAYER_TURN    
    
    var player_winning_index = 0
    
    for i in range(player_scores.size()):
        if player_scores[i] == win_score:
            player_winning_index = i
    
    Mediator.instance.call_on_players(player_controller.propagate_end_game, player_winning_index)
    Immersive.client.end_game()
    
    return true

@rpc('authority') 
func play_shockwave_anim(saved_host_pos: Vector2):
    var screen_pos = check_tile(saved_host_pos, false, false).get_global_transform_with_canvas().get_origin()
    screen_pos.x = screen_pos.x + 50
    screen_pos.y = screen_pos.y + 50
    
    var screen_size = get_viewport_rect().size
    var screen_ratio = screen_pos
    screen_ratio.x = screen_ratio.x / screen_size.x
    screen_ratio.y = screen_ratio.y / screen_size.y
    
    camera.play_shockwave_anim(screen_ratio)
    
func finish_game(player_winning_index : int):
            
    game_finished.emit(player_winning_index == player_controller.player_index)
    
    get_tree().get_root().get_node("BackgroundMusic/BGMusic").stream_paused = true
    if player_winning_index == player_controller.player_index:
        camera.confetti_launcher.fire_confetti()

    # on cache tout
    is_game_over = true
    player_managers.visible = false
    grid.visible = false
    host_manager.visible = false
