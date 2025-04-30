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

	
func show_result(result: String):
	if result == "win":
		print("YOU WIN!")
		return_troops()
	elif result == "lose":
		print("YOU LOSE!")
		Engine.time_scale = 0  # Pause everything
		Global.stop_time = false
		
		game_ui.show()
		defense_ui.hide()

		var game_over_panel = defense_ui.find_child("Defend Control/gameOverPanel")
		game_over_panel.show()

		var play_again_button = game_over_panel.find_child("playAgain")
		play_again_button.disabled = false

		play_again_button.pressed.connect(func():
			get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
		)



func return_troops():
	for child in get_children():
		if child.is_in_group("Good"):
			child.find_child("GoToCamp").go_to_camp()
