extends Node2D
class_name Wall

# Preload both segment scenes
@onready var wall_segment_scene = preload("res://scenes/wall_segment.tscn")
@onready var gate_segment_scene = preload("res://scenes/gate_segment.tscn")

enum SegmentType { WALL, GATE }

func place_segment(position: Vector2, segment_type: SegmentType = SegmentType.WALL) -> void:
	var new_segment: Node2D
	match segment_type:
		SegmentType.WALL:
			new_segment = wall_segment_scene.instantiate()
		SegmentType.GATE:
			new_segment = gate_segment_scene.instantiate()
		_:
			push_error("Unknown segment type!")
			return
	new_segment.global_position = position
	self.add_child(new_segment)
