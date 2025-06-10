extends Node2D
class_name WallPlacer

const POSITION_OFFSET = Vector2(127, -19)
const WALL_PRICE = 1
const GATE_PRICE = 1

enum SegmentType { WALL, GATE }

@onready var wall_segment_ghost: WallSegmentGhost = $WallSegmentGhost
@onready var gate_segment_ghost: GateSegmentGhost = $GateSegmentGhost
@export var wall: Wall
@export var backpack: Backpack

var current_segment_type: SegmentType = SegmentType.WALL

func _ready() -> void:
	self.visible = false
	_set_active_ghost(SegmentType.WALL)

func enable_builder() -> void:
	self.visible = true

func disable_builder() -> void:
	self.visible = false

func is_enabled() -> bool:
	return self.visible

func switch_segment_type():
	if current_segment_type == SegmentType.WALL:
		current_segment_type = SegmentType.GATE
	else:
		current_segment_type = SegmentType.WALL
	_set_active_ghost(current_segment_type)

func _set_active_ghost(segment_type: SegmentType) -> void:
	wall_segment_ghost.visible = (segment_type == SegmentType.WALL)
	gate_segment_ghost.visible = (segment_type == SegmentType.GATE)

func place() -> void:
	match current_segment_type:
		SegmentType.WALL:
			if backpack.spend_logs(WALL_PRICE):
				wall.place_segment(wall_segment_ghost.global_position, Wall.SegmentType.WALL)
		SegmentType.GATE:
			if backpack.spend_logs(GATE_PRICE):
				wall.place_segment(gate_segment_ghost.global_position, Wall.SegmentType.GATE)

func get_ghost_position() -> Vector2:
	match current_segment_type:
		SegmentType.WALL:
			return wall_segment_ghost.global_position
		SegmentType.GATE:
			return gate_segment_ghost.global_position
	return Vector2(0, 0)

func _on_player_move(position: Vector2) -> void:
	var grid_offset = Vector2(fmod(position[0], 64), fmod(position[1], 64))
	match current_segment_type:
		SegmentType.WALL:
			wall_segment_ghost.global_position = position - grid_offset - POSITION_OFFSET
		SegmentType.GATE:
			gate_segment_ghost.global_position = position - grid_offset - POSITION_OFFSET
