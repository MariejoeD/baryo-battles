extends Control

@onready var attack_button = $AttackButton
@onready var build_button = $BuildButton
@onready var build_inventory_panel = $BuildInventoryPanel
@onready var grid_container = $BuildInventoryPanel/HScrollContainer/GridContainer
@onready var attack_panel = $AttackPanel

# Resource labels and icons
@onready var food_label = $ResourcePanel/FoodContainer/Label
@onready var stone_label = $ResourcePanel/StoneContainer/Label
@onready var wood_label = $ResourcePanel/WoodContainer/Label

# Settings button and panel
@onready var settings_button = $SettingsContainer/SettingsButton
@onready var settings_panel = $SettingsPanel
@onready var back_to_main_menu_button = $SettingsPanel/BackToMainMenuButton

# Resource amounts
var food = 0
var stone = 0
var wood = 0

func _ready():
	# Update connect calls to use Callable
	attack_button.connect("pressed", Callable(self, "_on_attack_button_pressed"))
	build_button.connect("pressed", Callable(self, "_on_build_button_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_button_pressed"))
	back_to_main_menu_button.connect("pressed", Callable(self, "_on_back_to_main_menu_pressed"))

	print("AttackButton:", attack_button)
	print("BuildButton:", build_button)
	print("BuildInventoryPanel:", build_inventory_panel)

	# Initialize the resource display
	update_resource_display()
	
	# Hide settings panel initially
	settings_panel.visible = false

func _on_attack_button_pressed():
	print("Attack button pressed!")
	attack_panel.visible = !attack_panel.visible
	build_button.visible = !build_button.visible

func _on_build_button_pressed():
	build_inventory_panel.visible = !build_inventory_panel.visible
	attack_button.visible = !attack_button.visible

func _on_settings_button_pressed():
	settings_panel.visible = !settings_panel.visible

func _on_back_to_main_menu_pressed():
	print("Back to Main Menu button pressed!")
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

func _on_slot_pressed(slot_index: int):
	print("Slot %d clicked!" % slot_index)

# Update the resource display
func update_resource_display():
	food_label.text = "Food: %d" % food
	stone_label.text = "Stone: %d" % stone
	wood_label.text = "Wood: %d" % wood

# Functions to modify resources
func add_food(amount: int):
	food += amount
	update_resource_display()

func add_stone(amount: int):
	stone += amount
	update_resource_display()

func add_wood(amount: int):
	wood += amount
	update_resource_display()
