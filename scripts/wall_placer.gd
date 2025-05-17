extends Node2D
class_name WallPlacer

const POSITION_OFFSET = Vector2(127, -19)
const WALL_PRICE = 1

@onready var wall_segment_ghost: WallSegmentGhost = $WallSegmentGhost
@export var wall: Wall
@export var backpack: Backpack

func _ready() -> void:
	self.visible = false

func enable_builder() -> void:
	self.visible = true

func disable_builder() -> void:
	self.visible = false

func is_enabled() -> bool:
	return self.visible
	
func place() -> void:
	var cost_deducted = backpack.spend_logs(WALL_PRICE)
	if cost_deducted:
		wall.place_segment(wall_segment_ghost.global_position)

func get_ghost_position() -> Vector2:
	return wall_segment_ghost.global_position

func _on_player_move(position: Vector2) -> void:
	var grid_offset = Vector2(fmod(position[0], 64), fmod((position[1]), 64)) 
	wall_segment_ghost.global_position = position - grid_offset - POSITION_OFFSET
