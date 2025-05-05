extends Node2D
class_name Lvl

@onready var treeManager: TreeManager = $TreeManager

var spawn_rect: Rect2 = Rect2(1250, -1100, 3000, 2150)
var trees_to_spawn: int = 100
var min_tree_distance: float = 100.0

func _ready() -> void:
	treeManager.spawn_trees(trees_to_spawn, spawn_rect, min_tree_distance)
