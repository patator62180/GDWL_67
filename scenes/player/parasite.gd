extends Node2D

class_name Parasite

signal parasited

var target_pos: Vector2
var apogee_pos: Vector2
var start_pos: Vector2

var timer = 0.0
var timer_max = 0.5

var height = 200

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if timer < timer_max:
        timer = timer + delta
        
        self.position = _quadratic_bezier(start_pos, apogee_pos, target_pos, timer / timer_max)
        
        if timer >= timer_max:
            parasited.emit()
            queue_free()
    
func fly_to(position: Vector2):
    start_pos = self.position
    target_pos = position
    
    var mid_point = (start_pos + target_pos) / 2
    apogee_pos = mid_point + Vector2.UP * height
    
    timer = 0
    
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    
    var r = q0.lerp(q1, t)
    return r
