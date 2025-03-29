extends Node

var base_path = "res://Scene/battle/"  # Parent path
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for btn in $"../AttackPanel/ScrollContainer/VBoxContainer/TextureRect".get_children():
		btn.connect("pressed", Callable(self, "_on_btn_pressed").bind(btn))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_btn_pressed(btn):
	# Save the troops data before changing scenes
	
	print("Before Saving:", Global.kampo_troops)  # Debugging print
	Global.kampo_troops.clear()
	for kampo in Global.all_kampo:
		var kampo_id = kampo.get_instance_id()
		
		if kampo_id in Global.kampo_troops:
			print("⚠️ Duplicate Detected! Kampo ID:", kampo_id)
		else:
			Global.kampo_troops[kampo_id] = kampo.troops.duplicate(true)  # Deep copy

	print("After Saving:", Global.kampo_troops)  # Check if duplicates appear
	var scene_path = scene_exists_in_folder(base_path, btn.name)
	if scene_path:
		get_tree().change_scene_to_file(scene_path)
		
	pass

func scene_exists_in_folder(folder_path: String, button_name: String) -> String:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			# Check if it's a folder (region name)
			if dir.current_is_dir():
				var scene_path = folder_path + file_name + "/" + button_name + ".tscn"
				if FileAccess.file_exists(scene_path):
					return scene_path  # Return the correct path
			file_name = dir.get_next()
	return ""  # Return empty if not found
