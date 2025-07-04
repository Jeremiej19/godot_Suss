extends Camera2D
class_name PlayerCamera

@export var tilemap: TileMapLayer

func _ready() -> void:
	var mapRect = tilemap.get_used_rect()
	var tileSize = tilemap.tile_set.tile_size
	var worldSizeInPixels = mapRect.size * tileSize
	limit_right = worldSizeInPixels.x + limit_left
	limit_bottom = worldSizeInPixels.y + limit_top
	self.zoom = Vector2(0.8, 0.8)
