extends Node2D

const MAX_PLAYERS_COUNT = 4

@export var host_scene: PackedScene
@export var host_root: Node2D
@export var player_managers: PlayerManagers
@export var grid: Grid
@export var host_spawner: MultiplayerSpawner
@export var hud : HUD
@export var shockwave_scene: PackedScene
@export var camera: Camera2D
@export var camera_drag = 25

signal p1_scored
signal p2_scored

var players = []
var hosts: Array[Host] = []
var player_index: int
var is_game_started: bool
var is_choice_step: bool
var is_game_over: bool = false
var selected_player: Player
var player_index_playing: int = -1
var selected_card_type: String

var saved_host_pos
var saved_player_pos
var saved_host

var respawn_timer = 0.3
var respawn_timer_max = respawn_timer

var shockwave = Shockwave

func _ready():
    if multiplayer and multiplayer.is_server():
        Immersive.client.peer_player_joined.connect(on_peer_player_joined)
        
        for player_character in player_managers.array:
            player_character.played.connect(on_player_played)
            
    host_spawner.spawn_function = spawn_host_client

    grid.cell_click.connect(on_cell_click)
    grid.wall_click.connect(on_wall_click)
    
    hud.hand.card_selected.connect(on_card_selected);
    
    if multiplayer and !multiplayer.is_server():
        shockwave = shockwave_scene.instantiate()
        camera.add_child(shockwave)
            
       
func _process(delta):
    if respawn_timer < respawn_timer_max:
        respawn_timer = respawn_timer + delta
        
        if respawn_timer >= respawn_timer_max:
            respawn_host()
    
    get_node("Camera2D").position = get_local_mouse_position()/camera_drag

func on_player_played():
    #check if a player is next to a host
    for player in player_managers.array[player_index_playing].player_characters:
        var host = check_octo_around_player(player)
        
        if host != null:
            saved_host_pos = grid.get_grid_pos(host.position)
            saved_player_pos = grid.get_grid_pos(player.position)
            saved_host = host
            
            player.parasited.connect(on_parasiting_done)
            
            player.shoot_your_shot(host.position)
            player.shoot_your_shot.rpc(host.position)
            
            #on attend 1 seconde avant de tout kill
            await get_tree().create_timer(1).timeout
            
        else:
            on_turn_done()

func on_parasiting_done():
    play_shockwave_anim.rpc(saved_host_pos)
    
    await get_tree().create_timer(1).timeout
    
    player_managers.array[player_index_playing].spawn_player(grid, saved_host_pos)
    player_managers.array[player_index_playing].kill_player(grid, saved_player_pos)
    
    hosts.erase(saved_host)
    saved_host.queue_free()
    
    if player_index_playing == 0:
        emit_signal("p1_scored")
    else:
        emit_signal("p2_scored")
    
    respawn_timer = 0
    
func respawn_host():
    spawn_host(Vector2(randi_range(-3,3), randi_range(-2,2)))
    await get_tree().create_timer(0.5).timeout
    on_turn_done()

func on_turn_done():
    player_index_playing = player_index_playing + 1 if player_index_playing < len(players) - 1 else 0
    
    for host in hosts:
        host.move_host(grid, player_managers)
        host.get_node("HostAnimationPlayer").play("idle")
    
    if hosts.is_empty():
        on_host_played()
        
    check_if_player_won()
    
func on_host_played():
    set_turn(player_index_playing)

func check_if_player_won():
    for host in hosts:
        var current_player_manager = player_managers.array[player_index_playing]
        for player in current_player_manager.player_characters:
            if(host.position == player.position):
                finish_game.rpc()


func set_turn(player_index: int):
    propagate_turn.rpc(player_index)
    
    for index in range(MAX_PLAYERS_COUNT):
        hud.player_cards[index].set_playing(player_index == index)
    
    player_index_playing = player_index

func is_player_active_turn():
    return player_index_playing == player_index

@rpc('authority')
func propagate_turn(player_index: int):
    player_index_playing = player_index

