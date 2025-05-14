extends Node

@onready var game_ui: Control = $"../Control"
@onready var defense_ui: Control = $"../../Defend Mechanism/UI"


func win_lose_check():
	# Wait for the next frame to ensure nodes have been processed (queue_free is done)
	await get_tree().process_frame
	var enemies_remaining
	var troops_remaining
	# Get all enemies and troops
	if get_tree() and get_tree().has_group("Enemy"):
		enemies_remaining = get_tree().get_nodes_in_group("Enemy")
	else:
		enemies_remaining = []

	if get_tree() and get_tree().has_group("Good"):
		troops_remaining = get_tree().get_nodes_in_group("Good")
	else:
		troops_remaining = []


	# Check if any enemies are alive
	var all_enemies_defeat = true

	for enemy in enemies_remaining:
				# For regular enemies, check if they are still alive
		if enemy.is_inside_tree() and enemy.visible:
			all_enemies_defeat = false
			break  # If one is alive, no need to continue checking
	if all_enemies_defeat:
		print("✅ WIN!")
		show_result("win")

	
func show_result(result: String):
	if result == "win":
		print("YOU WIN!")
		$"../../Defend Mechanism/UI".hide()
		$"../Control".show()
		Global.stop_time = false
		return_troops()
	elif result == "lose":
		print("YOU LOSE!")
		Engine.time_scale = 0  # Pause everything
		Global.stop_time = false
		
		game_ui.show()
		defense_ui.hide()

		var game_over_panel = get_tree().current_scene.find_child("gameOverPanel")
		$"../../Defend Mechanism/Defend Control".show()
		$"../../Defend Mechanism/Defend Control/warningContainer".hide()
		$"../../Defend Mechanism/Defend Control/assignTroop".hide()
		$"../../Defend Mechanism/Defend Control/gameOverPanel".show()

		var play_again_button = game_over_panel.find_child("playAgain")

		play_again_button.pressed.connect(func():
			Engine.time_scale = 1
			delete_save_file(Global.save_path)
			SceneManager.go_to_scene("res://Scene/MainMenu.tscn", true)
		)


func delete_save_file(path: String):
	if FileAccess.file_exists(path):
		var dir_path = path.get_base_dir()
		var file_name = path.get_file()
		var dir = DirAccess.open(dir_path)
		if dir:
			var result = dir.remove(file_name)
			if result == OK:
				print("Deleted file:", path)
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
func return_troops():
	for child in get_children():
		if child.is_in_group("Good"):
			child.find_child("GoToCamp").go_to_camp()
