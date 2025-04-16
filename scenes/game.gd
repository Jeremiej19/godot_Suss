extends Node2D

@export var start_scene:String
var current_level:Node2D

func _ready() -> void:
	current_level=load(start_scene).instantiate()
	$Levels.add_child(current_level)
