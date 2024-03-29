extends Node2D

class_name HostManager

@export var host_spawner: MultiplayerSpawner
@export var host_scene: PackedScene
@export var host_root: Node2D

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

        return host
        
func on_host_played():
    pass

func get_hosts():
    return host_root.get_children()
