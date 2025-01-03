extends Node3D

# Reference to the popup
@onready var popup = $Popup
@onready var cut_button = $Popup/Cut
@onready var uproot_button = $Popup/Uproot
@onready var area = $Area3D


func _ready() -> void:
	area.monitoring = true
	pass

		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
	pass # Replace with function body.


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			print("test")
	pass # Replace with function body.
