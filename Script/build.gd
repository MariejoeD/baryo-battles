extends Node

@export var hbox: HBoxContainer
@export var build_button: Button
@export var attack_button: Button
@export var build_panel: Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the "pressed" signal for each TextureButton child
	for child in hbox.get_children():
		if child is TextureButton:
			child.connect("pressed", Callable(self, "_on_btn_pressed").bind(child))  # Use Callable and bind the button
	pass


# Function called when a button is pressed
func _on_btn_pressed(button: TextureButton) -> void:
	# Print the name of the button
	print("Button pressed:", button.name)
	build_button.visible = !build_button.visible
	build_panel.visible = !build_panel.visible
	
	
	pass
