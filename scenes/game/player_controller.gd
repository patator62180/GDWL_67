extends Node2D

class_name PlayerController

@export var hud : HUD
@export var game : Game
@export var player_managers: PlayerManagers
@export var grid: Grid
@export var host_scene: PackedScene
@export var background: Sprite2D
@export var your_turn: TextEdit
@export var other_player_turn: TextEdit
@export var defeat_sound: AudioStreamPlayer
@export var victory_sound: AudioStreamPlayer
@export var card_selection_sound: AudioStreamPlayer
@export var horizontal_slider: HSlider

var player_index: int
var player_index_playing: int = -1
var is_game_over: bool = false
var selected_player: Player

var game_turn_state = TurnState.NONE

@rpc('authority')
func give_start_game_permission():
    hud.player_cards[player_index].set_start_game_button_enabled(true)
    hud.player_cards[player_index].start_game_pressed.connect(game.request_start_game)

@rpc('authority')
func propagate_start_game():
    hud.player_cards[player_index].set_start_game_button_enabled(false)
    player_managers.array[0].modulateFaceColor = horizontal_slider.value
    hud.hand.draw_multiple(2)

@rpc('authority')
func propagate_turn(player_index: int, game_turn_state):
    player_index_playing = player_index
    self.game_turn_state = game_turn_state
    
    if can_play():
        hud.hand.draw()

@rpc('authority')
func finish_game():
    hud.set_winning_label(can_play())
    get_tree().get_root().get_node("BackgroundMusic/BGMusic").stream_paused = true
    if can_play():
        victory_sound.play()
    else: 
        defeat_sound.play()

    # on cache tout
    is_game_over = true
    player_managers.visible = false
    grid.visible = false

@rpc('authority')
func assign_player(player_index: int):
    self.player_index = player_index
    hud.player_cards[player_index].assign()
    

func is_player_active_turn():
    return player_index_playing == player_index and game_turn_state == TurnState.PLAYER_TURN

func can_play():
    return Mediator.instance.is_couch or is_player_active_turn()

func turn_indicator():
    if can_play():
        background.material.set_shader_parameter("tint_color", Color(1,1,1,1))
        your_turn.visible = true
        other_player_turn.visible = false
    else:
        background.material.set_shader_parameter("tint_color", Color(1,0.3,0.3,1))
        your_turn.visible = false
        other_player_turn.visible = true

func on_cell_click(grid_pos: Vector2):
    if Mediator.instance.is_player() and can_play():
        if(grid.selected_card_type != "Movement"):
            return
            
        var player_manager = player_managers.array[player_index_playing]
        var found_player = player_manager.get_character_at_position(grid_pos, grid)
        var found_player_index = player_manager.get_character_index_at_position(grid_pos, grid)
        
        if found_player != null:
            selected_player = found_player
            grid.show_possible_selection(grid_pos, player_managers)
            return
        elif selected_player != null:
            if selected_player.can_move_to(grid_pos, grid, player_managers):
                Mediator.instance.call_on_server(game.end_player_turn_move, found_player_index, grid.get_screen_pos(grid_pos))
                hud.hand.consume_selected_card()
                
            selected_player = null
            grid.clear_possible_selections()
            return
        else:
            selected_player = null
            grid.clear_possible_selections()

func on_wall_click(grid_pos: Vector2, tile_index: int):
    if Mediator.instance.is_player() and can_play():
        Mediator.instance.call_on_server(game.end_player_turn_place_wall, grid_pos, tile_index)
        hud.hand.consume_selected_card()

func on_card_selected(cardType : String):
    var rng = RandomNumberGenerator.new()
    card_selection_sound.pitch_scale = rng.randf_range(0.70,1.30)
    card_selection_sound.play()
    grid.selected_card_type = cardType

func on_card_draw():
    Mediator.instance.call_on_server(game.draw_for_turn)

func _ready():
    grid.cell_click.connect(on_cell_click)
    hud.hand.card_selected.connect(on_card_selected)
    hud.hand.draw_card_for_turn.connect(on_card_draw)
    grid.wall_click.connect(on_wall_click)
    
func _process(delta):
    turn_indicator()
