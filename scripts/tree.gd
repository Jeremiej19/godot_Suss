extends StaticBody2D
class_name Log

@onready var pickupRangeShape: CollisionShape2D = $PickupRangeArea/PickupRangeShape

func disable_pickup_range():
	pickupRangeShape.disabled = true

func enable_pickup_range():
		pickupRangeShape.disabled = false
