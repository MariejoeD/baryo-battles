extends Node3D

var tree_scene = preload("res://Scene/buildings/tree.tscn")
var grid_size = Global.grid_size
var max_tree_qty: int = 30
var grid_range = floor(grid_size / 2.0)

var available_indices = []  # List to keep track of available indices for tree names

func _ready() -> void:
	generate_trees()




func generate_trees():
	if find_qty("tree") >= max_tree_qty:
		return
	if tree_scene == null:
		print("No Tree Scene")
		return


	for i in range(max_tree_qty - find_qty("tree")):
		var is_valid_position = false
		var pos = Vector3()

		# Get the next available index for the tree name
		var tree_index = get_next_available_index()

		# Try to find a valid position
		var tree_inst = tree_scene.instantiate()
		tree_inst.name = "Tree" + str(tree_index)  # Use the next available index
		var selected_child = tree_inst.get_children()[randi() % 4]
		var mesh = selected_child.mesh

		var tree_area = tree_inst.get_child(4)
		add_child(tree_inst)
		while not is_valid_position:
			var random_x = randi_range(-grid_range, grid_range)
			var random_z = randi_range(-grid_range, grid_range)
			pos = Vector3(random_x, 0, random_z)

			tree_inst.global_transform.origin = pos

			if tree_area.get_overlapping_bodies().size() == 0 and tree_area.get_overlapping_areas().size() == 0:
				is_valid_position = true  # Position is valid if no overlap

		selected_child.visible = true
		

func get_next_available_index() -> int:
	var next_index = 0

	# If there are available indices, pop one from the list
	if available_indices.size() > 0:
		next_index = available_indices.pop_back()
	else:
		# If no available indices, find the next unused index
		while get_node_or_null("Tree" + str(next_index)) != null:
			next_index += 1

	return next_index

func find_qty(mats: String) -> int:
	var current_qty = 0
	for child in get_children():
		if child.name.begins_with("Tree") and mats == "tree":
			current_qty += 1
	print(current_qty)
	return current_qty

# Call this when a tree is removed to free up its index
func free_tree_index(tree: Node):
	
	if tree.name.begins_with("Tree"):
		var index_str = tree.name.get_slice("Tree", 0)
		var index = int(index_str)
		available_indices.append(index)

func npc(name):
	print(name)
func _on_tree_entered() -> void:
	SignalManager.discovered.connect(npc)
	SignalManager.tree_remove.connect(free_tree_index)
	SignalManager.new_day.connect(generate_trees)
	pass # Replace with function body.


func _on_tree_exiting() -> void:
	SignalManager.tree_remove.disconnect(free_tree_index)
	SignalManager.new_day.disconnect(generate_trees)
	
	pass # Replace with function body.
