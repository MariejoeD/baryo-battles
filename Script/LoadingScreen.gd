extends Control

@onready var loading_bar = $LoadingBar
@onready var random_message = $RandomMessage

var random_texts = [
	"Tip: Use your resources wisely!",
	"Did you know? The Tikbalang guards its territory fiercely.",
	"Fun fact: Gabriela Silang was a revolutionary leader.",
	"Tip: Upgrade your troops for tougher battles.",
	"Loading... Hang tight!"
]

var loading_percentage := 0  # Tracks the progress of the loading

# Called when the scene is ready
func _ready() -> void:
	# Initialize the random seed
	randomize()
	
	# Set a custom cursor
	Input.set_custom_mouse_cursor(
		load("res://assets/game/cursor.png"),
		Input.CURSOR_ARROW
	)
	
	# Reset the progress bar
	loading_bar.value = 0
	
	# Start the loading process
	perform_loading()

# Function to simulate loading resources with changing random messages
func perform_loading() -> void:
	var total_steps := 100
	var change_message_interval := 0.30  # Change random message every 0.30 second
	var last_message_change := 0.0  # Tracks time since the last message change
	
	for step in range(total_steps):
		# Update the progress bar
		loading_percentage = step
		loading_bar.value = loading_percentage
		
		# Check if it's time to change the random message every 0.30 seconds
		if last_message_change >= change_message_interval:
			random_message.text = random_texts[randi() % random_texts.size()]
			last_message_change = 0.0  # Reset timer for the next message change
		else:
			last_message_change += 0.02  # Increment the timer (time interval is based on the loading step)
		
		# Simulate loading delay
		await get_tree().create_timer(0.02).timeout  # Adjust the timer for loading delay
		
	# Once loading is complete, change to the main menu scene
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")  
