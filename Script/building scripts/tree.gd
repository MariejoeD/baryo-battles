extends Node3D

# Dictionary to store popups for each tree
var tree_popups = {}

# Reference to the popup and other nodes
@onready var popup = $Control/VBoxContainer
@onready var cut_button = $Control/VBoxContainer/Cut
@onready var uproot_button = $Control/VBoxContainer/Uproot
@onready var area = $Area3D

func _ready() -> void:
	area.monitoring = true
	popup.visible = false  # Ensure the popup is initially hidden

	# Hide all popups initially
	for tree in get_tree().get_nodes_in_group("trees"):
		var tree_popup = tree.get_node("Control/VBoxContainer")
		tree_popup.visible = false
		tree_popups[tree] = tree_popup
		tree.get_node("Area3D").connect("input_event", _on_tree_input_event.bind(tree))

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			popup.visible = true  # Show the container when the tree is clicked
			print("Tree clicked")

func _on_tree_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, tree: Node3D) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Hide all popups first
			for tree_popup in tree_popups.values():
				tree_popup.visible = false

			# Show only the clicked tree's popup
			tree_popups[tree].visible = true
			print(tree.name + " clicked")
