# Building.gd
class_name Building
extends Node3D  # Or whatever base type your buildings use

@export var level: int = 1
@export var built: = false
func get_save_data() -> Dictionary:
	return {
		"name": scene_file_path.get_file().get_basename(),
		"position": global_transform.origin,
		"scale": scale,
		"level": level,
		"built": built
	}

func load_from_data(data: Dictionary) -> void:
	global_transform.origin = data.get("position", Vector3.ZERO)
	scale = data.get("scale", Vector3.ONE)
	level = data.get("level", 1)
	built = data.get("built", false)
	
	if built:
		instant_build()

func instant_build():
	
	pass
