class_name Warrior
extends CharacterBody2D

const SPEED = 350.0
const LOG_SPEED_MODIFIER = 0.8
const JUMP_VELOCITY = -400.0
const DECAY = 0.1
const push_force = 80
var attack_initiated = false
const DAMAGE := 50
const KNOCKBACK := 100

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var backpack = $Backpack

func update_animation(directionH, directionV):		
	if attack_initiated:
		return
		
	if directionH == 0 and directionV == 0:
		animation_tree.get("parameters/playback").travel("Idle")
	else:
		animation_tree.get("parameters/playback").travel("Run")
		run_handler(Vector2(directionH, 0))

func run_handler(anim_vector: Vector2) -> void:
	animation_tree.set("parameters/Run/BlendSpace2D/blend_position", anim_vector.normalized())
	state_machine.travel("Run")
		
func attack_handler() -> void:
	if Input.is_action_pressed("attack_right"):
		perform_attack(Vector2(1, 0))
	elif Input.is_action_pressed("attack_left"):
		perform_attack(Vector2(-1, 0))
	elif Input.is_action_pressed("attack_up"):
		perform_attack(Vector2(0, 1))
	elif Input.is_action_pressed("attack_down"):
		perform_attack(Vector2(0, -1))

func perform_attack(anim_vector: Vector2) -> void:
	attack_initiated = true
	animation_tree.set("parameters/Attack/BlendSpace2D/blend_position", anim_vector)
	state_machine.travel("Attack")
	
func pickup_handler() -> void:
	if Input.is_action_just_pressed("pickup"):
		print("pick")
		backpack.add_tree()
	elif Input.is_action_just_pressed("drop"):
		print("drop")
		backpack.remove_tree()

func _physics_process(delta: float) -> void:
	var directionH:= Input.get_axis("move_left", "move_right")
	var directionV := Input.get_axis("move_up", "move_down")
	
	var speed = calculate_speed()
	
	if directionH:
		velocity.x = directionH * speed
	else:
		velocity.x -= velocity.x * DECAY
	
	if directionV:
		velocity.y = directionV * speed
	else:
		velocity.y -= velocity.y * DECAY
		
	attack_handler()
	update_animation(directionH, directionV)
	move_and_slide()
	pickup_handler()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func calculate_speed():
	var tree_count = backpack.get_tree_count()
	return SPEED * LOG_SPEED_MODIFIER ** tree_count

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "attack" in anim_name:
		attack_initiated = false


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE, KNOCKBACK)
