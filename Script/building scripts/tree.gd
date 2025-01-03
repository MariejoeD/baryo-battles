extends Node3D

# Dictionary to store popups for each tree

# Reference to the popup and other nodes
@onready var panel = $SubViewport/Panel
@onready var cut_button = $SubViewport/Panel/Control/Cut
@onready var uproot_button = $SubViewport/Panel/Control/Uproot
@onready var area = $Area3D

var is_panel_visible = false

func _ready() -> void:
	area.monitoring = true
	panel.visible = false
	#popup.visible = false  # Ensure the popup is initially hidden

	# Hide all popups initially
	#for tree in get_tree().get_nodes_in_group("trees"):
		#var tree_popup = tree.get_node("Control/VBoxContainer")
		#tree_popup.visible = false
		#tree_popups[tree] = tree_popup
		#tree.get_node("Area3D").connect("input_event", _on_tree_input_event.bind(tree))

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if panel.visible:
				panel.visible = false  # hide the panel when already visible
				is_panel_visible = false
			else:
				panel.visible = true # show panel
				is_panel_visible = true
				
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if is_panel_visible:
			var viewport = get_viewport()
			var clicked_pos = viewport.get_mouse_position()
			
			#checked if the click is outside the panel
			if not panel.get_global_rect().has_point(clicked_pos):
				panel.visible = false
				is_panel_visible = false
#func _on_tree_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, tree: Node3D) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			## Hide all popups first
			#for tree_popup in tree_popups.values():
				#tree_popup.visible = false
#
			## Show only the clicked tree's popup
			#tree_popups[tree].visible = true
			#print(tree.name + " clicked")
