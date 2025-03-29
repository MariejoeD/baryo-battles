extends Control

@onready var container = $allyPanel/allyContainer

# Store the selected troop name
var selected_troop: String = ""

func _ready() -> void:
	print(Global.kampo_troops)
	var troop_counts = {}  # Dictionary to store troop counts

	for troops in Global.kampo_troops.values():  # Loop directly through stored troop lists
		for troop in troops:
			var name = troop.get("name", "")
			if name != "":
				troop_counts[name] = troop_counts.get(name, 0) + 1
				print(troop_counts[name])

	# Update UI
	for button in container.get_children():
		var troop_name = button.name  # Button name should match troop name
		if troop_counts.has(troop_name):
			button.visible = true  # Show button if troop exists
			button.pressed.connect(_on_button_pressed.bind(troop_name))  # Pass troop name
			update_troop_count_label(button, troop_counts[troop_name])
		else:
			button.visible = false  # Hide button if troop doesn't exist

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

	# Offset so it's not exactly at the edge
	label.offset_left = -15
	label.offset_top = 1

# Function to set the selected troop when a button is clicked
func _on_button_pressed(troop_name: String) -> void:
	selected_troop = troop_name
	print("Selected Troop:", selected_troop)
