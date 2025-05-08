extends StaticBody2D
class_name Tower

const TOP_Z_INDEX = 10
const NORMAL_Z_INDEX = 1
const SPEED = 1000
const TOWER_CENTER = Vector2(250, -250)

@onready var camera: TowerCamera = $TowerCamera

var arrow_scene = preload("res://scenes/arrow.tscn")

var player: Warrior
var ui_controller: UIController

var is_player_in_range = false
var is_player_in_tower = false
var active_player = false

func _ready() -> void:
	var parent = get_parent()
	player = parent.get_node("Player")
	ui_controller = parent.get_node("UIController")

func _process(delta: float) -> void:
	if not active_player: return
	
	if Input.is_action_just_pressed("shoot"):
		shoot(camera.get_global_mouse_position())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter") && is_player_in_range:
		if is_player_in_tower:
			player_sprite_leave_tower()
			player.active_player = true
			active_player = false
			is_player_in_tower = false
			player.camera.make_current()
			ui_controller.change_cursor(UIController.CursorMode.DEFAULT)
		else:
			player_sprite_enter_tower()
			player.active_player = false
			active_player = true
			is_player_in_tower = true
			camera.make_current()
			ui_controller.change_cursor(UIController.CursorMode.CROSSHAIR)		

func shoot(mouse_position: Vector2) -> void:
	var arrow = arrow_scene.instantiate()
	arrow.global_position =  Vector2(430, -280)
	var direction = (mouse_position - TOWER_CENTER).normalized()
	arrow.velocity = direction * SPEED
	arrow.rotation = direction.angle()
	get_parent().add_child(arrow)

func player_sprite_enter_tower() -> void:
	player.global_position = Vector2(260, -275)
	player.z_index = TOP_Z_INDEX
	player.animated_sprite.flip_h = true
	player.state_machine.travel("Idle")
	player.velocity.x = 0
	player.velocity.y = 0

func player_sprite_leave_tower() -> void:
	player.global_position = Vector2(400, -200)
	player.z_index = NORMAL_Z_INDEX
	player.animated_sprite.flip_h = false

func _on_tower_enter_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = true

func _on_tower_enter_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false
