extends Camera3D

@export var zoom_speed := 2.0
@export var pan_speed := 1
@export var min_zoom := 20
@export var max_zoom := 80

var is_panning := false
var last_mouse_pos := Vector2.ZERO

func _process(delta: float) -> void:
	if is_panning:
		print("pan")
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
	var distance := new_pos.distance_to(Vector3.ZERO)  # Calculate distance from the origin

	# Only zoom if it's within the specified range
	if distance > min_zoom and distance < max_zoom:
		transform.origin = new_pos

# Panning function based on camera's local space
func _pan(delta: float):
	if not is_panning:
		return
	# Get the current mouse position
	var current_mouse_pos = get_parent().get_mouse_position()
	var displacement = current_mouse_pos - last_mouse_pos
	last_mouse_pos = current_mouse_pos
	
	# Calculate panning velocity based on the camera's local space
	var velocity = (transform.basis.x * -displacement.x + transform.basis.z * -displacement.y) * delta * pan_speed
	
	# Apply the calculated velocity to move the camera
	position -= velocity
