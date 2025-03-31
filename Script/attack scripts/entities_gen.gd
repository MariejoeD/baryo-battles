extends Node3D

@export var enemies: Array[PackedScene]
@export var troops: Dictionary
@onready var UI = $"../UI"
@onready var container = UI.get_node("allyPanel/allyContainer")
@onready var camera = $"../SubViewportContainer/SubViewport/Camera3D"  # Ensure you reference your main Camera3D
@export var Objects: Array[Node]
var in_area = false

func _ready() -> void:
	create_area_and_collision()
func _input(event: InputEvent) -> void:
	if get_selected_troop() != "":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var target_pos = get_mouse_floor_position()
			if target_pos == Vector3.ZERO or target_pos == Vector3.INF:
				print("[ERROR] Invalid position detected, skipping troop placement.")
				return
			spawn_troop(target_pos)

func get_mouse_floor_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000  

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		print("[DEBUG] Mouse hit position:", result.position)
		return result.position

	print("[WARNING] Mouse position invalid, returning Vector3.INF")
	return Vector3.INF

func spawn_troop(target_position: Vector3):
	# Find the selected troop
	var selected_troop = get_selected_troop()
	if selected_troop == "":
		print("[ERROR] No troop selected!")
		return

	# Get troop count
	var troop_count = UI.troop_data[selected_troop][0]

	if troop_count <= 0:
		print("[ERROR] No more", selected_troop, "available!")
		return

	# Get troop scene
	var Troop_Scene = troops.get(selected_troop, null)
	if not Troop_Scene:
		print("[ERROR] Null troop scene!")
		return

	# Create a temporary instance to check collision
	var temp_instance = Troop_Scene.instantiate()
	temp_instance.get_node("Detection/CollisionShape3D").shape.radius *= 0.001
	var collision_shape = temp_instance.get_node_or_null("CollisionShape3D")
	if not collision_shape:
		print("[ERROR] No collision shape found in troop!")
		temp_instance.queue_free()
		return

	# Check if position is valid BEFORE spawning
	if not await is_position_valid(target_position, collision_shape):
		print("[ERROR] Cannot place troop here! Position occupied.")
		temp_instance.queue_free()
		return

	# Position is valid, decrease troop count
	UI.troop_data[selected_troop][0] -= 1
	UI.update_troop_count_label(container.get_node(selected_troop), UI.troop_data[selected_troop][0])
	# Spawn troop
	temp_instance.position = target_position
	add_child(temp_instance)
	print("[SUCCESS] Deployed", selected_troop, "at", target_position)
	print("[INFO] Remaining", selected_troop, ":", UI.troop_data[selected_troop][0])

func get_selected_troop() -> String:
	for troop_name in UI.troop_data.keys():
		if UI.troop_data[troop_name][1]:  # If is_selected is true
			return troop_name
	return ""  # No troop selected


func is_position_valid(position: Vector3, collision_shape: CollisionShape3D) -> bool:
	var temp_area = Area3D.new()
	var temp_col = CollisionShape3D.new()
	temp_col.shape = collision_shape.shape  # Copy troop shape
	temp_area.add_child(temp_col)
	temp_area.position = position
	add_child(temp_area)

	# Wait a frame to let physics process
	await get_tree().physics_frame  

	# Check for collisions
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = temp_col.shape
	query.transform.origin = position
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query)
	temp_area.queue_free()

	# Filter out collisions with GridMap and itself
	var valid = true
	for result in results:
		if result.collider is GridMap:
			print("[INFO] Ignoring GridMap collision.")
			continue  # Ignore GridMap
		if result.collider == temp_area:
			print("[INFO] Ignoring temporary Area3D.")
			continue  # Ignore itself
		print("[ERROR] Collision with:", result.collider.name)
		valid = false

	return valid  # Return True if no unwanted collisions
	
func create_area_and_collision():
	for group in Objects:
		for child in group.get_children():
			# Find all MeshInstance3D children
			var mesh_instances: Array[MeshInstance3D] = []
			
			if child is MeshInstance3D:
				mesh_instances.append(child)  # Directly add if it's a MeshInstance3D
			else:
				# Search for MeshInstance3D children inside the node
				for sub_child in child.get_children():
					if sub_child is MeshInstance3D:
						mesh_instances.append(sub_child)

			# Process each MeshInstance3D found
			for mesh_inst in mesh_instances:
				# Ensure the mesh instance has a valid AABB
				var aabb = mesh_inst.get_aabb()
				if aabb.size == Vector3.ZERO:
					print("[WARNING] Skipping", mesh_inst.name, "- AABB is empty.")
					continue

				# Create Area3D and CollisionShape3D
				var area = Area3D.new()
				var collision = CollisionShape3D.new()
				var box = BoxShape3D.new()

				box.extents = aabb.size / 2  # Correct way to set box size
				collision.shape = box

				# Attach the collision shape
				area.add_child(collision)
				collision.owner = mesh_inst.owner  # Set owner for scene compatibility
				area.owner = mesh_inst.owner  # Prevents issues when saving scene

				# Add Area3D to the MeshInstance3D
				mesh_inst.add_child(area)

				print("[INFO] Added Area3D to:", mesh_inst.name)
