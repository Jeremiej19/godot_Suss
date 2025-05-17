class_name Enemy
extends CharacterBody2D

enum MobState {
	IDLE,
	CHASING,
	ATTACKING,
	DEATH
}

signal death(enemy: Enemy)

@export var player: CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var max_health = 100
var current_health = max_health

var knockback = false
var knocback_velocity = Vector2(0 ,0)
var knockback_timer = 0

var current_state
var dmg_bodies_count = 0

@onready var animated_sprite: AnimatedSprite2D = $Anim
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_area: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready():
	current_state = MobState["CHASING"]
	attack_area.disabled = true

func _physics_process(delta: float) -> void:
	match current_state:
			MobState.IDLE:
				animated_sprite.play("default")
				self.velocity = Vector2(0,0)
			MobState.CHASING:
				animated_sprite.play("default")
				if !knockback && knockback_timer==0:
					var direction = (player.global_position - self.global_position).normalized()
					velocity = direction*SPEED
			MobState.ATTACKING:
				animated_sprite.play("attack")
				self.velocity = Vector2(0,0)
			MobState.DEATH:
				death.emit(self)
				self.queue_free()
					
	if knockback_timer:
		velocity = knockback_timer * knocback_velocity
		knockback_timer -= 1
		knockback = false
	
	move_and_slide()

func take_damage_knockback(amount: int, knockback_amount: int) -> void:
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
		current_state = MobState["DEATH"]


func _on_attack_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("WallSegment") || body.is_in_group("Player"):
		print("wall")
		dmg_bodies_count += 1
		current_state = MobState["ATTACKING"]

func _on_attack_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("WallSegment") || body.is_in_group("Player"):
		dmg_bodies_count -= 1
		if dmg_bodies_count == 0:
			print("chase")
			current_state = MobState["CHASING"]
			attack_area.disabled = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("WallSegment"):
		print("wall dmg")
		body.take_damage(20)
	if body.is_in_group("Player"):
		print("player dmg")
		body.take_damage(20)

func _on_anim_frame_changed() -> void:
	if current_state == MobState["ATTACKING"]:
		if animated_sprite.frame == 1:
			attack_area.disabled = false
		if animated_sprite.frame == 2:
			attack_area.disabled = true
