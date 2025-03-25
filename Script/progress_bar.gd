extends ProgressBar

@export var time_label: Label  # Assign in Inspector

const TOTAL_GAME_HOURS := 24
const REAL_TIME_DURATION := 20 * 60.0  # 20 minutes in seconds
var time_passed := 0.0  # Tracks elapsed real time

@onready var tween := get_tree().create_tween()  # Tween for smooth updates

func _ready():
	value = 0  # Start at 0
	modulate = Color(0.0, 1.0, 0.0)  # Initial color (Morning - Green)
	update_time_label(0)  # Start with 00:00

func _process(delta):
	# Increase elapsed real time
	time_passed += delta
	
	# Convert real time to in-game hours
	var game_hours = (time_passed / REAL_TIME_DURATION) * TOTAL_GAME_HOURS

	# Smoothly update the ProgressBar
	tween.tween_property(self, "value", game_hours, 0.5)

	# Update the displayed time
	update_time_label(game_hours)

	# Change color based on the time of day
	if game_hours < 6 or game_hours >= 18:
		modulate = Color(0.0, 0.0, 1.0)  # Night (Blue)
	else:
		modulate = Color(0.0, 1.0, 0.0)  # Morning (Green)

	# Reset at the end of the cycle
	if time_passed >= REAL_TIME_DURATION:
		time_passed = 0  # Reset real time
		value = 0  # Reset ProgressBar
		update_time_label(0)

# Function to update the Label with 24-hour time format
func update_time_label(game_hours: float):
	var hours = int(game_hours)
	var minutes = int((game_hours - hours) * 60)  # Convert fraction to minutes
	if time_label:
		time_label.text = "%02d:%02d" % [hours, minutes]  # Format as HH:MM
