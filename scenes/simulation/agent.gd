extends Sprite2D

var last_pheromone = Time.get_unix_time_from_system()
var pheromone_delay = randf_range(1 , 2.5)

func _process(delta):    
    position += transform.x * delta * 10
    position.x = fmod(position.x,get_viewport_rect().size.x)
    position.y = fmod(position.y, get_viewport_rect().size.y)

    sense_and_rotate()

    if(Time.get_unix_time_from_system() > last_pheromone + pheromone_delay):
        var pheromone_scene = load("res://scenes/simulation/pheromone.tscn")
        var pheromone = pheromone_scene.instantiate()        
        get_parent().add_child(pheromone)
        pheromone.position = position
        last_pheromone = Time.get_unix_time_from_system()

func sense_and_rotate():
    $RayCast2D_Froward.force_raycast_update()
    if $RayCast2D_Froward.is_colliding():
        return
    
    $RayCast2D_Left.force_raycast_update()    
    if $RayCast2D_Left.is_colliding():
        rotate(-PI/4.0)
        
    $RayCast2D_Right.force_raycast_update()    
    if $RayCast2D_Right.is_colliding():
        rotate(PI/4.0)
