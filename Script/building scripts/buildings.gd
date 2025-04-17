# Building.gd
class_name Building
extends Node3D  # Or whatever base type your buildings use

@export var level: int = 1

func get_save_data() -> Dictionary:
	return {
		"name": scene_file_path.get_file().get_basename(),
		"position": global_transform.origin,
		"scale": scale,
		"level": level
	}

func load_from_data(data: Dictionary) -> void:
	global_transform.origin = data.get("position", Vector3.ZERO)
	scale = data.get("scale", Vector3.ONE)
	level = data.get("level", 1)
	
