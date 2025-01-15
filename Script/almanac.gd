extends Control

# Declare necessary nodes for buttons and containers
@onready var back_button = $mainPanel/VBoxContainer/BackButton
@onready var ally_button = $mainPanel/VBoxContainer/AllyButton
@onready var enemy_button = $mainPanel/VBoxContainer/EnemyButton
@onready var enemy_container = $mainPanel/picturePanel/EnemyContainer
@onready var description_panel = $mainPanel/picturePanel/DescriptionPanel



# Hide containers and panels initially
func _ready():
	enemy_container.visible = false
	description_panel.visible = false

	# Connect button signals using Callable
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	ally_button.connect("pressed", Callable(self, "_on_ally_button_pressed"))
	enemy_button.connect("pressed", Callable(self, "_on_enemy_button_pressed"))

	for child in $mainPanel/picturePanel/EnemyContainer/pictureContainer.get_children():
		var desc
		for desc_panel_child in description_panel.get_children():
			if desc_panel_child.name.contains(child.name):
				desc = desc_panel_child
		if child:
			child.pressed.connect(_on_character_button_pressed.bind(desc))
		

# Back button hides all panels
func _on_back_button_pressed():
	print("Back button pressed!")
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

# Ally button functionality (add as needed)
func _on_ally_button_pressed():
	print("Ally button clicked")
	# Implement ally-related behavior here

# Enemy button opens the enemy container
func _on_enemy_button_pressed():
	for i in description_panel.get_children():
		i.visible = false
	description_panel.visible = false
	enemy_container.visible = true
	description_panel.visible = false

# Generic handler for character buttons
func _on_character_button_pressed(desc):
	print(desc.name + " button clicked")
	enemy_container.visible = false
	description_panel.visible = true
	#var panel = get_node_or_null(descriptions[_name])
	# Show the specific description
	if desc:
		desc.visible = true
		
