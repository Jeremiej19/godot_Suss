# Backpack.gd - Attach this to your Backpack node
extends Node2D
class_name Backpack

# Preload your tree scene
var Log = preload("res://scenes/log.tscn")

# Store the trees currently in the backpack
var trees = []
const MAX_TREES = 16
const TREE_VERTICAL_OFFSET = 16  # pixels between trees

# Add a new tree to the backpack
func add_tree():
	# Check if we've reached the maximum number of trees
	if trees.size() >= MAX_TREES:
		print("Backpack is full!")
		return false
	
	# Instance a new tree
	var new_tree = Log.instantiate()
	
	# Calculate position - each new tree appears 16px above the last one
	var y_position = trees.size() * TREE_VERTICAL_OFFSET * -1
	
	# Set the position
	new_tree.position = Vector2(0, y_position)
	
	# Add the tree to the backpack and the trees array
	add_child(new_tree)
	trees.append(new_tree)
	
	print("Added tree. Total: ", trees.size())
	return true

# Remove the most recently added tree
func remove_tree():
	# Check if there are trees to remove
	if trees.size() <= 0:
		print("No trees to remove!")
		return null
	
	# Remove last tree from array and scene
	var tree_to_remove = trees.pop_back()
	tree_to_remove.queue_free()
	
	print("Removed tree. Total: ", trees.size())
	return true

# Get the current number of trees
func get_tree_count():
	return trees.size()

# Check if backpack is full
func is_full():
	return trees.size() >= MAX_TREES
