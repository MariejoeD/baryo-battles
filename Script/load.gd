extends Node3D

@onready var entities = $"../Entities"

var save_data = {
	"Panday" : 2
}

var char_scenes = {
	"Panday" : "res://Scene/Characters/panday.tscn"
}

func _ready():
	_load()
	pass

func _load():
	load_chars()
	pass
	
func load_chars():
	for char_name in save_data.keys():
		if char_scenes.has(char_name):
			var scene_path = char_scenes[char_name]
			var character_scene = load(scene_path)
			var num_to_spawn = save_data[char_name]
			
			for i in range(num_to_spawn):
				var char_inst = character_scene.instantiate()
				entities.add_child(char_inst)
				char_inst.global_transform.origin = Vector3(randf() * 10, 0, randf() * 10)  # Set random positions
		else:
			print("Unknown character ID:", char_name)
	pass
