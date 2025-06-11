extends Node2D
class_name Lvl

@onready var treeManager: TreeManager = $TreeManager
@onready var timer = $WaveTimer
@onready var progress_bar = $CanvasLayer/ProgressBar

# Store the initial wait time
var max_time = 0

var spawn_rect: Rect2 = Rect2(1250, -1100, 3000, 2150)
var trees_to_spawn: int = 100
var min_tree_distance: float = 100.0

func _ready() -> void:
	treeManager.spawn_trees(trees_to_spawn, spawn_rect, min_tree_distance)
	# Store the initial wait time when the scene starts
	max_time = timer.wait_time
	progress_bar.max_value = max_time
	progress_bar.value = max_time

func _process(delta):
	# Update the progress bar with the current time left
	progress_bar.value = timer.time_left
