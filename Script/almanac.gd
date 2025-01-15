extends Control

# Declare necessary nodes for buttons and containers
@onready var back_button = $mainPanel/VBoxContainer/BackButton
@onready var ally_button = $mainPanel/VBoxContainer/AllyButton
@onready var enemy_button = $mainPanel/VBoxContainer/EnemyButton
@onready var enemy_container = $mainPanel/picturePanel/EnemyContainer
@onready var description_panel = $mainPanel/picturePanel/DescriptionPanel

# Dictionary to store button-to-description mapping
var descriptions = {
	"Agta": $mainPanel/picturePanel/DescriptionPanel/AgtaDescription,
	"Duwende": $mainPanel/picturePanel/DescriptionPanel/DuwendeDescription,
	"Tikbalang": $mainPanel/picturePanel/DescriptionPanel/TikbalangDescription,
	"Kapre": $mainPanel/picturePanel/DescriptionPanel/KapreDescription,
	"Manananggal": $mainPanel/picturePanel/DescriptionPanel/MananaggalDescription,
	"Sigbin": $mainPanel/picturePanel/DescriptionPanel/SigbinDescription,
	"TinienteGimo": $mainPanel/picturePanel/DescriptionPanel/TinienteGimoDescription,
	"Amomongo": $mainPanel/picturePanel/DescriptionPanel/AmomongoDescription,
	"Mangkukulam": $mainPanel/picturePanel/DescriptionPanel/MangkukulamDescription,
	"Lizardo": $mainPanel/picturePanel/DescriptionPanel/LizardoDescription,
	# Add other descriptions here
}

# Hide containers and panels initially
func _ready():
	enemy_container.visible = false
	description_panel.visible = false

	# Connect button signals using Callable
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	ally_button.connect("pressed", Callable(self, "_on_ally_button_pressed"))
	enemy_button.connect("pressed", Callable(self, "_on_enemy_button_pressed"))

	for name in descriptions.keys():
		var button = $mainPanel/picturePanel/EnemyContainer/pictureContainer.get_node(name)
		if button:
			button.connect("pressed", Callable(self, "_on_character_button_pressed").bind(name))

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
	enemy_container.visible = true
	description_panel.visible = false

# Generic handler for character buttons
func _on_character_button_pressed(name):
	print(name + " button clicked")
	description_panel.visible = true
	
	# Show the specific description
	if descriptions.has(name):
		print(descriptions.get(self.name))
		descriptions[name].visible = true
		
