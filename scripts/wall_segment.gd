extends StaticBody2D
class_name WallSegment

@export var max_hp: int = 100
var current_hp: int

func _ready():
	current_hp = max_hp

func take_damage(amount: int) -> void:
	current_hp -= amount
	modulate = Color(1, 0.5, 0.5)  # Tint red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Reset

	if current_hp <= 0:
		die()

func die() -> void:
	queue_free()  # Or play animation, spawn debris, etc.
