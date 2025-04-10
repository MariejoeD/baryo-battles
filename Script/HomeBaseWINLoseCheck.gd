extends Node


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

	
	# Determine win or lose
	if all_enemies_defeat:
		print("✅ WIN!")
		show_result("win")
	elif troops_remaining.size() == 0:
		print("❌ LOSE!")
		show_result("lose")







func show_result(result: String):
	if result == "win":
		print("YOU WIN!")
	elif result == "lose":
		print("YOU LOSE!")
