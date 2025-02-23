extends Node2D

@onready var animation_player: AnimationPlayer = $Body/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.seek(randf_range(0, 1))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
