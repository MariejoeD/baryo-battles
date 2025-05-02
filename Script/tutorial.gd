extends Control

@onready var build_tutorial = $mainPanel/buildTutorial
@onready var attack_tutorial = $mainPanel/attackTutorial
@onready var resource_tutorial = $mainPanel/resourceTutorial
@onready var train_tutorial = $mainPanel/trainTutorial

@onready var btn_build = $howToBuild
@onready var btn_attack = $howToAttack
@onready var btn_resource = $howToCollectResource
@onready var btn_train = $howToTrain
@onready var btn_exit = $exitButton  # Make sure your exit button is named exactly this

func _ready():
	btn_build.pressed.connect(_on_build_pressed)
	btn_attack.pressed.connect(_on_attack_pressed)
	btn_resource.pressed.connect(_on_resource_pressed)
	btn_train.pressed.connect(_on_train_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)

func _on_build_pressed():
	_show_only_panel(build_tutorial)

func _on_attack_pressed():
	_show_only_panel(attack_tutorial)

func _on_resource_pressed():
	_show_only_panel(resource_tutorial)

func _on_train_pressed():
	_show_only_panel(train_tutorial)

func _on_exit_pressed():
	hide()  # Closes/removes the tutorial scene

func _show_only_panel(panel_to_show):
	var panels = [build_tutorial, attack_tutorial, resource_tutorial, train_tutorial]
	for panel in panels:
		panel.visible = (panel == panel_to_show)
