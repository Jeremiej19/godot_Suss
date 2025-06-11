extends CanvasLayer
class_name ProgressBarLayer

@onready var progress_bar: ProgressBar = $ProgressBar

func disable_progress():
	progress_bar.visible = 0
