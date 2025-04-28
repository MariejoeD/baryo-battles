extends Control

@export var is_homebase: bool = false
@onready var container = $allyPanel/allyContainer
@onready var spell_panel = %spellPanel

# Dictionary to store troop counts and selection status
var troop_data = {}

func _ready() -> void:
	troop_data.clear()
	if is_homebase:
		_load_homebase_troops()
	else:
		_load_kampo_troops()
	load_spells()
	update_ui()
	# Update UI
func update_ui():
	for button in container.get_children():
		var troop_name = button.name  # Button name should match troop name
		if troop_data.has(troop_name):
			button.visible = true
			button.pressed.connect(_on_button_pressed.bind(troop_name))
			update_troop_count_label(button, troop_data[troop_name][0])
		else:
			button.visible = false
func _load_kampo_troops() -> void:
	SaverLoader.saved_game = load("res://save.tres") as SavedGame
	SaverLoader.load_kampo_troops()
	for kampo in Global.kampo_troops.values():
		for troop in kampo.keys():
			troop_data[troop] = [kampo[troop], false]

func _load_homebase_troops() -> void:
	var entities = get_tree().current_scene.find_child("Entities")
	if entities:
		for entity in entities.get_children():
			if entity.is_in_group("Good") and entity.has_node("Stats"):
				var stats = entity.get_node("Stats")
				var name = stats.Name  # Assuming there's a `name` property
				print(name)
				if name != "":
					if not troop_data.has(name):
						troop_data[name] = [0, false]
					troop_data[name][0] += 1

func update_troop_count_label(button: TextureButton, count: int) -> void:
	var label = button.get_node_or_null("CountLabel")
	if label == null:
		label = Label.new()
		label.name = "CountLabel"
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_child(label)

	label.text = str(count)

	# Set anchors manually for top-right positioning
	label.anchor_right = 1.0
	label.anchor_top = 0.0
	label.anchor_left = 1.0
	label.anchor_bottom = 0.0
	label.offset_left = -15
	label.offset_top = 1

func _on_button_pressed(troop_name: String) -> void:
	for key in troop_data.keys():
		troop_data[key][1] = false
	troop_data[troop_name][1] = true
	print("Troop Data:", troop_data)

#load spell
func load_spells():
	SaverLoader.saved_game = load("res://save.tres") as SavedGame
	for data in SaverLoader.saved_game.building_data:
		var stored_spell = {}
		if data.has("spell_data"):
			stored_spell= data["spell_data"]["stored_spell"]
		for name in stored_spell.keys():
			spell_panel.get_child(0).find_child(name).get_child(0).text = str(int(spell_panel.get_child(0).find_child(name).get_child(0).text) + stored_spell[name])
			if spell_panel.get_child(0).find_child(name).get_child(0).text != "0":
				spell_panel.get_child(0).find_child(name).show()
#apply spell in display
