extends Area2D

@onready var timer: Timer = $Timer

const PLAYER = preload("res://scenes/player.tscn")


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("Player") and timer.is_stopped():
		timer.start()
	
func _on_timer_timeout() -> void:
	
	get_tree().reload_current_scene()
