extends Control
class_name UIController

enum CursorMode {
	DEFAULT,
	CROSSHAIR
}

var crosshair_texture = load("res://assets/cursors/crosshair.png")

func change_cursor(cursorMode: CursorMode) -> void:
	if cursorMode == CursorMode.DEFAULT:
		Input.set_custom_mouse_cursor(null)
	
	if cursorMode == CursorMode.CROSSHAIR:
		Input.set_custom_mouse_cursor(
			crosshair_texture,
			Input.CURSOR_ARROW,
			Vector2(crosshair_texture.get_width()/2, crosshair_texture.get_height()/2)
		)
