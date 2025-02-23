extends CharacterBody2D

@onready var WalkSound = $WalkSound

@onready var upright_sprite: AnimatedSprite2D = $AnimatedSprites/Upright
@onready var jump_sprite: AnimatedSprite2D = $AnimatedSprites/Jump
@onready var crouch_transition_sprite: AnimatedSprite2D = $AnimatedSprites/CrouchTransition
@onready var crouch_sprite: AnimatedSprite2D = $AnimatedSprites/Crouch

@onready var arms_fixture: Node2D = $Arms
@onready var arms_bottom_sprite: AnimatedSprite2D = $Arms/ArmsBottom
@onready var arms_top_sprite: AnimatedSprite2D = $Arms/ArmsTop
@onready var arms_center: Marker2D = $Arms/ArmsCenter


@onready var area_test_stand: Area2D = $AreaTestStand

@onready var collision_shape_standing: CollisionShape2D = $CollisionShapeStanding
@onready var collision_shape_crouching: CollisionShape2D = $CollisionShapeCrouching

const light_path = preload("res://scenes/fading_light.tscn")


var stand_restricted = 0

var active_sprite := upright_sprite

const WALK_SPEED = 90.0
const CROUCH_SPEED = 60.0

const JUMP_VELOCITY = -200.0

var friction = 1

var crouching = false

var coyote_frames = 5

var step_cooldown = 100

var in_air = false

@onready var live_light: Node2D = $LiveLight

# Called when the object is loaded
func _ready() -> void:
	pass
	Engine.time_scale = 1


# Called as often as possible (delta isn't constant)
func _process(_delta: float) -> void:
	pass
	
	
# Called at a constant rate
func _physics_process(delta: float) -> void:
		
	# Add the gravity.
	if not is_on_floor():
		in_air = true
		coyote_frames = max(0, coyote_frames - 1)
		velocity += get_gravity() * delta
	else:
		if (in_air): 
			coyote_frames = 5
			
			live_light.set_size(1.5, 20)
		
		in_air = false
	
	# Handle crouch
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		if (crouching):
			if not stand_restricted:
				collision_shape_crouching.disabled = true
				collision_shape_standing.disabled = false
				set_crouch(false)
		else:
			collision_shape_standing.disabled = true
			collision_shape_crouching.disabled = false
			set_crouch(true)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_frames):
		
		set_active_sprite(jump_sprite)
		if crouching:
			jump_sprite.play("jump_crouch")
		else:
			jump_sprite.play("jump")
			
			
		velocity.y = JUMP_VELOCITY
		
		live_light.set_size(1.1, 15)

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	# 1st = -1, 2nd = 1, both/none = 0

	if direction > 0:
		for animated_sprite in [upright_sprite, jump_sprite, crouch_sprite, crouch_transition_sprite, arms_bottom_sprite, arms_top_sprite]:
			animated_sprite.scale.x = -1

	elif direction < 0:
		for animated_sprite in [upright_sprite, jump_sprite, crouch_sprite, crouch_transition_sprite, arms_bottom_sprite, arms_top_sprite]:
			animated_sprite.scale.x = 1

	# If there is a direction to go...
	if direction:
		
		if is_on_floor():
			live_light.size = move_toward(live_light.size, max(0.3 if crouching else 0.7, live_light.size), 0.5)

		
		velocity.x = direction * (CROUCH_SPEED if crouching else WALK_SPEED)		
		
		if upright_sprite.visible or crouch_sprite.visible:
			if crouching:
				crouch_sprite.play("walk")
			else:
				upright_sprite.play("walk")

		if not WalkSound.playing:
			WalkSound.play()
	# If there is no player movement
	else:
		
		live_light.set_target_size(0.25)
		
		if upright_sprite.visible or crouch_sprite.visible:
			if crouching:
				crouch_sprite.play("idle")
			else:
				upright_sprite.play("idle")
		

		velocity.x = move_toward(velocity.x, 0, 10.0)
		WalkSound.stop()
	
	point_at_mouse()
	move_and_slide()

func set_active_sprite(activate: AnimatedSprite2D):

	for deactivate in [upright_sprite, jump_sprite, crouch_sprite, crouch_transition_sprite]:
		deactivate.visible = false

	activate.visible = true
	active_sprite = activate
	
	
#===========CROUCHING==============
func set_crouch(active: bool):
	
	if(active == crouching):
		pass
	else:
		
		crouching = active
		set_active_sprite(crouch_transition_sprite)
		
		if active:
			crouch_transition_sprite.play("crouch")
		else:
			crouch_transition_sprite.play("uncrouch")
					
func _on_crouch_animation_finished() -> void:
	if crouch_transition_sprite.animation == "uncrouch":
		
		upright_sprite.frame = 0
		upright_sprite.play("idle")
		
		set_active_sprite(upright_sprite)
	else:
		
		crouch_sprite.play("idle")		
		set_active_sprite(crouch_sprite)

func _on_area_test_stand_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		stand_restricted += 1

func _on_area_test_stand_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		stand_restricted -= 1

#==============JUMPING==============
func _on_jump_animation_finished() -> void:
	if crouching:
		crouch_sprite.play("idle")
		set_active_sprite(crouch_sprite)
	else:
		upright_sprite.play("idle")		
		set_active_sprite(upright_sprite)

#=============DO THINGS FROM ANIMATION=============

func _on_jump_frame_changed() -> void:
	
	# Im not sure why the frame is changed before the sprite exists, but hey we're all human
	if typeof(jump_sprite) == TYPE_NIL:
		return

func _on_upright_frame_changed() -> void:
	
	if typeof(upright_sprite) == TYPE_NIL:
		return
		
	if upright_sprite.visible and upright_sprite.animation == "walk":
		if upright_sprite.frame == 1:
			arms_fixture.position = Vector2(0, 1)
		if upright_sprite.frame == 5:
			arms_fixture.position = Vector2(0, 0)
	
	if upright_sprite.visible and is_on_floor() and upright_sprite.animation == "walk" and (upright_sprite.frame == 0 or upright_sprite.frame == 4):
		live_light.set_size(0.75, 10)
		

func _on_crouch_transition_frame_changed() -> void:
	pass # Replace with function body.
	
func _on_crouch_frame_changed() -> void:
	
	if typeof(crouch_sprite) == TYPE_NIL:
		return
	
	if crouch_sprite.visible and is_on_floor() and crouch_sprite.animation == "walk" and (crouch_sprite.frame == 0 or crouch_sprite.frame == 4):
		live_light.set_size(0.35, 10)
		
# ========== MOUSE HANDLING =============

func point_at_mouse() -> void:
	
	var mouse_offset = arms_center.get_local_mouse_position()
	
	var angle = (atan2(mouse_offset.x * arms_bottom_sprite.scale.x, -mouse_offset.y) + PI)
	
	var frame = round(angle / (PI) * 8)
	
	arms_bottom_sprite.frame = frame
	
	arms_top_sprite.frame = frame
