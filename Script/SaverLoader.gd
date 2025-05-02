extends Node

var saved_game:SavedGame 

# Called when the autoload is initialized (before any scenes)
func _ready():
	SignalManager.save.connect(save_game)
	SignalManager.homebase.connect(scene_change)
	var current = get_tree().get_current_scene()
	if current and current.name == "HomeBase":
		current.get_node(NodePath("Control/HBoxContainer/Button2")).pressed.connect(save_game)
		current.get_node(NodePath("Control/HBoxContainer/Button3")).pressed.connect(load_save_data)


func scene_change():
	var current = get_tree().get_current_scene()
	if current and current.name == "HomeBase":
		current.get_node(NodePath("Control/HBoxContainer/Button2")).pressed.connect(save_game)
		current.get_node(NodePath("Control/HBoxContainer/Button3")).pressed.connect(load_save_data)


func load_save_data():
	var path = Global.save_path
	if ResourceLoader.exists(path):
		saved_game = load(path) as SavedGame
		if saved_game:
			# Load time-related data
			load_time_data()

			# Load other game data like resources, environment, and buildings
			load_resources(saved_game.resources)
			load_environment(get_tree().current_scene.find_child("Generate"))
			load_building()
			
			load_sibilyans()
			load_kampo_troops()
			load_battle_data()

		else:
			print("Failed to load save data.")
	else:
		print("No saved data found, starting fresh.")
		  # Create new if no data exists


# Save the current game data
func save_game():
	saved_game = SavedGame.new()

	# Save time-related data
	save_time_data()

	# Save other data like resources, environment, and buildings
	save_resources()
	save_environment(get_tree().current_scene.find_child("Generate"))
	save_building()
	
	save_sibilyans()
	save_kampo_troops()
	save_battle_data()
	# Save the game state
	ResourceSaver.save(saved_game, Global.save_path)

	

# Function to access resources (can be used in any scene)
func save_resources():
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
			for i in range(child.get_child_count()):
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
func load_resources(new_resources: Dictionary):
	Global.wood_qty = new_resources["wood"]
	Global.stone_qty = new_resources["stone"]
	Global.food_qty = new_resources["food"]
	
func load_environment(env_root: Node):
	# Step 1: Remove extra nodes not in the saved data
	var saved_names = []
	env_root.Load()
	#print(env_root.get_children())
	for item in saved_game.environment_data:
		saved_names.append(item["name"])  # Collect names of saved nodes

	# Iterate through the children of the environment root
	for child in env_root.get_children():
		# If the child's name is not in the saved names list, remove it
		if child.name not in saved_names:
			child.queue_free()

	# Step 2: Update the existing nodes with the saved data
	for item in saved_game.environment_data:
		
		var instance = env_root.get_node_or_null(NodePath(item["name"])) # Retrieve the existing node by name
		
		if instance:
			# Update the position
			#print(instance.global_transform.origin)
			#print(instance.name)
			#print(item["position"])
			instance.global_transform.origin = item["position"]
			#print(instance.global_transform.origin)

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
			building.on_placed()
		else:
			print("Failed to load:", scene_path)

# Function to save time-related data
func save_time_data():
	saved_game.game_time = {
	"current_time": Global.current_time,
	"total_game_time": Global.total_game_time,
	"time_of_day": Global.time_of_day,
	"has_emitted_night_time": Global.has_emitted_night_time
}


func load_time_data():
	if "current_time" in saved_game.game_time:
		Global.current_time = saved_game.game_time["current_time"]
		Global.total_game_time = saved_game.game_time["total_game_time"]
		Global.time_of_day = saved_game.game_time["time_of_day"]
		Global.has_emitted_night_time = saved_game.game_time["has_emitted_night_time"]
	else:
		push_warning("Time data missing from saved_game. Using defaults.")

	# Optionally, reset time progression if necessary:
	if Global.current_time >= Global.DAY_DURATION:
		Global.current_time = 0.0
		Global.has_emitted_night_time = false


