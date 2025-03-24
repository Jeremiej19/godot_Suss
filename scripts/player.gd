extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const DECAY = 0.1
const push_force = 80

func update_animation(directionH, directionV):
	if directionH > 0:
		animated_sprite.flip_h = false
	elif directionH < 0:
		animated_sprite.flip_h = true
	
	if directionH == 0 and directionV == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionH:= Input.get_axis("move_left", "move_right")
	var directionV := Input.get_axis("move_up", "move_down")

	
	if directionH:
		velocity.x = directionH * SPEED
	else:
		velocity.x -= velocity.x * DECAY
	
	if directionV:
		velocity.y = directionV * SPEED
	else:
		velocity.y -= velocity.y * DECAY
		
	var attack = Input.get_action_strength("atack_right")
	
	if attack:
		animated_sprite.play("atack")

	update_animation(directionH, directionV)
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
