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
func propagate_turn(player_index: int):
    player_index_playing = player_index
    if is_player_active_turn():
        hud.hand.draw()

@rpc('authority')
func finish_game():
    hud.set_winning_label(is_player_active_turn())
    get_tree().get_root().get_node("BackgroundMusic/BGMusic").stream_paused = true
    if is_player_active_turn():
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
    return player_index_playing == player_index


func turn_indicator():
    if is_player_active_turn():
        background.material.set_shader_parameter("tint_color", Color(1,1,1,1))
        your_turn.visible = true
        other_player_turn.visible = false
    else:
        background.material.set_shader_parameter("tint_color", Color(1,0.3,0.3,1))
        your_turn.visible = false
        other_player_turn.visible = true

func on_cell_click(grid_pos: Vector2):
    if multiplayer and not multiplayer.is_server() and is_player_active_turn():
        if(grid.selected_card_type != "Movement"):
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

func on_card_selected(cardType : String):
    var rng = RandomNumberGenerator.new()
    card_selection_sound.pitch_scale = rng.randf_range(0.70,1.30)
    card_selection_sound.play()
    grid.selected_card_type = cardType

func _ready():
    grid.cell_click.connect(on_cell_click)
    hud.hand.card_selected.connect(on_card_selected);
    
func _process(delta):
    turn_indicator()
