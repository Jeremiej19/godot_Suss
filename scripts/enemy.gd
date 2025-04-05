extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var max_health = 100
var current_health = max_health

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar

func _physics_process(delta: float) -> void:
	# Add the gravity.
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.


	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	print("hit: ", amount, " Current Health: ", current_health)
	
	if is_instance_valid(health_bar):
		print("update")
		health_bar.value = current_health

	if current_health <= 0:
		queue_free() # Or handle enemy death in another way
