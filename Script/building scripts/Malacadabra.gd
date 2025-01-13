extends MeshInstance3D
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.




func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("test")
		if event.button_index == 1 and event.pressed:
			print("pressed")
	pass # Replace with function body.
