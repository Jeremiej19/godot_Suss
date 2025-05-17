extends CharacterBody2D
class_name Arrow

const PIERCING = 1
const KNOCKBACK := 0
const DAMAGE := 50

var enemies_passed = 0 
var should_free = false 

func _physics_process(delta: float) -> void:
	move_and_slide()
	
func pierce() -> void:
	enemies_passed += 1
	if enemies_passed > PIERCING:
		queue_free()

func _on_arrow_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage_knockback"):
		body.take_damage_knockback(DAMAGE, KNOCKBACK)
		pierce()
