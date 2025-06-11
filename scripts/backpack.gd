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
func add_log(log: Log):
	# Check if we've reached the maximum number of trees
	if trees.size() >= MAX_TREES:
		return false
	
	log.reparent(self)
	log.disable_pickup_range()
	
	# Calculate position - each new tree appears 16px above the last one
	var y_position = trees.size() * TREE_VERTICAL_OFFSET * -1
	
	# Set the position
	log.position = Vector2(0, y_position)
	
	# Add the tree to the backpack and the trees array
	trees.append(log)
	
	return true

# Remove the most recently added tree
func pop_log():
	# Check if there are trees to remove
	if trees.size() <= 0:
		return null
	
	# Remove last tree from array and scene
	var tree_to_remove = trees.pop_back()
	
	return tree_to_remove
	
func spend_logs(number: int) -> bool:
	if len(trees) < number:
		return false
	for i in range(number):
		trees.pop_back().free()
	return true

# Get the current number of trees
func get_tree_count():
	return trees.size()

# Check if backpack is full
func is_full():
	return trees.size() >= MAX_TREES
