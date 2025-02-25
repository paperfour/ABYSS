## A light that can have it's target set and will move to that target size
extends Node2D

@export var active = true

# The last used size, used for interpolation
var old_size: float = 1

# Default is the max value for both
@export var size: float = 1

# What value to move towards
@export var target_size: float = 0

@export var speed: float = 1


@onready var area_2d: Area2D = $Area2D

@onready var hitbox = CollisionShape2D.new()
const BB_RADIUS_DEFAULT = 70

var changed_recently = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	hitbox.shape = CircleShape2D.new()
	hitbox.shape.radius = BB_RADIUS_DEFAULT
	area_2d.add_child(hitbox)

func _physics_process(delta: float) -> void:

	
	if changed_recently > 0:
		changed_recently -= 1

	if size != target_size:
		
		var ds = speed * size ** 2 / (1 + changed_recently) * delta
		
		size = move_toward(size, target_size, ds)
		
		update_size()
		
	
	update_pulse()
	
# ======== PULSING =============

@onready var pulse_timer: Timer = $PulseTimer

var pulse_target: float = -1

func pulse(s: float, duration: float):
	
	speed = 3
	
	pulse_target = s
	pulse_timer.start(duration)

func _on_pulse_timer_timeout() -> void:
	pulse_target = -1
	
func update_pulse() -> void:
	
	if pulse_target == -1:
		return
	else:
		
		# The length of time to ease the pulse coming in and out
		var easing = 0.5
		
		var difference = pulse_target - target_size
		
		var pulsed_size: float
		
		if pulse_timer.wait_time - pulse_timer.time_left <= easing:		
			pulsed_size = target_size + difference * (1 - cos(PI / easing * (pulse_timer.wait_time - pulse_timer.time_left))) / 2
		elif pulse_timer.time_left <= easing:
			pulsed_size = target_size + difference * (1 - cos(PI / easing * pulse_timer.time_left)) / 2
		else:
			pulsed_size = pulse_target
		
		universal_light.texture_scale = pulsed_size
		shadow_light.texture_scale = pulsed_size
		hitbox.shape.radius = pulsed_size * BB_RADIUS_DEFAULT

# ============ GENERAL =====================

@onready var shadow_light: PointLight2D = $PointLight2DShadow
@onready var universal_light: PointLight2D = $PointLight2DAmbient
	
## Updates the size of the light
func update_size():
	universal_light.texture_scale = size
	shadow_light.texture_scale = size
	hitbox.shape.radius = size * BB_RADIUS_DEFAULT

func set_size(s: float, buffer: int):
	if (s > size):
		changed_recently = buffer
		size = s

func set_target_size(s: float):
	if (s != target_size):
		changed_recently = 15
		target_size = s
	