@rpc('authority')
func finish_game():
    hud.set_winning_label(is_player_active_turn())
    get_tree().get_root().get_node("BackgroundMusic/BGMusic").stream_paused = true
    if is_player_active_turn():
        get_node("Audio/Victory").play()
    else: get_node("Audio/Defeat").play()

    # on cache tout
    is_game_over = true
    player_managers.visible = false
    grid.visible = false

@rpc('any_peer')
func start_game():
    if multiplayer and multiplayer.is_server():
        propagate_start_game.rpc()
        is_game_started = true

        for player_index in range(MAX_PLAYERS_COUNT):
            if player_index > len(players) - 1:
                hud.player_cards[player_index].visible = false
            else:
                player_managers.array[player_index].spawn_initial_player(grid)

        spawn_host(Vector2(0, -1))
        set_turn(0)
        Immersive.client.starts_playing()

func spawn_host(grid_pos: Vector2):
    host_spawner.spawn(grid.get_screen_pos(grid_pos))
    
func spawn_host_client(position):
    if is_game_over:
        pass
    else: 
        var host = host_scene.instantiate()
        host.get_node("HostAnimationPlayer").play("spawn")
        host.position = position
        host.played.connect(on_host_played)
    
        hosts.append(host) 
    
        return host
    
    
@rpc('authority')
func assign_player(player_index: int):
    self.player_index = player_index
    hud.player_cards[player_index].assign()

@rpc('authority')
func give_start_game_permission():
    hud.player_cards[player_index].set_start_game_button_enabled(true)
    hud.player_cards[player_index].start_game_pressed.connect(request_start_game)

@rpc('authority')
func propagate_start_game():
    hud.player_cards[player_index].set_start_game_button_enabled(false)
    get_node("PlayerManagers/PlayerManager0").modulateFaceColor = get_node("HUD/ColorChoicePlayer1/HSlider").value

func request_start_game():
    start_game.rpc_id(1)

func on_peer_player_joined(id: int):
    var player_index = len(players)
    
    players.append(id)
    assign_player.rpc_id(id, player_index)
    hud.player_cards[player_index].set_connected()
    
    if player_index == 1:
        give_start_game_permission.rpc_id(players[0])

func move_player(player_index: int, action: String):
    if multiplayer and multiplayer.is_server():
        player_managers.array[player_index].process_action(action)

func on_cell_click(grid_pos: Vector2):
    if multiplayer and not multiplayer.is_server() and is_player_active_turn():
        if(selected_card_type != "Movement"):
            return
        var player_manager = player_managers.array[player_index]
        var found_player = player_manager.get_character_at_position(grid_pos, grid)

        if found_player != null:
            selected_player = found_player
            grid.show_possible_selection(grid_pos, player_managers)
            return
        elif selected_player != null:
            if selected_player.can_move_to(grid_pos, grid, player_managers):
                selected_player.move_to.rpc_id(1, grid.get_screen_pos(grid_pos))
                hud.hand.consume_selected_card()
                
            selected_player = null
            grid.clear_possible_selections()
            return
        else:
            selected_player = null
            grid.clear_possible_selections()

func on_wall_click(grid_pos: Vector2, tile_index: int):
    if multiplayer and not multiplayer.is_server():
        add_wall.rpc_id(1, grid_pos, tile_index)
        hud.hand.consume_selected_card()

@rpc('any_peer')
func add_wall(grid_pos: Vector2, tile_index: int):
    if multiplayer and multiplayer.is_server():
        grid.add_wall(grid_pos, tile_index)
        propagate_add_wall.rpc(grid_pos, tile_index)
        on_player_played()

@rpc('authority')
func propagate_add_wall(grid_pos: Vector2, tile_index: int):
    grid.add_wall(grid_pos, tile_index)

func check_tile(grid_pos:Vector2, check_players: bool):
    if check_players:
        for i in range(0, players.size()):
            var player_is_present = player_managers.check_for_player(grid, grid_pos)
            if player_is_present != null:
                return player_is_present
    
    for host in hosts:
        if host == null:
            hosts.erase(host)
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
    finish_game.rpc()
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
    
    shockwave.play_shockwave_anim(screen_ratio)

func on_card_selected(cardType : String):
    selected_card_type = cardType
