extends Control

@onready var attack_button = $AttackButton
@onready var build_button = $BuildButton
@onready var build_inventory_panel = $BuildInventoryPanel
@onready var grid_container = $BuildInventoryPanel/HScrollContainer/GridContainer
@onready var attack_panel = $AttackPanel


func _ready():
	# Update connect calls to use Callable
	attack_button.connect("pressed", Callable(self, "_on_attack_button_pressed"))
	build_button.connect("pressed", Callable(self, "_on_build_button_pressed"))
	
	print("AttackButton:", attack_button)
	print("BuildButton:", build_button)
	print("BuildInventoryPanel:", build_inventory_panel)


func _on_attack_button_pressed():
	print("Attack button pressed!")
	attack_panel.visible = !attack_panel.visible
	build_button.visible = !build_button.visible

func _on_build_button_pressed():
	build_inventory_panel.visible = !build_inventory_panel.visible
	attack_button.visible = !attack_button.visible
		

func _on_slot_pressed(slot_index: int):
	print("Slot %d clicked!" % slot_index)
