extends Node2D

@export_file var agent_file : String
    
func _ready():    
    var agent = load("res://scenes/simulation/agent.tscn")
    for i in range(200):        
        var agent_instance = agent.instantiate();
        add_child(agent_instance)
        agent_instance.rotate(randf_range(0,2*PI))
        agent_instance.position = Vector2( randi_range(0, get_viewport_rect().size.x), randi_range(0, get_viewport_rect().size.y))
