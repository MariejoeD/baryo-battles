# Building.gd
class_name Building
extends MeshInstance3D

@export var level: int = 1
@export var built: bool = false

@onready var astar = get_tree().get_nodes_in_group("pathscript")[0]
@onready var grid_map = get_tree().get_first_node_in_group("floor")

var blocked_cells: Array[Vector3i] = []

func get_save_data() -> Dictionary:
	return {
		"name": scene_file_path.get_file().get_basename(),
		"position": global_transform.origin,
		"scale": scale,
		"level": level,
		"built": built
	}

func load_from_data(data: Dictionary) -> void:
	global_transform.origin = data.get("position", Vector3.ZERO)
	scale = data.get("scale", Vector3.ONE)
	level = data.get("level", 1)
	built = data.get("built", false)

	if built:
		instant_build()

func instant_build():
	# Whatever your instant build needs to do
	pass

func on_placed():
	remove_floor1_cells_inside_mesh()

func on_destroyed():
	add_floor1_cells_inside_mesh()

func remove_floor1_cells_inside_mesh():
	var cell_size = grid_map.cell_size
	var half_extents = cell_size * 0.5
	var local_aabb = get_aabb()
	var transform = global_transform

	var corners = [
		Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1),
		Vector3(1, 1, 0), Vector3(1, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1)
	]

	var min = transform * (local_aabb.position + corners[0] * local_aabb.size)
	var max = min

	for corner in corners:
		var world_pos = transform * (local_aabb.position + corner * local_aabb.size)
		min = min.min(world_pos)
		max = max.max(world_pos)

	var world_aabb = AABB(min, max - min) # No need to grow here usually

	var start = grid_map.local_to_map(world_aabb.position)
	var end = grid_map.local_to_map(world_aabb.position + world_aabb.size)

	blocked_cells.clear() # Clear previously saved cells

	var y = 1 # Floor height

	for x in range(start.x, end.x + 1):
		for z in range(start.z, end.z + 1):
			var cell = Vector3i(x, y, z)
			var cell_world_pos = grid_map.map_to_local(cell) + half_extents
			if world_aabb.has_point(cell_world_pos):
				astar.remove_path(cell)
				blocked_cells.append(cell) # Save it for restoration later!

func add_floor1_cells_inside_mesh():
	for cell in blocked_cells:
		astar.add_path(cell)
