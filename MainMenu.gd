extends Control

# References to buttons
@onready var play_button = $VBoxContainer/play
@onready var options_button = $VBoxContainer/options
@onready var quit_button = $VBoxContainer/quit

# Load icon textures
var play_icon = preload("res://assets/game/play_icon.png")
var options_icon = preload("res://assets/game/option_icon.png")
var quit_icon = preload("res://assets/game/quit_icon.png")

# Function to start the game
func _on_play_button_pressed():
	print("Play button pressed!")
	get_tree().change_scene_to_file("res://game.tscn")

# Function to open options
func _on_options_button_pressed():
	print("Options button pressed!")
	get_tree().change_scene_to_file("res://OptionsMenu.tscn")  # Load the options menu scene

# Function to quit the game
func _on_quit_button_pressed():
	get_tree().quit()

# Connect button signals and assign icons
func _ready():
	# Set a custom mouse cursor (optional)
	var cursor_texture = preload("res://assets/game/cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture)
	
	# Assign icons to buttons
	play_button.icon = play_icon
	options_button.icon = options_icon
	quit_button.icon = quit_icon
	
	# Connect signals
	play_button.pressed.connect(_on_play_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
