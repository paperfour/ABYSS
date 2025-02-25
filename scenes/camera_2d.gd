extends Camera2D

var flip = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x += delta * sign(flip) * 5
	position.y += delta * sign(flip) * 5
	
	if (flip > 120):
		flip = -120
	else:
		flip += 1	
	
