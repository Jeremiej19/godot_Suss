class_name Warrior
extends CharacterBody2D

const SPEED = 350.0
const LOG_SPEED_MODIFIER = 0.6
const JUMP_VELOCITY = -400.0
const DECAY = 0.1
const push_force = 80
const DAMAGE := 50
const CHOP_DAMAGE := 50
const KNOCKBACK := 100

var attack_initiated = false
var nerbyLogs = []
var active_player = true

@export var max_hp: int = 20
var current_hp: int

var crosshair_texture = load("res://assets/cursors/crosshair.png")

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: PlayerCamera = $Camera2D
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var backpack = $Backpack
@onready var wall_placer: WallPlacer = $WallPlacer

signal move(position: Vector2)

func _ready():
	current_hp = max_hp

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
		if nerbyLogs.size() > 0:
			var closest_log = nerbyLogs.pop_front()
			var logAdded = backpack.add_log(closest_log)
			if !logAdded:
				nerbyLogs.append(closest_log)
		
	elif Input.is_action_just_pressed("drop"):
		var log: Log = backpack.pop_log()
		if log:
			log.reparent(self.get_parent())
			log.position = self.position
			log.enable_pickup_range()

func builder_handler() -> void:
	if Input.is_action_just_pressed("pickup"):
		wall_placer.place()
	elif Input.is_action_just_pressed("drop"):
		wall_placer.disable_builder()

func action_handler() -> void:
	if Input.is_action_just_pressed("build_mode"):
		wall_placer.enable_builder()
	if wall_placer.is_enabled():
		builder_handler()
	else:
		pickup_handler()

func _physics_process(delta: float) -> void:
	if not active_player: return
	
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
	action_handler()
	move.emit(self.global_position)
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func take_damage(amount: int) -> void:
	current_hp -= amount
	modulate = Color(1, 0.5, 0.5)  # Tint red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Reset

	if current_hp == 0:
		die()

func die() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func calculate_speed():
	var tree_count = backpack.get_tree_count()
	return SPEED * LOG_SPEED_MODIFIER ** tree_count

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "attack" in anim_name:
		attack_initiated = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage_knockback"):
		body.take_damage_knockback(DAMAGE, KNOCKBACK)

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("TreeAliveHitbox"):
		var treeNode2D = area.get_parent()
		if treeNode2D.has_method("take_chop_damage"):
			treeNode2D.take_chop_damage(CHOP_DAMAGE)	

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Log"):
		nerbyLogs.append(area.get_parent())

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("Log"):
		nerbyLogs.remove_at(nerbyLogs.find(area.get_parent()))
