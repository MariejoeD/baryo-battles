extends Node

func go_to_scene(path: String):
	await get_tree().process_frame
	get_tree().change_scene_to_file(path)
