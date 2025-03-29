extends Node3D

@export var enemies: Array[PackedScene]
@export var troops: Dictionary
@onready var UI = $"../UI"
@onready var camera = $"../SubViewportContainer/SubViewport/Camera3D"  # Ensure you reference your main Camera3D

var obstacles = ["Buildings", "Tree", "stones", "Bush"]

func _input(event: InputEvent) -> void:
	if UI.selected_troop:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var target_pos = get_mouse_floor_position()
			if target_pos != Vector3.ZERO:
				spawn_troop(target_pos)

func get_mouse_floor_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000  # Cast ray into distance

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		print(collider.name)
		# Check if it's a valid GridMap tile and not an obstacle
		if collider is GridMap or collider.name == "GridMap":
			return result.position
		elif collider.name in obstacles:
			return Vector3.ZERO  # Invalid placement
	return Vector3.ZERO  # No valid position found

func spawn_troop(position: Vector3):
	var Troop_Scene = troops.get(UI.selected_troop, null)
	if Troop_Scene:
		var Troop_inst = Troop_Scene.instantiate()
		Troop_inst.position = position
		add_child(Troop_inst)
		print("Troop deployed at:", position)
	else:
		print("Null")
