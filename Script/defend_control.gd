extends Control

@onready var warning_container = $warningContainer
@onready var assign_troop_btn = $assignTroop
@onready var ui_node = $"../UI"

func _ready():
	self.visible = false
	warning_container.visible = false
	$assignTroop.visible = false
	ui_node.visible = false
	assign_troop_btn.pressed.connect(_on_assign_troop_pressed)

func show_defense_warning():
	self.visible = true
	warning_container.visible = true
	$assignTroop.visible = true
	print("⚠️ Defense Warning Shown")

func _on_assign_troop_pressed():
	print("✅ Troops Assigned. UI Activated.")
	ui_node.visible = true
	ui_node.troop_data.clear()
	ui_node._load_homebase_troops()
	ui_node.update_ui()
	# Hide BuildButton and AttackButton using find_child
	var build_button = get_tree().get_root().find_child("BuildButton", true, false)
	var attack_button = get_tree().get_root().find_child("AttackButton", true, false)

	if build_button:
		build_button.visible = false
		print("🔧 BuildButton hidden.")	

	if attack_button:
		attack_button.visible = false
		print("⚔️ AttackButton hidden.")
