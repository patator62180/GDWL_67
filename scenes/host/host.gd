extends Player

class_name Host

func move_after_players_turns():
    var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
    
    directions.shuffle()
    
    for direction in directions:
        if move(direction):
            break

