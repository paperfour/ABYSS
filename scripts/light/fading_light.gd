extends Node2D

@export var LIFETIME_FRAMES: int = 120
@export var FADING: bool = true
@export var DYING: bool = true

# The scale of the light
@export var MAX_SIZE: float = 1
@export var MIN_SIZE: float = 0


# Default is the max value
var size: float

# How many frames before the light reaches its minimum value and maybe dies
var frames_remaining: int



@onready var area_2d: Area2D = $Area2D

@onready var hitbox = CollisionShape2D.new()
const BB_RADIUS_DEFAULT = 70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	hitbox.shape = CircleShape2D.new()
	hitbox.shape.radius = BB_RADIUS_DEFAULT
	area_2d.add_child(hitbox)
	
	
	reset()
	
	if scale.x != 1 or scale.y != 1:
		print_debug("Careful! Make sure to chance the SIZE variable, too")

func _physics_process(_delta: float) -> void:
	
	if FADING and frames_remaining > 0:
	
		var i = frames_remaining / float(LIFETIME_FRAMES)
	
		frames_remaining -= 1
		
		setLightScale(i)
		
	else:
		if DYING and FADING:
			queue_free()


@onready var shadow_light: PointLight2D = $PointLight2DShadow
@onready var universal_light: PointLight2D = $PointLight2DAmbient

# Remember... s is between 1 and 0, where 1 is the MAX and 0 is the MIN	
func setLightScale(s: float):
	size = MIN_SIZE + sqrt(s) * (MAX_SIZE - MIN_SIZE)
	universal_light.texture_scale = size
	shadow_light.texture_scale = size
	hitbox.shape.radius = MAX_SIZE * BB_RADIUS_DEFAULT


# Reset light to a "just born" state
func reset():
	frames_remaining = LIFETIME_FRAMES
	setLightScale(1)	