func save_sibilyans():
	var sibilyan_data_array = []

	for sib in get_tree().get_nodes_in_group("Sibilyan"):
		var workload_names = []
		var current_work = null
		for task in sib.workload:
			if current_work == null:
				current_work = task
			if is_instance_valid(task):
				workload_names.append(task.name)  # or task.get_path() for uniqueness
		var start_time = current_work.start_time if current_work else 0
		var remaining_time = current_work.get_remaining_time() if current_work else 0
		var data = {
			"position": sib.global_transform.origin,
			"assigned_kubo": sib.assigned_kubo.name if sib.assigned_kubo else "",
			"returning": sib.returning,
			"current_work":current_work.name if current_work else "",
			"start_time": start_time,
			"remaining_time": remaining_time if remaining_time != 0 else -1,
			"workload": workload_names,
		}
		sibilyan_data_array.append(data)

	saved_game.sibilyans = sibilyan_data_array


func load_sibilyans():
	for sib in get_tree().get_nodes_in_group("Sibilyan"):
		sib.get_parent().remove_child(sib)
		sib.queue_free()
	var sib_scene = preload("res://Scene/Characters/sibilyan.tscn")
	
	for sib_data in saved_game.sibilyans:
		var sib = sib_scene.instantiate()
		sib.global_transform.origin = sib_data["position"]
		sib.returning = sib_data.get("returning", false)
		sib.current_work = find_node_by_name(sib_data.get("current_work", ""))
		sib.remaining = sib_data.get("remaining_time", -1)
		print(sib.remaining)
		# Reassign kubo if found
		for kubo in Global.all_kubos:
			if kubo.name == sib_data["assigned_kubo"]:
				sib.assigned_kubo = kubo
				break

		get_tree().current_scene.find_child("Entities").add_child(sib)

		# Rebuild workload from task names
		for task_name in sib_data["workload"]:
			var task_node = find_node_by_name(task_name)
			if task_node:
				sib.add_work(task_node)

func find_node_by_name(target_name: String) -> Node:
	return get_tree().current_scene.find_child(target_name, true, false)

func save_kampo_troops() -> void:
	Global.kampo_troops.clear()
	Global.all_kampo = Global.all_kampo.filter(func(k): return is_instance_valid(k))

	for kampo in Global.all_kampo:
		var kampo_id = kampo.name  # Assuming this is unique
		var troop_counts = {}

		for troop in kampo.troops:
			if troop.name in troop_counts:
				troop_counts[troop.name] += 1
			else:
				troop_counts[troop.name] = 1

		Global.kampo_troops[kampo_id] = troop_counts

	saved_game.troops = Global.kampo_troops.duplicate(true)

func clear_used_troops() -> void:
	saved_game.troops.clear()
	Global.kampo_troops.clear()

func load_kampo_troops() -> void:
	for troop in get_tree().get_nodes_in_group("Good"):
		troop.get_parent().remove_child(troop)
		troop.queue_free()
	if saved_game.troops:
		Global.kampo_troops = saved_game.troops.duplicate(true)
	else:
		Global.kampo_troops.clear()
	Global.all_kampo = Global.all_kampo.filter(func(k): return is_instance_valid(k))

	for kampo in Global.all_kampo:
		var kampo_id = kampo.name
		if Global.kampo_troops.has(kampo_id):
			kampo.troops.clear()

			var troop_data = Global.kampo_troops[kampo_id]
			for troop_name in troop_data.keys():
				var count = troop_data[troop_name]

				if Npc.Troops_unlocked.has(troop_name):
					var scene = Npc.Troops_unlocked[troop_name][0]
					var training_time = 1.0  # You can customize this per unit if needed
					for i in count:
						kampo.troops.append({
							"name": troop_name,
							"duration": training_time,
							"scene": scene
						})
						var instance = scene.instantiate()
						get_tree().current_scene.find_child("Entities").add_child(instance)
						instance.global_transform.origin = kampo.global_transform.origin
						var shape = instance.get_node("Detection/CollisionShape3D").shape.duplicate()
						shape.radius *= 0.2
						instance.get_node("Detection/CollisionShape3D").shape = shape

func save_battle_data() -> void:
	var battle_data = {
		"conquered_bases": MapManager.conquered_bases,
		"unlocked_maps": MapManager.unlocked_maps,
		"boss_defeated": Npc.bosses
	}
	saved_game.battle_data = battle_data

func load_battle_data() -> void:
	if saved_game.battle_data != null:
		var battle_data = saved_game.battle_data
		MapManager.conquered_bases = battle_data.get("conquered_bases", [])
		MapManager.unlocked_maps = battle_data.get("unlocked_maps", ["Aklan"])
		Npc.bosses = battle_data["boss_defeated"]
