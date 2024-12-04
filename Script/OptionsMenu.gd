extends Control

@onready var back_button = $backButton
@onready var music_button = $VBoxContainer/musicButton
@onready var sound_button = $VBoxContainer/SoundButton
@onready var about_button = $VBoxContainer/AboutButton
@onready var reset_game_button = $ResetGameButton
@onready var reset_dialog = $ResetDialog
@onready var timer = Timer.new()
@onready var reset_text_input = $ResetDialog/LineEdit  # Ensure this path is correct (change to TextEdit or LineEdit)

var music_on_icon = preload("res://assets/game/musicOn.png")
var music_off_icon = preload("res://assets/game/musicOff.png")
var sound_on_icon = preload("res://assets/game/audioOn.png")
var sound_off_icon = preload("res://assets/game/audioOff.png")
var back_icon = preload("res://assets/game/backButton.png")
var reset_icon = preload("res://assets/game/resetGame.png")
var about_icon = preload("res://assets/game/about.png")

var is_music_on = true
var is_sound_on = true

func _ready():
	var cursor_texture = preload("res://assets/game/cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture)
	
	music_button.icon = music_on_icon
	music_button.text = "Music: On"
	sound_button.icon = sound_on_icon
	sound_button.text = "Sound: On"
	back_button.icon = back_icon
	reset_game_button.icon = reset_icon
	about_button.icon = about_icon

	back_button.pressed.connect(_on_back_button_pressed)
	music_button.pressed.connect(_on_music_button_pressed)
	sound_button.pressed.connect(_on_sound_button_pressed)
	about_button.pressed.connect(_on_about_button_pressed)
	reset_game_button.pressed.connect(_on_reset_game_button_pressed)

	reset_dialog.connect("confirmed", Callable(self, "_on_reset_confirmed"))
	add_child(timer)

func _on_music_button_pressed():
	is_music_on = !is_music_on
	if is_music_on:
		music_button.icon = music_on_icon
		music_button.text = "Music: On"
	else:
		music_button.icon = music_off_icon
		music_button.text = "Music: Off"

func _on_sound_button_pressed():
	is_sound_on = !is_sound_on
	if is_sound_on:
		sound_button.icon = sound_on_icon
		sound_button.text = "Sound: On"
	else:
		sound_button.icon = sound_off_icon
		sound_button.text = "Sound: Off"

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

func _on_about_button_pressed():
	print("About button pressed!")

func _on_reset_game_button_pressed():
	reset_dialog.dialog_text = "Are you sure you want to reset the game? Type 'confirm reset' to proceed."
	reset_dialog.popup_centered()

	reset_text_input.text = ""  # Clear text field when the dialog pops up

func _on_reset_confirmed():
	if reset_text_input.text == "confirm reset":
		get_tree().change_scene_to_file("res://Scene/loading.tscn")  # Transitions to loading screen
	else:
		print("Reset not confirmed. Please type 'confirm reset' to proceed.")
		reset_dialog.hide()  # Hide dialog if reset is not confirmed
