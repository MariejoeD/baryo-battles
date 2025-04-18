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
	if SaverLoader.saved_game and SaverLoader.saved_game.environment_data and SaverLoader.saved_game.environment_data.size() > 0:
		print("running")
		SaverLoader.load_environment(self)


func clear_environment():
	for tree in get_tree().get_nodes_in_group("Trees"):
		tree.get_parent().remove_child(tree)
		tree.queue_free()
	for stone in get_tree().get_nodes_in_group("Stones"):
		stone.get_parent().remove_child(stone)
		stone.queue_free()

func Load():
	clear_environment()
	generate_stones()
	generate_trees()

func generate_trees():
	print("Tree: ",find_qty("tree"))
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
	print("Stone: ",find_qty("stone"))
	if find_qty("stone") >= max_stones_qty:
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
	if mats == "tree":
		return get_tree().get_nodes_in_group("Trees").size()
	elif mats == "stone":
		return get_tree().get_nodes_in_group("Stones").size()
	else:
		print("%s is not an available resource" % [mats])
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
	SignalManager.new_day.connect(generate_stones)
	
	pass # Replace with function body.


func _on_tree_exiting() -> void:
	SignalManager.tree_remove.disconnect(free_resource_index)
	SignalManager.new_day.disconnect(generate_trees)
	SignalManager.new_day.disconnect(generate_stones)
	
	pass # Replace with function body.


func _on_button_pressed() -> void:
	clear_environment()
	for child in $"../AMap/GridMap".get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	generate_trees()
	generate_stones()
	Buildings.reset()
	pass # Replace with function body.
