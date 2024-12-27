extends Control

# Preload or declare nodes
@onready var enemy_container = $Panel/EnemyContainer
@onready var ally_container = $Panel/AllyContainer
@onready var back_button = $Panel/BackButton
@onready var enemy_button = $Panel/enemyButton
@onready var ally_button = $Panel/allyButton

func _ready():
	# Hide containers initially
	enemy_container.visible = false
	ally_container.visible = false

	# Connect button signals
	enemy_button.connect("pressed", Callable(self, "_on_enemy_button_pressed"))
	ally_button.connect("pressed", Callable (self, "_on_ally_button_pressed"))
	back_button.connect("pressed", Callable (self, "_on_back_button_pressed"))

func _on_enemy_button_pressed():
	# Open Enemy Container and hide Ally Container
	enemy_container.visible = true
	ally_container.visible = false

func _on_ally_button_pressed():
	# Open Ally Container and hide Enemy Container
	ally_container.visible = true
	enemy_container.visible = false

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
