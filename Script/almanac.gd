extends Control

# Declare necessary nodes for buttons and containers
@onready var back_button = $mainPanel/VBoxContainer/BackButton
@onready var ally_button = $mainPanel/VBoxContainer/AllyButton
@onready var enemy_button = $mainPanel/VBoxContainer/EnemyButton
@onready var enemy_container = $mainPanel/picturePanel/EnemyContainer
@onready var ally_container = $mainPanel/picturePanel/AllyContainer
@onready var description_panel = $mainPanel/picturePanel/DescriptionPanel
var npc_discovered = {}
var npc_discovered_texture = {}

# Hide containers and panels initially
func _ready():
	
	enemy_container.visible = false
	ally_container.visible = false
	description_panel.visible = false

	# Connect button signals using Callable
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	ally_button.connect("pressed", Callable(self, "_on_ally_button_pressed"))
	enemy_button.connect("pressed", Callable(self, "_on_enemy_button_pressed"))
	
	# Connect enemy and ally to their description and initializze their discovered states
	for child in enemy_container.get_child(0).get_children() + ally_container.get_child(0).get_children():
		if child.name not in npc_discovered:
			npc_discovered[child.name] = false
		var folder = "Allyunlocked" if child in ally_container.get_child(0).get_children() else "Enemyunlocked"
		var name_png = child.name+".png"
		var image_path = "res://assets/Almanac/%s/%s" % [folder, name_png]
		if child.name not in npc_discovered_texture:
			npc_discovered_texture[child.name] = load(image_path)
		print("Name: %s, Discovered: %s" % [child.name, npc_discovered[child.name]])
		var desc
		for desc_panel_child in description_panel.get_children():
			if desc_panel_child.name.contains(child.name):
				desc = desc_panel_child
		if child:
			child.pressed.connect(_on_character_button_pressed.bind(desc))
	update_almanac()
	## Connect enemy buttons to their descriptions
	#for child in $mainPanel/picturePanel/EnemyContainer/pictureContainer.get_children():
		#var desc
		#for desc_panel_child in description_panel.get_children():
			#if desc_panel_child.name.contains(child.name):
				#desc = desc_panel_child
		#if child:
			#child.pressed.connect(_on_character_button_pressed.bind(desc))
#
	## Connect ally buttons to their descriptions
	#for child in $mainPanel/picturePanel/AllyContainer/pictureContainer.get_children():
		#var desc
		#for desc_panel_child in description_panel.get_children():
			#if desc_panel_child.name.contains(child.name):
				#desc = desc_panel_child
		#if child:
			#child.pressed.connect(_on_character_button_pressed.bind(desc))


# Back button hides all panels
func _on_back_button_pressed():
	print("Back button pressed!")
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

# Ally button opens the ally container
func _on_ally_button_pressed():
	print("Ally button clicked")
	for i in description_panel.get_children():
		i.visible = false
	description_panel.visible = false
	enemy_container.visible = false
	ally_container.visible = true

# Enemy button opens the enemy container
func _on_enemy_button_pressed():
	print("Enemy button clicked")
	for i in description_panel.get_children():
		i.visible = false
	description_panel.visible = false
	ally_container.visible = false
	enemy_container.visible = true

# Generic handler for character buttons
func _on_character_button_pressed(desc):
	print(desc.name + " button clicked")
	enemy_container.visible = false
	ally_container.visible = false
	description_panel.visible = true
	# Show the specific description
	if desc:
		desc.visible = true




func update_almanac():
	for child in enemy_container.get_child(0).get_children() + ally_container.get_child(0).get_children():
		if npc_discovered[child.name] == true:
			child.texture_normal = npc_discovered_texture[child.name]
			pass
	pass



func _on_tree_entered() -> void:
	print("entered")
	if Global.npc_discovered:
			print("test")
			npc_discovered = Global.npc_discovered
	
	pass # Replace with function body.


func _on_tree_exited() -> void:
	Global.npc_discovered = npc_discovered
	pass # Replace with function body.
