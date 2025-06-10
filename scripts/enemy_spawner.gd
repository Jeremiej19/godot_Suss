extends Node

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 0.2 
@export var wave_timer: Timer
@export var spawn_enemy_timer: Timer

var max_enemies: int = 1
var wave_number: int = 0
var enemies_in_wave: int = 0
var enemies_to_spawn: int = 0
var current_enemy_count: int = 0
var enemies_in_scene: Array = []
@onready var player_node: CharacterBody2D
@export var castle_node: Castle
var spawn_points: Array = []

func _ready():
	if not enemy_scene:
		printerr("Error: Enemy Scene not assigned!")
		set_process(false)
	player_node = get_node_or_null("/root/Game/Lvl1/Player")
	if not player_node:
		printerr("Error: Player node not found!")
		set_process(false)
	if not castle_node:
		printerr("Error: Castle node not found!")
		set_process(false)
	spawn_points = get_tree().get_nodes_in_group("Spawn")
	if spawn_points.is_empty():
		printerr("No spawn points found!")
		set_process(false)
	
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	spawn_enemy_timer.timeout.connect(_on_spawn_enemy_timer_timeout)

func _start_next_wave():
	wave_number += 1
	max_enemies += wave_number
	enemies_in_wave = max_enemies
	enemies_to_spawn = max_enemies
	spawn_enemy_timer.start(spawn_interval)

func _on_wave_timer_timeout():
	_start_next_wave()

func _on_spawn_enemy_timer_timeout():
	if enemies_to_spawn > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		_spawn_enemy(spawn_point.position)
		enemies_to_spawn -= 1
		if enemies_to_spawn > 0:
			spawn_enemy_timer.start(spawn_interval)

func _spawn_enemy(position: Vector2):
	var new_enemy = enemy_scene.instantiate()
	new_enemy.global_position = position
	new_enemy.player = player_node
	new_enemy.castle = castle_node
	add_child(new_enemy)
	current_enemy_count += 1
	enemies_in_scene.append(new_enemy)
	new_enemy.death.connect(_on_enemy_died)

func _on_enemy_died(enemy):
	current_enemy_count -= 1
	enemies_in_wave -= 1
	enemies_in_scene.erase(enemy)
	if enemies_in_wave == 0:
		wave_timer.start() # Wait before next wave
