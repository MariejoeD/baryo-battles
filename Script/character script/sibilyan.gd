extends CharacterBody3D


#@onready var amap = $"Base/AMap/floor setup"
var speed = 10
var path = []
var path_index = 0
var parent
var gparent
var base
var camera
var amap
var moveb
var animation
func _ready():
	parent = get_parent()
	gparent = parent.get_parent()
	base = gparent.get_parent()
	amap = base.get_node("AMap/floor setup")
	animation = $AnimationPlayer
	animation.play("idle",-1,1,true)
	pass
func _process(delta: float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		moveb = true
		var space_state = get_world_3d().direct_space_state
		var mouse_position = get_viewport().get_mouse_position()  # Get the mouse position in screen coordinates

		camera = base.get_node("SubViewportContainer/SubViewport/Camera3D")
		# Create a ray from the camera to the mouse position
		var from = camera.project_ray_origin(mouse_position)
		var to = from + camera.project_ray_normal(mouse_position) * 1000  # Adjust the length as needed
		#print("Ray from: ", from, " to: ", to)  # Debug ray direction

		var query = PhysicsRayQueryParameters3D.create(from, to)

		# Perform a raycast to find where to spawn the NPC
		var result = space_state.intersect_ray(query)
		if result.has("position"):
			
			var position = result.position
			var pos = Vector3(
					floor(position.x),  # Snap X to integer
					1,  # Snap Y to integer
					floor(position.z)   # Snap Z to integer
				)
			
		else:
			print()
	if moveb:
		#global_transform.origin.y = 0
		move(delta)
		if animation.current_animation != "walk":
			animation.play("walk", -1, 1, true)
	else:
		if animation.current_animation != "idle":
			animation.play("idle", -1, 1, true)
	pass

func move(delta):
	if path_index < path.size():
		var move_vec = (path[path_index] - global_transform.origin)
		
		# If close to the target waypoint, proceed to the next
		if move_vec.length() < 2:
			path_index += 1
		else:
			# Move towards the target
			velocity = move_vec.normalized() * speed
			move_and_slide()

			# Calculate target rotation based on direction
			var direction = move_vec.normalized()
			var target_rotation_y = atan2(direction.x, direction.z)  # atan2 gives the correct Y-axis rotation

			# Smoothly interpolate current rotation to the target rotation (360-degree wrapping)
			rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 5)  # Use lerp_angle for smooth shortest-path rotation
	else:
		moveb = false


		
	pass
	
func chop():
	pass
	
func idle():
	pass

func set_path(target_pos: Vector3):
	# Calculate path to the target position
	var current_pos = global_transform.origin
	current_pos.y = 1  # Keep pathfinding on the XZ plane
	target_pos.y = 1
	path = amap.find_path(current_pos, target_pos)
	path_index = 0
