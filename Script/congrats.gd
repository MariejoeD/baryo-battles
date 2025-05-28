extends Control
@onready var button: Button = $Panel/Button
@onready var button_2: Button = $Panel/Button2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(new_game)
	button_2.pressed.connect(continue_game)
	pass # Replace with function body.


func new_game():
	var path = Global.save_path
	if FileAccess.file_exists(path):
		var dir_path = path.get_base_dir()
		var file_name = path.get_file()
		var dir = DirAccess.open(dir_path)
		if dir:
			var result = dir.remove(file_name)
			if result == OK:
				print("Deleted file:", path)
				# Launch a new instance of the game
				OS.shell_open(OS.get_executable_path())
				# Delay quit just a little
				await get_tree().create_timer(0.1).timeout
				get_tree().quit()
			else:
				print("Failed to delete file:", path)
		else:
			print("Failed to open directory:", dir_path)
	else:
		print("File does not exist:", path)
	pass

func continue_game():
	SceneManager.go_to_scene("res://Scene/HomeBase.tscn")
	pass
