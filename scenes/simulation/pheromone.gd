extends Sprite2D

var lifetime = 10
var life = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    life += delta
    modulate.a = 1 - (life/lifetime)
    if(life >= lifetime):
        print("pheromone dead")
        queue_free()
