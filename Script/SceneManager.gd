extends Node

func go_to_scene(path: String, skip_save := false):
	await get_tree().process_frame
	print("Saving to: ", Global.save_path)

	if !skip_save and get_tree().current_scene.name == "HomeBase":
		await SaverLoader.save_game()
	var loader_node = preload("res://Scene/loadBeforeBattle.tscn").instantiate()
	loader_node.target_scene_path = path
	get_tree().current_scene.add_child(loader_node)
