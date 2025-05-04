extends Node2D
class_name TreeManager

# Preload the log scene
var log_scene = preload("res://scenes/log.tscn")

func _ready():
	# Look for trees already in the scene
	connect_to_trees()

# Connect to all tree signals in the scene
func connect_to_trees():
	for tree in get_tree().get_nodes_in_group("TreeAlive"):
		if !tree.chopped.is_connected(_on_tree_chopped):
			tree.chopped.connect(_on_tree_chopped)
			print("Connected to tree: ", tree.name)

# Register a new tree (call this when spawning trees dynamically)
func register_tree(tree):
	if !tree.chopped.is_connected(_on_tree_chopped):
		tree.chopped.connect(_on_tree_chopped)
		print("Registered new tree: ", tree.name)

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
