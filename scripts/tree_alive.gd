extends Node2D
class_name TreeAlive

@onready var particles: CPUParticles2D = $CPUParticles2D

signal chopped(tree: TreeAlive)

var max_health = 100
var current_health = max_health

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerAttack"):
		particles.restart()

func take_chop_damage(damage: int):
	current_health = current_health - damage
	print("tree health: %s" % current_health)
	
	if current_health <= 0:
		chopped.emit(self)
		queue_free()
