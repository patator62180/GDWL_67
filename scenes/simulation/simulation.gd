extends Node2D

@export_file var agent_file : String
    
func _ready():    
    var agent = load("res://scenes/simulation/agent.tscn")
    for i in range(100):        
        var agent_instance = agent.instantiate();
        add_child(agent_instance)
        agent_instance.rotate(randf_range(0,2*PI))
        agent_instance.position = get_viewport_rect().size/2
    
func _process(delta):
    var sprite2d = $Sprite2D as Sprite2D
    sprite2d.material.set_shader_parameter("delta_time", delta)
    sprite2d.texture
    
    for agent in get_children():
        agent.position += agent.transform.x * delta * 100
        agent.position.x = fmod(agent.position.x,get_viewport_rect().size.x)
        agent.position.y = fmod(agent.position.y, get_viewport_rect().size.y)
