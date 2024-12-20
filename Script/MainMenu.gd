extends Control

# References to buttons
@onready var play_button = $VBoxContainer/play
@onready var options_button = $VBoxContainer/options
@onready var quit_button = $VBoxContainer/quit
@onready var almanac_button = $AlmanacContainer/AlmanacButton

# Load icon textures
var play_icon = preload("res://assets/game/play_icon.png")
var options_icon = preload("res://assets/game/option_icon.png")
var quit_icon = preload("res://assets/game/quit_icon.png")
var almanac_icon = preload("res://assets/button/almanac.png")

# Function to start the game
func _on_play_button_pressed():
	print("Play button pressed!")
	get_tree().change_scene_to_file("res://Scene/HomeBase.tscn")

# Function to open options
func _on_options_button_pressed():
	print("Options button pressed!")
	get_tree().change_scene_to_file("res://Scene/OptionsMenu.tscn")

# Function to quit the game
func _on_quit_button_pressed():
	get_tree().quit()

# Function to open Almanac scene
func _on_almanac_button_pressed():
	print("Almanac button pressed!")
	get_tree().change_scene_to_file("res://Scene/Almanac.tscn")

func _ready():
	var cursor_texture = preload("res://assets/game/cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture)
	
	# Assign icons to buttons
	if play_button.has_method("set_icon"):
		play_button.icon = play_icon
	if options_button.has_method("set_icon"):
		options_button.icon = options_icon
	if quit_button.has_method("set_icon"):
		quit_button.icon = quit_icon
	if almanac_button.has_method("set_icon"):
		almanac_button.icon = almanac_icon

	# Connect signals (check if buttons exist and signals are valid)
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	if almanac_button:
		almanac_button.pressed.connect(_on_almanac_button_pressed)
