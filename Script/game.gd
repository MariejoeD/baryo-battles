extends Control

@onready var attack_button = $AttackButton
@onready var build_button = $BuildButton
@onready var build_inventory_panel = $BuildInventoryPanel
@onready var grid_container = $BuildInventoryPanel/HScrollContainer/HBoxContainer
@onready var attack_panel = $AttackPanel
@onready var settings_panel = $SettingsPanel


@onready var check_button = $DescriptionPanel/Malacadabra/CheckButton
@onready var english_description = $DescriptionPanel/Malacadabra/EnglishDescription
@onready var tagalog_description = $DescriptionPanel/Malacadabra/TagalogDescription

# Button textures for locked and unlocked states
@onready var locked_textures = {
	"MalacadabraBtn": preload("res://assets/buildings/locked/1.png"),
	"KampoBtn": preload("res://assets/buildings/locked/2.png"),
	"BodegaBtn": preload("res://assets/buildings/locked/3.png"),
	"SandatahangLakasBtn": preload("res://assets/buildings/locked/4.png"),
	"KawaBtn": preload("res://assets/buildings/locked/5.png"),
	"EstakadaBtn": preload("res://assets/buildings/locked/6.png"),
	"BalwarteBtn": preload("res://assets/buildings/locked/7.png"),
	"KwitisBtn": preload("res://assets/buildings/locked/8.png"),
	"KuboBtn": preload("res://assets/buildings/locked/9.png"),
	"TanimBtn": preload("res://assets/buildings/locked/10.png"),
	"ImbakanBtn": preload("res://assets/buildings/locked/11.png")
}

@onready var unlocked_textures = {
	"MalacadabraBtn": preload("res://assets/buildings/unlocked/1.png"),
	"KampoBtn": preload("res://assets/buildings/unlocked/2.png"),
	"BodegaBtn": preload("res://assets/buildings/unlocked/3.png"),
	"SandatahangLakasBtn": preload("res://assets/buildings/unlocked/4.png"),
	"KawaBtn": preload("res://assets/buildings/unlocked/5.png"),
	"EstakadaBtn": preload("res://assets/buildings/unlocked/6.png"),
	"BalwarteBtn": preload("res://assets/buildings/unlocked/7.png"),
	"KwitisBtn": preload("res://assets/buildings/unlocked/8.png"),
	"KuboBtn": preload("res://assets/buildings/unlocked/9.png"),
	"TanimBtn": preload("res://assets/buildings/unlocked/10.png"),
	"ImbakanBtn": preload("res://assets/buildings/unlocked/11.png")
}

# Button states for features
var button_states = {
	"MalacadabraBtn": true,
	"KampoBtn": false,
	"BodegaBtn": false,
	"SandatahangLakasBtn": false,
	"KawaBtn": false,
	"EstakadaBtn": false,
	"BalwarteBtn": false,
	"KwitisBtn": false,
	"KuboBtn": false,
	"TanimBtn": false,
	"ImbakanBtn": false
}

func _ready():
	# Connect main buttons
	attack_button.connect("pressed", Callable(self, "_on_attack_button_pressed"))
	build_button.connect("pressed", Callable(self, "_on_build_button_pressed"))

	# Connect settings button
	var settings_button = $SettingsContainer/SettingsButton
	settings_button.connect("pressed", Callable(self, "_on_settings_button_pressed"))

	# Connect Back to Main Menu button
	var back_to_main_menu_button = $SettingsPanel/BackToMainMenuButton
	back_to_main_menu_button.connect("pressed", Callable(self, "_on_back_to_main_menu_pressed"))

	# Initialize the resource display and button visuals
	update_resource_display()
	update_button_visuals()

func _on_attack_button_pressed():
	print("Attack button pressed!")
	attack_panel.visible = !attack_panel.visible
	build_button.visible = !build_button.visible

func _on_build_button_pressed():
	print("Build button pressed!")
	build_inventory_panel.visible = !build_inventory_panel.visible
	attack_button.visible = !attack_button.visible
	update_button_visuals()

func _on_settings_button_pressed():
	print("Settings button pressed!")
	settings_panel.visible = !settings_panel.visible

func _on_back_to_main_menu_pressed():
	#print("Back to Main Menu button pressed!")
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

# Update the resource display
func update_resource_display():
	#print("Updating resource display...")
	$ResourcePanel/WoodContainer/Label.text = str(Global.wood_qty)
	$ResourcePanel/StoneContainer/Label.text = str(Global.stone_qty)
	# Placeholder for updating UI elements for resources

# Update button visuals based on their states
func update_button_visuals():
	#print("Updating button visuals...")
	for button_name in button_states.keys():
		var button = grid_container.get_node_or_null(button_name)
		if button:
			button.texture_normal = unlocked_textures[button_name] if button_states[button_name] else locked_textures[button_name]


func _on_tree_entered() -> void:
	SignalManager.update_mats.connect(update_resource_display)
	pass # Replace with function body.


func _on_tree_exiting() -> void:
	SignalManager.update_mats.disconnect(update_resource_display)
	
	pass # Replace with function body.
	
#for toggle
	# Set default visibility
	english_description.visible = true
	tagalog_description.visible = false
	
func _on_check_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		english_description.visible = false
		tagalog_description.visible = true
	else:
		english_description.visible = true
		tagalog_description.visible = false
	
