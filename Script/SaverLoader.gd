extends Node

var saved_game:SavedGame 
# Called when the autoload is initialized (before any scenes)
func _ready():
	SignalManager.save.connect(save_game)
	get_tree().tree_changed.connect(scene_change)


func scene_change():
	var current = get_tree().get_current_scene()
	if current and current.name == "HomeBase":
		current.get_node(NodePath("Control/HBoxContainer/Button2")).pressed.connect(save_game)
		current.get_node(NodePath("Control/HBoxContainer/Button3")).pressed.connect(load_save_data)


# Load saved data from file
func load_save_data():
	var path = "res://save.tres"
	if ResourceLoader.exists(path):
		saved_game = load(path) as SavedGame
		if saved_game:
			update_resources(saved_game.resources)
			load_environment(get_tree().current_scene.find_child("Generate"))
			load_building()
			print("Save data loaded successfully.")
		else:
			print("Failed to load save data.")
	else:
		print("No saved data found, starting fresh.")
		saved_game = SavedGame.new()  # Create new if no data exists

# Save the current game data
func save_game():
	saved_game = SavedGame.new()
	get_resources()
	save_environment(get_tree().current_scene.find_child("Generate"))
	save_building()
	
	ResourceSaver.save(saved_game, "res://save.tres")
	

# Function to access resources (can be used in any scene)
func get_resources():
	saved_game.resources = {

		"wood": Global.wood_qty,
		"stone": Global.stone_qty,
		"food": Global.food_qty
	}
	
func save_environment(env_root: Node):
	saved_game.environment_data.clear()

	for child in env_root.get_children():
		if child.name.begins_with("Tree") or child.name.begins_with("Stone"):
			var mesh_index := -1
			for i in child.get_child_count():
				if child.get_child(i).visible:
					mesh_index = i
					break
			saved_game.environment_data.append({
				"type": "tree" if child.name.begins_with("Tree") else "stone",
				"position": child.global_transform.origin,
				"mesh_index": mesh_index,
				"name": child.name
			})


# Function to update/save resource data (to be used in different scenes)
func update_resources(new_resources: Dictionary):
	Global.wood_qty = new_resources["wood"]
	Global.stone_qty = new_resources["stone"]
	Global.food_qty = new_resources["food"]
	
func load_environment(env_root: Node):
	# Step 1: Remove extra nodes not in the saved data
	var saved_names = []
	print(env_root.get_children())
	for item in saved_game.environment_data:
		saved_names.append(item["name"])  # Collect names of saved nodes

	# Iterate through the children of the environment root
	for child in env_root.get_children():
		# If the child's name is not in the saved names list, remove it
		if child.name not in saved_names:
			child.queue_free()

	# Step 2: Update the existing nodes with the saved data
	for item in saved_game.environment_data:
		print("Load")
		var instance = env_root.get_node_or_null(NodePath(item["name"])) # Retrieve the existing node by name
		print(item["name"])
		if instance:
			# Update the position
			print(instance.global_transform.origin)
			print(instance.name)
			print(item["position"])
			instance.global_transform.origin = item["position"]
			print(instance.global_transform.origin)

			# Set visibility for the mesh children based on the saved mesh_index
			if instance.is_in_group("Trees"):
				for i in range(4):
					instance.get_child(i).visible = false
					if instance.get_child(i) == instance.get_child(item["mesh_index"]):
						instance.get_child(i).visible = true
			else:
				for i in range(2):
					instance.get_child(i).visible = false
					if instance.get_child(i) == instance.get_child(item["mesh_index"]):
						instance.get_child(i).visible = true
	#env_root.clear_environment()
	#var tree_scened = load("res://Scene/buildings/tree.tscn")
	#var stone_scened = load("res://Scene/buildings/stone.tscn")
	#for item in saved_game.environment_data:
		#var instance =  tree_scened.instantiate() if item["type"] == "tree" else stone_scened.instantiate()
		#instance.name = item["name"]
		#
		## Reset all mesh children to invisible
		#for i in instance.get_child_count():
			#instance.get_child(i).visible = false
#
		## Set the saved visible child
		#var visible_index :int = item["mesh_index"]
		#if visible_index >= 0 and visible_index < instance.get_child_count():
			#instance.get_child(visible_index).visible = true
#
		#env_root.add_child(instance)
		#instance.global_transform.origin = item["position"]
		#if instance.has_method("init"):
			#instance.init()
		#print("Tree:", instance.name)
		#print("Has connected signal:", instance.find_child("Area3D").is_connected("input_event", instance._on_area_3d_input_event))


func save_building():
	saved_game.building_data.clear()
	var gridmap = get_tree().current_scene.find_child("GridMap")
	if !gridmap:
		print("Null")
		return

	for building in gridmap.get_children():
		if building.has_method("get_save_data"):
			saved_game.building_data.append(building.get_save_data())



func load_building():
	var gridmap = get_tree().current_scene.find_child("GridMap")
	if !gridmap:
		print("Null")
		return

	# Clear existing children
	for child in gridmap.get_children():
		gridmap.remove_child(child)
		child.queue_free()

	for data in saved_game.building_data:
		var scene_path = "res://Scene/buildings/%s.tscn" % data["name"]
		var packed_scene = load(scene_path)

		if packed_scene and packed_scene is PackedScene:
			var building = packed_scene.instantiate()
			if building.has_method("load_from_data"):
				building.load_from_data(data)
			else:
				# Fallback if building doesn't have load method
				building.global_transform.origin = data.get("position", Vector3.ZERO)
				building.scale = data.get("scale", Vector3.ONE)
				building.level = data.get("level", 1)
			gridmap.add_child(building)
		else:
			print("Failed to load:", scene_path)
