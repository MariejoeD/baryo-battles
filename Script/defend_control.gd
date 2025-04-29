extends Control

@onready var warning_container = $warningContainer
@onready var assign_troop_btn = $assignTroop
@onready var ui_node = $"../UI"
@onready var game_ui: Control = $"../../Base/Control"

func _ready():
	self.visible = false
	ui_node.visible = false
	assign_troop_btn.pressed.connect(_on_assign_troop_pressed)

func show_defense_warning():
	show()
	print("⚠️ Defense Warning Shown")

func _on_assign_troop_pressed():
	print("✅ Troops Assigned. UI Activated.")
	hide()
	ui_node.visible = true
	ui_node.troop_data.clear()
	ui_node._load_homebase_troops()
	ui_node.update_ui()
	game_ui.hide()
