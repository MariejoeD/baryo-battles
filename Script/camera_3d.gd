extends Camera3D

@export var zoom_speed := 2.0
@export var pan_speed := 3
@export var cap:= 100
@export var min_zoom := 3
@export var max_zoom := 42

var is_panning := false
var last_mouse_pos := Vector2.ZERO
@export var second_cam: Camera3D

func _process(delta: float) -> void:
	
		#print("pan")
	_pan(delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		# Zoom in and out with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1)

		# Start panning when middle mouse button is pressed
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			if is_panning:
				last_mouse_pos = event.position


	

# Zooming function based on camera's view direction (forward/backward)
func _zoom(direction: int):
	# Move the camera along its local Z axis (forward/backward)
	var zoom_amount := direction * zoom_speed
	var new_pos := transform.origin + transform.basis.z * zoom_amount

	# Only zoom if it's within the specified range
	if new_pos.y > min_zoom and new_pos.y < max_zoom:
		transform.origin = new_pos
		second_cam.transform.origin = new_pos

# Panning function based on camera's local space
func _pan(delta: float):
	if not is_panning:
		return

	var current_mouse_pos = get_parent().get_mouse_position()
	var displacement = current_mouse_pos - last_mouse_pos
	last_mouse_pos = current_mouse_pos

	var velocity = (transform.basis.x * -displacement.x + transform.basis.y * displacement.y) * delta * pan_speed
	var proposed_position = position + velocity

	# Clamp all 3 axes
	proposed_position.x = clamp(proposed_position.x, -cap, cap)
	proposed_position.y = clamp(proposed_position.y, min_zoom, max_zoom)
	proposed_position.z = clamp(proposed_position.z, -cap, cap)

	# Apply clamped position
	position = proposed_position
	second_cam.position = proposed_position
