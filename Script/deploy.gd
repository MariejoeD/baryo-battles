extends Control

@export var is_homebase: bool = false
@onready var container = $allyPanel/allyContainer
@onready var spell_panel = %spellPanel
@export var time:float = 120.0
@onready var battle_countdown: Label = %battleCountdown

# Dictionary to store troop counts and selection status
var troop_data = {}
var spell_data = {}

func _ready() -> void:
	troop_data.clear()
	if is_homebase:
		_load_homebase_troops()
	else:
		_load_kampo_troops()
		load_spells()
		battle_countdown.time = time
		battle_countdown.update_time_text()
		battle_countdown.show()
		
	update_ui()
	# Update UI
func update_ui():
	for button in container.get_children():
		var troop_name = button.name  # Button name should match troop name
		if troop_data.has(troop_name):
			button.visible = true
			if !button.is_connected("pressed", _on_button_pressed):
				button.pressed.connect(_on_button_pressed.bind(button))
			update_troop_count_label(button, troop_data[troop_name][0])
		else:
			button.visible = false
func _load_kampo_troops() -> void:
	SaverLoader.saved_game = load(Global.save_path) as SavedGame
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
	if count == 0:
		button.get_child(0).hide()
		troop_data[button.name][1] = false
	label.text = str(count)

	# Set anchors manually for top-right positioning
	label.anchor_right = 1.0
	label.anchor_top = 0.0
	label.anchor_left = 1.0
	label.anchor_bottom = 0.0
	label.offset_left = -15
	label.offset_top = 1

func _on_button_pressed(button:TextureButton) -> void:
	var troop_name = button.name
	for key in troop_data.keys():
		troop_data[key][1] = false
		button.get_parent().find_child(key).get_child(0).hide()
		
	for key in spell_data.keys():
		spell_data[key][1] = false
	troop_data[troop_name][1] = true
	button.get_child(0).show()
	#print("Troop Data:", troop_data)

#load spell
func load_spells():
	if SaverLoader.saved_game == null:
		return

	SaverLoader.saved_game = load(Global.save_path) as SavedGame

	var spell_shown := {}  # Tracks how many of each spell were shown in UI

	# Loop through each building
	for data in SaverLoader.saved_game.building_data:
		if not data.has("spell_data"):
			continue

		var stored_spell = data["spell_data"]["stored_spell"]

		# Loop through spells stored in this building
		for name in stored_spell.keys():
			var shown = spell_shown.get(name, 0)
			if shown >= 2:
				continue  # We already showed max for this spell

			var available = stored_spell[name]
			var to_load = min(2 - shown, available)

			# Update display and internal spell_data
			if spell_data.has(name):
				spell_data[name][0] += to_load
			else:
				spell_data[name] = [to_load, false]

			# Update UI
			var spell_label = spell_panel.get_child(0).find_child(name).get_child(0)
			spell_label.text = str(spell_data[name][0])
			if spell_data[name][0] > 0:
				spell_panel.get_child(0).find_child(name).show()

			# Update how many shown and reduce in this building
			spell_shown[name] = shown + to_load
			stored_spell[name] = available - to_load  # Decrease only from this building

	# Connect buttons
	for button in spell_panel.get_child(0).get_children():
		button.pressed.connect(_on_spell_pressed.bind(button.name))

	ResourceSaver.save(SaverLoader.saved_game, Global.save_path)

#apply spell in display
func _on_spell_pressed(spell_name: String):
	for key in troop_data.keys():
		troop_data[key][1] = false
	for key in spell_data.keys():
		spell_data[key][1] = false
	spell_data[spell_name][1] = true
