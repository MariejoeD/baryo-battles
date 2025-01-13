extends Camera3D

@export var move_speed: float = 10.0  # Movement speed
@export var rotation_speed: float = 0.005  # Rotation sensitivity
var camera = false
var mouse_delta = Vector2.ZERO
#var rotation_speed = 0.1  # Speed at which the camera rotates
var sensitivity = 0.5  # Sensitivity of mouse movement
var min_vertical_angle = -80  # Min rotation angle in degrees for the X axis (vertical)
var max_vertical_angle = 80  # Max rotation angle in degrees for the X axis (vertical)
var current_rotation_x = 0  # To keep track of vertical rotation
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if camera:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		_handle_movement(delta)
		_handle_rotation()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera = camera
	mouse_delta = Vector2.ZERO
	pass

func _handle_movement(delta):
	var direction = Vector3.ZERO
	
	# Get the camera's local directions
	var forward = -transform.basis.z  # Local forward direction (negative Z axis)
	var right = transform.basis.x     # Local right direction (positive X axis)
	var up = transform.basis.y        # Local up direction (positive Y axis)

	# Check for movement input and move in the corresponding direction
	if Input.is_key_pressed(KEY_W):  # move forward
		direction += forward
	if Input.is_key_pressed(KEY_S):  # move backward
		direction -= forward
	if Input.is_key_pressed(KEY_A):  # move left
		direction -= right
	if Input.is_key_pressed(KEY_D):  # move right
		direction += right
	if Input.is_key_pressed(KEY_SPACE):  # move up
		direction += up
	if Input.is_key_pressed(KEY_SHIFT):  # move down
		direction -= up

	# Normalize direction to prevent faster diagonal movement
	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Move the camera
	translate(direction * move_speed * delta)

	pass
func _handle_rotation():
	var mouse_position = get_viewport().get_mouse_position()

	# Calculate the delta (movement) of the mouse from the last frame
	var mouse_delta = mouse_position - Vector2(get_viewport().get_size() / 2)
	
	# Rotate the camera horizontally based on mouse X movement
	rotate_y(deg_to_rad(-mouse_delta.x * sensitivity))

	# Update the vertical rotation (X axis) based on mouse Y movement, but clamp it
	current_rotation_x = clamp(current_rotation_x - mouse_delta.y * sensitivity, min_vertical_angle, max_vertical_angle)
	rotation_degrees.x = current_rotation_x  # Set the camera's X rotation

	# Reset the mouse position to the center of the screen (for continuous movement tracking)
	get_viewport().warp_mouse(get_viewport().get_size() / 2)  # Move the camera towards the target  # Horizontal rotation (yaw)
	pass
