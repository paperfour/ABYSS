extends AnimatedSprite2D

enum Modes {
	HIDDEN,
	IDLE,
	ALERT,
	ATTACK
}

var mode = Modes.HIDDEN


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_kill_zone_area_entered(area: Area2D) -> void:

	print(mode)

	if area.is_in_group("Light") and mode == Modes.HIDDEN:
		
		animation_player.play("emerge")
		mode = Modes.IDLE
