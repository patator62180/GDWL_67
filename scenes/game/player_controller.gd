extends Node2D

class_name PlayerController

@export var hud : HUD
@export var game : Game
@export var player_managers: PlayerManagers
@export var grid: Grid
@export var host_scene: PackedScene
@export var lobby: Lobby

var player_index: int
var player_index_playing: int = -1
var selected_player: Player
var nickname: String
var color: float

var game_turn_state = TurnState.NONE

static var instance: PlayerController

@rpc('authority')
func give_start_game_permission():
    lobby.set_can_start_game()
    lobby.started_game.connect(game.request_start_game)

@rpc('authority')
func propagate_start_game():
    lobby.close()
    hud.hand.draw_multiple(2)

@rpc('authority')
func propagate_turn(player_index: int, game_turn_state):
    player_index_playing = player_index
    self.game_turn_state = game_turn_state
    
    if can_play():
        hud.hand.draw()
        hud.set_turn_label()

@rpc('authority')
func assign_player(player_index: int):
    self.player_index = player_index    
    if player_index != 0:
            lobby.win_score_container.visible = false

@rpc('authority')
func update_connected_player(player_index: int, nickname: String, color: float):
    lobby.update_connected_player(player_index, nickname, color)

    hud.player_cards[player_index].nickname = nickname
    hud.player_cards[player_index].color = color
    
    if player_index == self.player_index:
        lobby.nickname = nickname
        lobby.color = color

@rpc('authority')
func update_score(player_index: int, score: int):
    hud.player_cards[player_index].score = score
    
@rpc('authority')
func propagate_end_game(player_winning_index : int):
    game_turn_state = TurnState.GAME_OVER
    game.finish_game(player_winning_index)

func on_nickname_edited(nickname: String):
    Mediator.instance.call_on_server(game.update_nickname, player_index, nickname)

func on_color_changed(color: float):
    Mediator.instance.call_on_server(game.update_color, player_index, color)

func on_win_score_changed(new_win_score: int):
    Mediator.instance.call_on_server(game.set_win_score, new_win_score)

func is_player_active_turn():
    return player_index_playing == player_index

func can_play():
    return game_turn_state == TurnState.PLAYER_TURN and (Mediator.instance.is_couch or is_player_active_turn())

func on_cell_click(grid_pos: Vector2):
    if Mediator.instance.is_player() and can_play():
        if(grid.selected_card_type != "Movement"):
            return
            
        var player_manager = player_managers.array[player_index_playing]
        var found_player_index = player_manager.get_character_index_at_position(grid_pos, grid)
        
        if selected_player.can_move_to(grid_pos, grid, player_managers):
            Mediator.instance.call_on_server(game.end_player_turn_move, found_player_index, grid.get_screen_pos(grid_pos))
            hud.hand.consume_selected_card()
                
            selected_player = null
            grid.clear_possible_selections()

func on_wall_click(grid_pos: Vector2, tile_index: int):
    if Mediator.instance.is_player() and can_play():
        Mediator.instance.call_on_server(game.end_player_turn_place_wall, grid_pos, tile_index)
        hud.hand.consume_selected_card()

func on_hammer_click(grid_pos: Vector2):
    if Mediator.instance.is_player() and can_play():
        Mediator.instance.call_on_server(game.end_player_turn_hammer, grid_pos)
        hud.hand.consume_selected_card()
        
func on_card_selected(cardType : String):
    if cardType == "":
        grid.selected_card_type = ""
    
    if can_play():
        grid.selected_card_type = cardType
        
        if cardType == "Movement":
            selected_player = player_managers.array[player_index_playing].player_characters[0]
            grid.show_possible_selection(grid.get_grid_pos(selected_player.position), player_managers)

func on_card_draw():
    Mediator.instance.call_on_server(game.draw_for_turn)

func on_player_scored(player_index: int, score: int):
    Mediator.instance.call_on_players(update_score, player_index, score)
    
#func check_for_hosts(grid_pos: Vector2):
    #return game.host_manager.check_for_hosts(grid, grid_pos)
    
func is_tile_empty(grid_pos: Vector2):
    return game.check_tile(grid_pos, true, true) == null

func _ready():
    instance = self
    grid.cell_click.connect(on_cell_click)
    hud.hand.card_selected.connect(on_card_selected)
    hud.hand.draw_card_for_turn.connect(on_card_draw)
    grid.wall_click.connect(on_wall_click)
    grid.hammer_click.connect(on_hammer_click)
    lobby.nickname_edited.connect(on_nickname_edited)
    lobby.color_changed.connect(on_color_changed)
    lobby.win_score_changed.connect(on_win_score_changed)
    game.player_scored.connect(on_player_scored)


