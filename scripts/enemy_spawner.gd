extends Node

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var spawn_position: Marker2D
@export var max_enemies: int = 5

var current_enemy_count: int = 0
var spawn_timer: float = 0.0
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

	# Initial spawn (optional)
	_spawn_enemy()

func _process(delta):
	if current_enemy_count < max_enemies:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			_spawn_enemy()
			spawn_timer = 0.0

func _spawn_enemy():
	if not enemy_scene or not spawn_position or not player_node:
		return

	var new_enemy_instance = enemy_scene.instantiate()
	new_enemy_instance.global_position = spawn_position.global_position
	# Set the player variable of the new enemy instance
	new_enemy_instance.player = player_node
	add_child(new_enemy_instance)
	current_enemy_count += 1
	enemies_in_scene.append(new_enemy_instance)
	
	new_enemy_instance.death.connect(_on_enemy_died)

func _on_enemy_died(enemy):
	print("dead")
	current_enemy_count -= 1
	enemies_in_scene.erase(enemy)
	# Optional: Spawn immediately on death
	#_spawn_enemy()
