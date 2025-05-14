extends Node

var base_path = "res://Scene/battle/"  # Parent path
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for region in $"../AttackPanel/ScrollContainer/VBoxContainer/TextureRect".get_children():
		for btn in region.get_children():
			btn.connect("pressed", Callable(self, "_on_btn_pressed").bind(btn))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func display():
	%conquered.show()
	pass
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if %conquered.visible:
			var mouse_pos = get_viewport().get_mouse_position()

			# Adjust this to match your actual grandchild path
			var panel := %conquered.get_child(0).get_child(0)

			if panel is Control:
				if not panel.get_global_rect().has_point(mouse_pos):
					%conquered.hide()


	
func is_conquered(base_name: String) -> bool:
	for pair in MapManager.conquered_bases:
		print(base_name.capitalize())
		if pair["name"] == base_name.capitalize():
			return true
	return false
#var conquered_bases := [{"name": "Aklan",
		#"resource": "Wood",
		#"rate": 5,
		#"civilian": 0,
		#"base_cp": 0,
		#"stored_resources": 0},]
func base_data(base_name: String):
	for base in MapManager.conquered_bases:
		if base["name"] == base_name.capitalize():
			return base
	return {}
func update_conquered_panel(base_name: String):
	var panel := %conquered.get_child(0)
	var data = base_data(base_name)
	if data.size() == 0:  # Check if base data was found
		print("Base not found.")
		return
	
	panel.base_name = data["name"]
	panel.resource_type = data["resource"]
	panel.rate = data["rate"] + (data["civilian"] * 0.5) * 12
	panel.baseCp = data["base_cp"]
	
	panel.start()
	pass

func _on_btn_pressed(btn):
	# Save the troops data before changing scenes
	print(MapManager.conquered_bases)
	if is_conquered(btn.name):
		update_conquered_panel(btn.name)
		display()
		return

	var tutorial_node = get_tree().current_scene.find_child("tutorial")

	if is_instance_valid(tutorial_node):
		tutorial_node.step_10.emit()
	else:
		print("Tutorial node is no longer valid, skipping signal emission.")
	#print("Before Saving:", Global.kampo_troops)  # Debugging print
	#Global.kampo_troops.clear()
	#Global.all_kampo = Global.all_kampo.filter(func(k): return is_instance_valid(k))
	#for kampo in Global.all_kampo:
		#var kampo_id = kampo.get_instance_id()
		#
		#if kampo_id in Global.kampo_troops:
			#print("⚠️ Duplicate Detected! Kampo ID:", kampo_id)
		#else:
			#Global.kampo_troops[kampo_id] = kampo.troops.duplicate(true)  # Deep copy
	#
	#print("After Saving:", Global.kampo_troops)  # Check if duplicates appear
	#
	var folder_name :String = btn.get_parent().name
	var file_name :String = btn.name
	var scene_path :String= "res://Scene/battle/%s/%s.tscn" % [folder_name, file_name]
	print("Button Pressed")
	print(scene_path)
	if scene_path:
		# Create a SceneLoader instance dynamically
		
		SceneManager.go_to_scene(scene_path) # Start the scene loading process
