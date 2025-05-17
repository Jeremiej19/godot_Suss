extends Node2D
class_name Wall

@onready var wall_segment = preload("res://scenes/wall_segment.tscn")

func place_segment(position: Vector2) -> void:
	var new_segment = wall_segment.instantiate()
	new_segment.global_position = position
	self.add_child(new_segment)
