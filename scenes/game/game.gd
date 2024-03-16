extends Node2D

class_name Game

const MAX_PLAYERS_COUNT = 4

@export var lobby: Lobby
@export var player_managers: PlayerManagers
@export var host_manager: HostManager
@export var grid: Grid
@export var hud : HUD
@export var player_controller: PlayerController
@export var camera: Camera2D

signal p1_scored
signal p2_scored
signal game_finished(bool)
signal game_started

var players = []
var is_game_started: bool
var is_game_over: bool = false
var is_choice_step: bool
var player_index_playing: int = -1

var respawn_timer = 0.3
var respawn_timer_max = respawn_timer

var shockwave = Shockwave

var turn_state = TurnState.NONE

func _ready():
    if Mediator.instance.is_server():
        Mediator.instance.listen_peer_player_connection(on_peer_player_joined)

func _process(delta):
    if respawn_timer < respawn_timer_max:
        respawn_timer = respawn_timer + delta
        
        if respawn_timer >= respawn_timer_max:
            respawn_host()
    
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
    
func respawn_host():
    spawn_host(Vector2(randi_range(-3,3), randi_range(-2,2)))

func check_if_player_won():
    for host in host_manager.hosts:
        var current_player_manager = player_managers.array[player_index_playing]
        for player in current_player_manager.player_characters:
            if(host.position == player.position):
                Mediator.instance.call_on_players(player_controller.finish_game)
    
func end_turn(try_parasiting: bool = false):
    if turn_state == TurnState.PLAYER_TURN:
        turn_state = TurnState.AI_TURN
    
    elif turn_state == TurnState.AI_TURN:
        turn_state = TurnState.PLAYER_TURN
        
        player_index_playing = player_index_playing + 1
        if player_index_playing >= len(players):
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
                await try_parasiting()
            
            #move and wait hosts
            for host in host_manager.hosts:
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
            
            if player_index_playing == 0:
                emit_signal("p1_scored")
            else:
                emit_signal("p2_scored")
            
            player_managers.array[player_index_playing].spawn_player(grid, host_pos)
            player_managers.array[player_index_playing].kill_player(grid, player_pos)
            
            host_manager.hosts.erase(host)
            host.queue_free()
            
            respawn_host()
            
            await get_tree().create_timer(0.5).timeout

@rpc('any_peer')
func start_game():
    if Mediator.instance.is_server():
        turn_state = TurnState.PLAYER_TURN
        Mediator.instance.call_on_players(player_controller.propagate_start_game)
        is_game_started = true
        game_started.emit()

        for player_index in range(MAX_PLAYERS_COUNT):
            if player_index > len(players) - 1:
                hud.player_cards[player_index].visible = false
                get_node("HUD/PlayerCards").visible = false
            else:
                player_managers.array[player_index].spawn_initial_player(grid)

        spawn_host(Vector2(0, -1))

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
    var player_index = len(players)
    
    players.append(id)
    Mediator.instance.call_on_player(id, player_controller.assign_player, player_index)
    hud.player_cards[player_index].set_connected()
    
    if player_index == 1:
        Mediator.instance.call_on_player(players[0], player_controller.give_start_game_permission)

func move_player(player_index: int, action: String):
    if Mediator.instance.is_server():
        player_managers.array[player_index].process_action(action)


@rpc('authority')
func propagate_add_wall(grid_pos: Vector2, tile_index: int):
    grid.add_wall(grid_pos, tile_index)

func check_tile(grid_pos:Vector2, check_players: bool):
    if check_players:
        for i in range(0, players.size()):
            var player_is_present = player_managers.check_for_player(grid, grid_pos)
            if player_is_present != null:
                return player_is_present
    
    for host in host_manager.hosts:
        if host == null:
            host_manager.hosts.erase(host)
            continue
        var host_grid_pos = grid.get_grid_pos(host.position)
        if (host_grid_pos == grid_pos):
            return host

    return null

func check_octo_around_player(player: Player):
    var player_grid_pos = grid.get_grid_pos(player.position)
    
    for direction in grid.octo:
        var found_entity = check_tile(player_grid_pos + direction, false)

        if found_entity is Host:
            return found_entity as Host
        elif found_entity is Player:
            return null
            
    return null

func _on_score_card_score_atteint():
    Mediator.instance.call_on_players(player_controller.finish_game)
    Immersive.client.end_game()

@rpc('authority') 
func play_shockwave_anim(saved_host_pos: Vector2):
    var screen_pos = check_tile(saved_host_pos, false).get_global_transform_with_canvas().get_origin()
    screen_pos.x = screen_pos.x + 50
    screen_pos.y = screen_pos.y + 50
    
    var screen_size = get_viewport_rect().size
    var screen_ratio = screen_pos
    screen_ratio.x = screen_ratio.x / screen_size.x
    screen_ratio.y = screen_ratio.y / screen_size.y
    
    camera.play_shockwave_anim(screen_ratio)
    
func finish_game():
    game_finished.emit(player_controller.can_play())
    get_tree().get_root().get_node("BackgroundMusic/BGMusic").stream_paused = true

    # on cache tout
    is_game_over = true
    player_managers.visible = false
    grid.visible = false
