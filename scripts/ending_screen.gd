class_name EndingScreen
extends CanvasLayer

@export var progress_bar_layer: ProgressBarLayer
@onready var reason_label: Label = $CenterContainer/VBoxContainer/ReasonLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton

func _ready():
	# Connect restart button
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Make sure the screen starts hidden
	visible = false

func show_ending(reason: String):
	progress_bar_layer.disable_progress()
	reason_label.text = reason
	visible = true
	
	# Pause the game
	get_tree().paused = true
	
	# Optional: Add fade-in animation
	#modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_restart_pressed():
	# Unpause the game
	get_tree().paused = false
	
	# Restart the current scene
	get_tree().reload_current_scene()
