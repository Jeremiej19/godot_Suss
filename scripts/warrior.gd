class_name Warrior
extends CharacterBody2D

const SPEED = 350.0
const LOG_SPEED_MODIFIER = 0.8
const JUMP_VELOCITY = -400.0
const DECAY = 0.1
const push_force = 80
var attack_initiated = false
const DAMAGE := 50
const CHOP_DAMAGE := 50
const KNOCKBACK := 100
const TOP_Z_INDEX = 10
const NORMAL_Z_INDEX = 1

enum CameraMode{
	WARRIOR,
	TOWER
}

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var backpack = $Backpack

var crosshair_texture = load("res://assets/cursors/crosshair.png")

var nerbyLogs = []
var in_tower_range = false
var in_tower = false

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
		print("drop")
		var log: Log = backpack.pop_log()
		if log:
			log.reparent(self.get_parent())
			log.position = self.position
			log.enable_pickup_range()
		
			
func tower_handler() -> void:
	if Input.is_action_just_pressed("enter") && in_tower_range:
		if in_tower:
			leave_tower()
			change_camera_mode(CameraMode.WARRIOR)
			change_cursor(CameraMode.WARRIOR)
		else:
			enter_tower()
			change_camera_mode(CameraMode.TOWER)
			change_cursor(CameraMode.TOWER)

func enter_tower() -> void:
	in_tower = true
	self.global_position = Vector2(260, -275)
	self.z_index = TOP_Z_INDEX
	animated_sprite.flip_h = true
	state_machine.travel("Idle")

	
func change_cursor(cameraMode: CameraMode) -> void:
	if cameraMode == CameraMode.WARRIOR:
		Input.set_custom_mouse_cursor(null)
	
	if cameraMode == CameraMode.TOWER:
		Input.set_custom_mouse_cursor(
			crosshair_texture,
			Input.CURSOR_ARROW,  # The cursor shape being replaced
			Vector2(crosshair_texture.get_width()/2, crosshair_texture.get_height()/2)  # Center of image
		)

func leave_tower() -> void:
	in_tower = false
	self.global_position = Vector2(400, -200)
	self.z_index = NORMAL_Z_INDEX
	animated_sprite.flip_h = false


func change_camera_mode(mode: CameraMode) -> void:
	if mode == CameraMode.TOWER:
		camera.zoom = Vector2(0.6, 0.6)
		camera.global_position = Vector2(0,0)
	
	if mode == CameraMode.WARRIOR:
		camera.zoom = Vector2(0.8, 0.8)
		camera.global_position = self.global_position

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
		
	if !in_tower:
		attack_handler()
		update_animation(directionH, directionV)
		move_and_slide()
		pickup_handler()
	tower_handler()
	
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

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("TreeAliveHitbox"):
		var treeNode2D = area.get_parent()
		if treeNode2D.has_method("take_chop_damage"):
			treeNode2D.take_chop_damage(CHOP_DAMAGE)	

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Log"):
		nerbyLogs.append(area.get_parent())
	if area.is_in_group("TowerEnterRange"):
		in_tower_range = true

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("Log"):
		nerbyLogs.remove_at(nerbyLogs.find(area.get_parent()))
	if area.is_in_group("TowerEnterRange"):
		in_tower_range = false
