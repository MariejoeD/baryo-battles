extends Control

@onready var back_button = $backButton  # Replace with the actual path to your BackButton node

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scene/OptionsMenu.tscn")
