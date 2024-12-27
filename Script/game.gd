extends Control

@onready var attack_button = $AttackButton
@onready var build_button = $BuildButton
@onready var build_inventory_panel = $BuildInventoryPanel
@onready var grid_container = $BuildInventoryPanel/HScrollContainer/GridContainer
@onready var attack_panel = $AttackPanel


# Button textures for locked and unlocked states
@export var locked_textures = {
	"MalacadabraBtn": preload("res://assets/buildings/locked/1.png"),
	"KampoBtn": preload("res://assets/buildings/locked/2.png"),
	"KawaBtn2": preload("res://assets/buildings/locked/5.png"),
	"SandatahangLakasBtn": preload("res://assets/buildings/locked/4.png"),
	"EstakadaBtn": preload("res://assets/buildings/locked/6.png"),
	"BalwarteBtn2": preload("res://assets/buildings/locked/7.png"),
	"KuwitisBtn": preload("res://assets/buildings/locked/8.png"),
	"KuboBtn2": preload("res://assets/buildings/locked/9.png"),
	"TanimBtn": preload("res://assets/buildings/locked/10.png"),
	"ImbakanBtn": preload("res://assets/buildings/locked/11.png"),
	"BodegaBtn": preload("res://assets/buildings/locked/3.png")
}

@export var unlocked_textures = {
	"MalacadabraBtn": preload("res://assets/buildings/unlocked/1.png"),
	"KampoBtn": preload("res://assets/buildings/unlocked/2.png"),
	"KawaBtn2": preload("res://assets/buildings/unlocked/5.png"),
	"SandatahangLakasBtn": preload("res://assets/buildings/unlocked/4.png"),
	"EstakadaBtn": preload("res://assets/buildings/unlocked/6.png"),
	"BalwarteBtn2": preload("res://assets/buildings/unlocked/7.png"),
	"KuwitisBtn": preload("res://assets/buildings/unlocked/8.png"),
	"KuboBtn2": preload("res://assets/buildings/unlocked/9.png"),
	"TanimBtn": preload("res://assets/buildings/unlocked/10.png"),
	"ImbakanBtn": preload("res://assets/buildings/unlocked/11.png"),
	"BodegaBtn": preload("res://assets/buildings/unlocked/3.png")
}

# Button states for features
var button_states = {
	"MalacadabraBtn": false,
	"KampoBtn": false,
	"KawaBtn2": false,
	"SandatahangLakasBtn": false,
	"EstakadaBtn": false,
	"BalwarteBtn2": false,
	"KuwitisBtn": false,
	"KuboBtn2": false,
	"TanimBtn": false,
	"ImbakanBtn": false,
	"BodegaBtn": false
}

func _ready():
	# Update connect calls to use Callable
	attack_button.connect("pressed", Callable(self, "_on_attack_button_pressed"))
	build_button.connect("pressed", Callable(self, "_on_build_button_pressed"))
	
	print("AttackButton:", attack_button)
	print("BuildButton:", build_button)
	print("BuildInventoryPanel:", build_inventory_panel)

<<<<<<< Updated upstream
=======
	# Initialize the resource display
	update_resource_display()

	# Hide settings panel initially
	settings_panel.visible = false
>>>>>>> Stashed changes

	# Initialize button visuals
	update_button_visuals()

func _on_attack_button_pressed():
	print("Attack button pressed!")
	attack_panel.visible = !attack_panel.visible
	build_button.visible = !build_button.visible

func _on_build_button_pressed():
	build_inventory_panel.visible = !build_inventory_panel.visible
	attack_button.visible = !attack_button.visible
		

func _on_slot_pressed(slot_index: int):
	print("Slot %d clicked!" % slot_index)
<<<<<<< Updated upstream
=======

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

# Update button visuals based on their states
func update_button_visuals():
	for button_name in button_states.keys():
		var button = grid_container.get_node_or_null(button_name)
		if button:
			if button_states[button_name]:
				button.texture_normal = unlocked_textures[button_name]
			else:
				button.texture_normal = locked_textures[button_name]
>>>>>>> Stashed changes
