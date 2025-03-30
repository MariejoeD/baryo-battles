extends Node3D

@export var enemies: Array[PackedScene]
@export var troops: Dictionary
@onready var UI = $"../UI"
@onready var camera = $"../SubViewportContainer/SubViewport/Camera3D"  # Ensure you reference your main Camera3D
var in_area = false

func _input(event: InputEvent) -> void:
	if UI.selected_troop:
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
	# Create a temporary instance to get the collision shape
	var Troop_Scene = troops.get(UI.selected_troop, null)
	if not Troop_Scene:
		print("[ERROR] Null troop scene!")
		return

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

	# Position is valid, spawn troop
	temp_instance.position = target_position
	add_child(temp_instance)
	print("[SUCCESS] Troop deployed at:", target_position)

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
	
