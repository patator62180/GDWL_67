extends Node2D

class_name HostManager

@export var host_spawner: MultiplayerSpawner
@export var host_scene: PackedScene
@export var host_root: Node2D

var hosts: Array[Host] = []

# Called when the node enters the scene tree for the first time.
func _ready():
    host_spawner.spawn_function = spawn_host_client

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func spawn_host_client(position):
        var host = host_scene.instantiate()
        host.position = position
        host.played.connect(on_host_played)
    
        hosts.append(host) 
    
        return host
        
func on_host_played():
    pass

func check_for_hosts(grid: Grid, grid_pos:Vector2):
    for host in hosts:
        if host == null:
            hosts.erase(host)
            continue
            
        var host_grid_pos = grid.get_grid_pos(host.position)

        if (host_grid_pos == grid_pos):
            return true
    
    return false
