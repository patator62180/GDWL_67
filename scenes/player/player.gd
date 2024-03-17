extends Node2D

class_name Player

signal played
signal parasite_throwed

var tile_size = 100

@export var is_moving = false
@export var animation_player : AnimationPlayer

var grid_pos = Vector2.ZERO
var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO

var timer = 0.0
var timer_max = 0.5

@export var parasite_scene: PackedScene


var color: float = 0:
    set(value):
        if not OS.has_feature('dedicated_server'):
            $NodeSprite/Face.material.set_shader_parameter("Shift_Hue", value)

func _ready():
    pass

@rpc("any_peer")
func move_to(position: Vector2):
    if Mediator.instance.is_server():
        is_moving = true
        start_pos = self.position
        target_pos = position
        timer = 0
        
func _process(delta):
    if is_moving and multiplayer and multiplayer.is_server():
        self.position = lerp(start_pos, target_pos, timer/timer_max)
        timer += delta
        
        if timer >= timer_max:
            self.position = target_pos
            is_moving = false
            
            played.emit()
        
    elif is_moving and animation_player.get_current_animation() != "player_moving":
        animation_player.play("player_moving")
        animation_player.queue("idle")
        
func can_move_to(grid_pos: Vector2, grid: Grid, player_managers: PlayerManagers):
    var player_grid_pos = grid.get_grid_pos(self.position)
    var direction = grid_pos - player_grid_pos
    
    var is_possible_movement = grid.is_possible_movement(player_grid_pos, direction)
    var is_possible_tile = grid.is_possible_tile(grid_pos)
    
    return player_grid_pos.distance_to(grid_pos) <= 1 \
        and is_possible_movement \
        and is_possible_tile \
        and PlayerController.instance.is_tile_empty(grid_pos)
        #and player_managers.check_for_player(grid, grid_pos) == null \
        #and !PlayerController.instance.check_for_hosts(grid_pos)
       
@rpc("authority")     
func shoot_your_shot(position: Vector2):
    parasite_throwed.emit()
    var parasite = parasite_scene.instantiate() as Parasite
    get_parent().add_child(parasite)
    
    var offset = Vector2.ONE * tile_size / 2
    
    parasite.position = self.position + offset
    position = position + offset
    parasite.fly_to(position)


@rpc("authority")
func kill_player():
    animation_player.play('death')

func get_target_grid_pos():
    return Grid.instance.get_grid_pos(target_pos)   
