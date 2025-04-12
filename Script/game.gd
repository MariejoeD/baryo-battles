extends Control

@onready var attack_button = $AttackButton
@onready var build_button = $BuildButton
@onready var build_inventory_panel = $BuildInventoryPanel
@onready var grid_container = $BuildInventoryPanel/HScrollContainer/HBoxContainer
@onready var attack_panel = $AttackPanel
@onready var settings_panel = $SettingsPanel

@onready var english_description = $DescriptionPanel/Malacadabra/EnglishDescription

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
	if MusicController.is_music_on and !MusicController.music_player.playing:
		MusicController.music_player.play()

	attack_button.connect("pressed", Callable(self, "_on_attack_button_pressed"))
	build_button.connect("pressed", Callable(self, "_on_build_button_pressed"))

	var settings_button = $SettingsContainer/SettingsButton
	settings_button.connect("pressed", Callable(self, "_on_settings_button_pressed"))

	var back_to_main_menu_button = $SettingsPanel/BackToMainMenuButton
	back_to_main_menu_button.connect("pressed", Callable(self, "_on_back_to_main_menu_pressed"))

	for i in $BuildInventoryPanel/HScrollContainer/HBoxContainer.get_children():
		i.get_node("informationButton").pressed.connect(description_show.bind(i))

	update_resource_display()
	update_button_visuals()

func _on_attack_button_pressed():
	attack_panel.visible = !attack_panel.visible
	build_button.visible = !build_button.visible

func _on_build_button_pressed():
	build_inventory_panel.visible = !build_inventory_panel.visible
	attack_button.visible = !attack_button.visible
	update_button_visuals()

func _on_settings_button_pressed():
	settings_panel.visible = !settings_panel.visible

func _on_back_to_main_menu_pressed():
	save_troops_to_file()
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

func save_troops_to_file():
	var save_dict = {}
	for kampo in Global.all_kampo:
		save_dict[kampo.get_instance_id()] = kampo.troops

	var file = FileAccess.open("user://troops_data.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_dict))
	file.close()

func update_resource_display():
	$ResourcePanel/FoodContainer/Label.text = str(Global.food_qty)
	$ResourcePanel/WoodContainer/Label.text = str(Global.wood_qty)
	$ResourcePanel/StoneContainer/Label.text = str(Global.stone_qty)

func update_button_visuals():
	for button_name in button_states.keys():
		var button = grid_container.get_node_or_null(button_name)
		if button:
			button.get_node("resourceAmount").visible = button_states[button_name]
			button.texture_normal = unlocked_textures[button_name] if button_states[button_name] else locked_textures[button_name]

func description_show(building):
	if not button_states[building.name]:
		return
	
	var building_name = building.name.trim_suffix("Btn")
	build_inventory_panel.visible = false
	$DescriptionPanel.visible = true

	for child in $DescriptionPanel.get_children():
		child.visible = false

	$DescriptionPanel.get_node(building_name).visible = true

func _input(event):
	if event is InputEventMouseButton and event.pressed and $DescriptionPanel.visible:
		if not $DescriptionPanel.get_global_rect().has_point(event.position):
			$DescriptionPanel.visible = false
			build_inventory_panel.visible = true

func _on_tree_entered() -> void:
	SignalManager.update_mats.connect(update_resource_display)

func _on_tree_exiting() -> void:
	SignalManager.update_mats.disconnect(update_resource_display)
