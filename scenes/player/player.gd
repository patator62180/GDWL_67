extends Node2D

class_name Player

signal played
#signal parasited
signal parasite_throwed

var tile_size = 100

@export var is_moving = false

var grid_pos = Vector2.ZERO
var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO

var timer = 0.0
var timer_max = 0.5

@export var raycast: RayCast2D
@export var parasite_scene: PackedScene

func _ready():
    if !(self is Host) and not OS.has_feature('dedicated_server'):
        $NodeSprite/Face.material.set_shader_parameter("Shift_Hue", get_parent().get_parent().modulateFaceColor)

func move(direction):
    raycast.rotation = atan2(-direction.x, direction.y)
    raycast.force_raycast_update()
    
    if !raycast.is_colliding():
        position += direction * tile_size
        return true
    
    return false

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
        
    elif is_moving and %AnimationPlayer.get_current_animation() != "player_moving":
        %AnimationPlayer.play("player_moving")
        %AnimationPlayer.queue("idle")
        
func can_move_to(grid_pos: Vector2, grid: Grid, player_managers: PlayerManagers):
    var player_grid_pos = grid.get_grid_pos(self.position)
    var direction = grid_pos - player_grid_pos
    
    var is_possible_movement = grid.is_possible_movement(player_grid_pos, direction)
    var is_possible_tile = grid.is_possible_tile(grid_pos)
    
    return player_grid_pos.distance_to(grid_pos) <= 1 \
        and is_possible_movement \
        and is_possible_tile \
        and player_managers.check_for_player(grid, grid_pos) == null

func process_action(action: String):
    match action:
        "left":
            move(Vector2.LEFT)
        "right":
            move(Vector2.RIGHT)
        "up":
            move(Vector2.UP)
        "down":
            move(Vector2.DOWN)
       
@rpc("authority")     
func shoot_your_shot(position: Vector2):
    parasite_throwed.emit()
    var parasite = parasite_scene.instantiate() as Parasite
    #parasite.parasited.connect(on_parasited)
    get_parent().add_child(parasite)
    
    var offset = Vector2.ONE * tile_size / 2
    
    parasite.position = self.position + offset
    position = position + offset
    parasite.fly_to(position)

#func on_parasited():
    #parasited.emit()

    
