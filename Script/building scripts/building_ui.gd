extends Control

@onready var view_info_panel = $Kubo/viewInformation/Panel
@onready var upgrade_panel = $Kubo/upgrade/Panel
@onready var generate_civilian_panel = $Kubo/generateCivilian/Panel

@onready var view_info_button = $Kubo.get_node_or_null("ViewInfoButton")
@onready var upgrade_button = $Kubo.get_node_or_null("UpgradeButton")
@onready var generate_civilian_button = $Kubo.get_node_or_null("GenerateCivilianButton")

func _ready():
	# Ensure panels are initially hidden
	view_info_panel.hide()
	upgrade_panel.hide()
	generate_civilian_panel.hide()

	# Check if buttons exist before connecting signals
	if view_info_button:
		view_info_button.pressed.connect(_on_view_info_pressed)
	else:
		print("ViewInfoButton not found!")

	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)
	else:
		print("UpgradeButton not found!")

	if generate_civilian_button:
		generate_civilian_button.pressed.connect(_on_generate_civilian_pressed)
	else:
		print("GenerateCivilianButton not found!")

func _on_view_info_pressed():
	_toggle_panel(view_info_panel)

func _on_upgrade_pressed():
	_toggle_panel(upgrade_panel)

func _on_generate_civilian_pressed():
	_toggle_panel(generate_civilian_panel)

# Helper function to toggle panel visibility
func _toggle_panel(panel):
	if panel:
		panel.visible = !panel.visible
