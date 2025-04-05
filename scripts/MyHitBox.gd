class_name MyHitBox
extends Area2D

const DAMAGE := 50
const KNOCKBACK := 100

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
