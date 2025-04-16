extends Node
class_name GameController

func _ready() -> void:
	Global.game_controller = self

var game : Node2D
@export var game_scene : String

func _on_Game_starting():
	game=load(game_scene).instance()
	add_child(game)
