extends Node3D

var tree_scene = preload("res://Scene/buildings/tree.tscn")
var stone_scene = preload("res://Scene/buildings/stone.tscn")
var grid_size = Global.grid_size
var max_tree_qty: int = 30
var max_stones_qty: int = 30
var grid_range = floor(grid_size / 2.0)


var available_tree_indices = [] # List to keep track of available indices for tree names
var available_stone_indices = [] # List to keep track of available indices for stone names


func _ready() -> void:
	generate_trees()
	generate_stones()



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
		var tree_index = get_next_available_index("tree")

		# Try to find a valid position
		var tree_inst = tree_scene.instantiate()
		tree_inst.name = "Tree" + str(tree_index)  # Use the next available index
		var selected_child = tree_inst.get_children()[randi() % 4]
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

func generate_stones():
	if find_qty("stones") >= max_stones_qty:
		return
	if stone_scene == null:
		print("No Stone Scene")
		
	for i in range(max_stones_qty - find_qty("stone")):
		var is_valid_position = false
		var pos = Vector3()
		var stone_index = get_next_available_index("stone")

		var stone_inst = stone_scene.instantiate()
		stone_inst.name = "Stone" + str(stone_index)
		var selected_child = stone_inst.get_children()[randi() % 2]
		var stone_area = stone_inst.get_child(2)
		add_child(stone_inst)
		
		while not is_valid_position:
			var random_x = randi_range(-grid_range, grid_range)
			var random_z = randi_range(-grid_range, grid_range)
			pos = Vector3(random_x, 0, random_z)

			stone_inst.global_transform.origin = pos

			if stone_area.get_overlapping_bodies().size() == 0 and stone_area.get_overlapping_areas().size() == 0:
				is_valid_position = true
		selected_child.visible = true

func get_next_available_index(resource_type: String) -> int:
	var available_indices = available_tree_indices if resource_type == "tree" else available_stone_indices
	var next_index = 0

	if available_indices.size() > 0:
		next_index = available_indices.pop_back()
	else:
		while get_node_or_null(resource_type.capitalize() + str(next_index)) != null:
			next_index += 1

	return next_index

func find_qty(mats: String) -> int:
	if mats != "tree" and mats != "stone":
		print("%s is not a available resources" % [mats])
		return 0
	var current_qty = {
		"tree" : 0,
		"stone" : 0
	}
	for child in get_children():
		if child.name.begins_with("Tree") and mats == "tree":
			current_qty["tree"] += 1
		elif  child.name.begins_with("Stone") and mats == "stone":
			current_qty["stone"] += 1
	print(current_qty)
	if mats == "tree":
		return current_qty["tree"]
	elif mats == "stone":
		return current_qty["stone"]
	return 0

# Call this when a tree is removed to free up its index
func free_resource_index(resource: Node):
	var resource_type = resource.name.substr(0, 5)
	if resource_type == "Tree" or resource_type == "Stone":
		var index_str = resource.name.get_slice(resource_type, 0)
		var index = int(index_str)
		var available_indices = available_tree_indices if resource_type == "tree" else available_stone_indices
		available_indices.append(index)




func npc(name):
	print(name)
func _on_tree_entered() -> void:
	SignalManager.discovered.connect(npc)
	SignalManager.tree_remove.connect(free_resource_index)
	SignalManager.new_day.connect(generate_trees)
	pass # Replace with function body.


func _on_tree_exiting() -> void:
	SignalManager.tree_remove.disconnect(free_resource_index)
	SignalManager.new_day.disconnect(generate_trees)
	
	pass # Replace with function body.
