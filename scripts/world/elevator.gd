extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

## The string file name of the next level in the "levels" folder
@export var next_level: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_body_entered(_body: Node2D) -> void:
	timer.start()
	animated_sprite_2d.play("open")

const FILE_BEGIN = "res://scenes/levels/"

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file(FILE_BEGIN + next_level + ".tscn")
