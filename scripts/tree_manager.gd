extends Node2D
class_name TreeManager

# Preload the log scene
var log_scene = preload("res://scenes/log.tscn")
var tree_scene = preload("res://scenes/tree_alive.tscn")

# Connect to all tree signals in the scene
func connect_to_trees():
	for tree in get_tree().get_nodes_in_group("TreeAlive"):
		if !tree.chopped.is_connected(_on_tree_chopped):
			tree.chopped.connect(_on_tree_chopped)

# Register a new tree (call this when spawning trees dynamically)
func register_tree(tree):
	if !tree.chopped.is_connected(_on_tree_chopped):
		tree.chopped.connect(_on_tree_chopped)

# Handle tree chopped signal
func _on_tree_chopped(tree):
	# Create a log instance at the tree's position
	var log_instance = log_scene.instantiate()
	
	var tree_width = 0
	var tree_height = 0
	if tree.has_node("Sprite2D"):
		var sprite: Sprite2D = tree.get_node("Sprite2D")
		tree_width = sprite.get_rect().size[0] * tree.get_node("Sprite2D").scale.x
		tree_height = sprite.get_rect().size[1]
	else:
		tree_width = 64
	
	# Position the log: 50% left of tree's center, at ground level
	var log_position = Vector2(
		tree.global_position.x + tree_width,
		tree.global_position.y + tree_height * 0.5
	)
	
	# Set the log position
	log_instance.global_position = log_position
	
	get_parent().add_child(log_instance)
	print("Tree chopped down! Log created at: ", log_position)


# Spawn multiple trees in the defined rectangle
func spawn_trees(count: int, spawn_rect: Rect2, min_tree_distance: int):
	for i in range(count):
		var max_attempts = 30  # Maximum number of attempts to find a valid position
		var attempts = 0
		var valid_position = false
		var position = Vector2.ZERO
		
		while !valid_position and attempts < max_attempts:
			# Generate random position within rectangle
			position = Vector2(
				spawn_rect.position.x + randf() * spawn_rect.size.x,
				spawn_rect.position.y + randf() * spawn_rect.size.y
			)
			
			# Check if position is far enough from existing trees
			valid_position = true
			for existing_tree in get_tree().get_nodes_in_group("TreeAlive"):
				if position.distance_to(existing_tree.global_position) < min_tree_distance:
					valid_position = false
					break
					
			attempts += 1
		
		if valid_position:
			spawn_tree_at(position)
		else:
			print("Could not find valid position for tree after", max_attempts, "attempts")

# Spawn a single tree at the specified position
func spawn_tree_at(position: Vector2):
	var tree_instance = tree_scene.instantiate()
	tree_instance.global_position = position
	get_parent().add_child(tree_instance)
	
	# Register the tree to connect signals
	register_tree(tree_instance)
