extends Node3D

# Dictionary to store popups for each tree

# Reference to the popup and other nodes
@onready var panel = $Control
@onready var cut_button = $Control/Button
@onready var uproot_button = $SubViewport/Panel/Control/Uproot
@onready var area = $Area3D

var is_panel_visible = false

func _ready() -> void:
	area.monitoring = true
	panel.visible = false
	cut_button.connect("pressed", Callable(self, "pressed_cut"))


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("test")
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



func pressed_cut():
	print("cut")
	pass
