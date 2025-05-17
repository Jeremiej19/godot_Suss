extends Node

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var spawn_position: Marker2D
@export var max_enemies: int = 5
@export var spawn_timer: Timer

var enemies_in_wave = 0
var current_enemy_count: int = 0
var enemies_in_scene: Array = []
var player_node: CharacterBody2D # Declare a variable to hold the player

func _ready():
	if not enemy_scene:
		printerr("Error: Enemy Scene not assigned in the Inspector!")
		set_process(false)
	if not spawn_position:
		printerr("Error: Spawn Position not assigned in the Inspector!")
		set_process(false)

	# Find the Player node in the scene
	player_node = get_node_or_null("/root/Game/Lvl1/Player") # Adjust the path if your Player is in a different location
	if not player_node:
		printerr("Error: Player node not found in the scene!")
		set_process(false)

func _spawn_enemy(position: Vector2):
	if not enemy_scene or not spawn_position or not player_node:
		return

	var new_enemy_instance = enemy_scene.instantiate()
	new_enemy_instance.global_position = position
	# Set the player variable of the new enemy instance
	new_enemy_instance.player = player_node
	add_child(new_enemy_instance)
	current_enemy_count += 1
	enemies_in_scene.append(new_enemy_instance)
	
	new_enemy_instance.death.connect(_on_enemy_died)

func _on_enemy_died(enemy):
	print("dead")
	current_enemy_count -= 1
	enemies_in_wave -= 1
	enemies_in_scene.erase(enemy)
	if enemies_in_wave == 0:
		spawn_timer.start()
	# Optional: Spawn immediately on death
	#_spawn_enemy()


func _on_spawn_timer_timeout() -> void:
	var nodes = get_tree().get_nodes_in_group("Spawn")
	enemies_in_wave = max_enemies
	for i in range(enemies_in_wave):
		var node = nodes[randi() % nodes.size()]
		var position = node.position
		_spawn_enemy(position)
