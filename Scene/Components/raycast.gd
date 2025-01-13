extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	
	var mouse_position = get_viewport().get_mouse_position()  # Get the mouse position in screen coordinates

	# Create a ray from the camera to the mouse position
	var from = self.project_ray_origin(mouse_position)
	var to = from + self.project_ray_normal(mouse_position) * 1000  # Adjust the length as needed
	#print("Ray from: ", from, " to: ", to)  # Debug ray direction

	var query = PhysicsRayQueryParameters3D.create(from, to)

	# Perform a raycast to find where to spawn the NPC
	var result = space_state.intersect_ray(query)
	if result:
		print(result["position"])
	pass
