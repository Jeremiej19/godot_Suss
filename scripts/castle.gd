extends StaticBody2D
class_name Castle

@export var max_hp: int = 500
@export var game: Node2D
var current_hp: int
var is_dead: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar

signal castle_destroyed

func _ready():
	current_hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = max_hp

func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	current_hp -= amount
	
	# Update health bar
	if health_bar:
		health_bar.value = current_hp
		
	# Visual feedback - tint red when damaged
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	# Check if castle should be destroyed
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	
	if collision_shape:
		collision_shape.disabled = true
	game.castle_destroyed()
	#get_tree().change_scene_to_file("res://scenes/game.tscn")

# Optional: Method to repair the castle
func repair(amount: int) -> void:
	if is_dead:
		return
		
	current_hp = min(current_hp + amount, max_hp)
	
	# Visual feedback for healing
	modulate = Color(0.5, 1, 0.5)  # Tint green
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
		# Update health bar
	if health_bar:
		health_bar.value = current_hp

# Optional: Get current health percentage for UI
func get_health_percentage() -> float:
	return float(current_hp) / float(max_hp)

# Optional: Check if castle is at full health
func is_full_health() -> bool:
	return current_hp >= max_hp
