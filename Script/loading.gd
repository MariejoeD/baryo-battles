extends Control

@onready var loading_bar = $LoadingBar
var loading_percentage = 0

func _ready():
	loading_bar.value = 0
	perform_loading()

func perform_loading():
	var total_steps = 100
	var step_time = 0.02

	for step in range(total_steps):
		loading_percentage = step + 1
		loading_bar.value = loading_percentage
		await get_tree().create_timer(step_time).timeout
	
	# After loading, transition to the storytelling scene
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
