extends ProgressBar

@export var time_label: Label  # Assign in Inspector

const TOTAL_GAME_HOURS := 24
var game_hours := 6.0  # Start at 6:00 AM

@onready var tween := get_tree().create_tween()  # Tween for smooth updates

func _ready():
	value = 0  # Start at 0%
	modulate = Color(0.0, 1.0, 0.0)  # Morning (Green)
	update_time_label(game_hours)  # Display 06:00 AM

func _process(_delta):
	# Calculate game time from Global.time_of_day
	game_hours = 6.0 + (Global.time_of_day * TOTAL_GAME_HOURS)  # Shift 0 -> 6 AM

	# Stop and replace tween to avoid conflicts
	if tween.is_running():
		tween.stop()
	tween = get_tree().create_tween()

	# Smoothly update ProgressBar
	tween.tween_property(self, "value", game_hours, 0.5)

	# Update the displayed time
	update_time_label(game_hours)

	# Change color based on time of day
	if game_hours < 6 or game_hours >= 18:
		modulate = Color(0.0, 0.0, 1.0)  # Night (Blue)
	else:
		modulate = Color(0.0, 1.0, 0.0)  # Morning (Green)

# Function to update the time label (12-hour HH:MM AM/PM format)
func update_time_label(game_hours: float):
	var hours = int(game_hours) % 12
	if hours == 0:
		hours = 12  # Convert 0 to 12 for 12-hour format
	var minutes = int((game_hours - int(game_hours)) * 60)  # Convert fraction to minutes
	var period = "PM" if game_hours > 12 and game_hours < 24 else "AM"
	if time_label:
		time_label.text = "%02d:%02d %s" % [hours, minutes, period]  # Format as HH:MM AM/PM
