class_name EnemyHurtBox
extends Area2D


func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: MyHitBox) -> void:
	if hitbox == null:
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.DAMAGE, hitbox.KNOCKBACK)
