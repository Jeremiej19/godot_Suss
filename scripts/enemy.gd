class_name Enemy
extends CharacterBody2D

signal death(enemy: Enemy)

@export var player: CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var max_health = 100
var current_health = max_health

var knockback = false
var knocback_velocity = Vector2(0 ,0)
var knockback_timer = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar

func _physics_process(delta: float) -> void:
	if !knockback && knockback_timer==0:
		var direction = (player.global_position - self.global_position).normalized()
		velocity = direction*SPEED
	
	if knockback_timer:
		velocity = knockback_timer * knocback_velocity
		knockback_timer -= 1
		knockback = false
	
	move_and_slide()

func take_damage(amount: int, knockback_amount: int) -> void:
	current_health -= amount
	if knockback_amount > 0:
		knocback_velocity = ((player.global_position - self.global_position).normalized() * -1) * knockback_amount
		knockback = true
		knockback_timer = 10
	print("hit: ", amount, " Current Health: ", current_health)
	
	if is_instance_valid(health_bar):
		print("update")
		health_bar.value = current_health

	if current_health <= 0:
		death.emit(self)
		queue_free() # Or handle enemy death in another way
