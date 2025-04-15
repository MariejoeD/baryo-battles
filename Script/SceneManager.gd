extends Node

func go_to_scene(path: String):
	await get_tree().process_frame
	var loader_node = preload("res://Scene/loadBeforeBattle.tscn").instantiate()
	loader_node.target_scene_path = path  # Set the scene path
	get_tree().current_scene.add_child(loader_node)  # Add loader to the current scene
	
