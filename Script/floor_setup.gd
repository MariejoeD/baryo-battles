class_name path_finder extends Node3D

var all_points = {}
var aS = null



@onready var parent = get_parent()
@onready var floor_map = parent.get_node("Floor")
@onready var other_map = parent.get_node("GridMap")
@export var grid_size: int = 100
var grid_range = floor(grid_size/2)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_map()
	create_AStar_map()
	check_for_tile_collision()
	pass # Replace with function body.

func fill_map():
	
	for x in range(-grid_range,grid_range+1,):
		for z in range(-grid_range,grid_range+1,):
			floor_map.set_cell_item(Vector3i(x, 0, z), 0) #Set Floor on position
			floor_map.set_cell_item(Vector3(x, 1, z), 1)
	print(floor_map.get_cell_item(Vector3i(0,0,0)))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#check_for_tile_collision()
	pass
	
# Function to check if a collision exists at a given position
func check_for_tile_collision():
	var used_cells = other_map.get_used_cells()
	for grid_pos in used_cells:
		# Check if a tile exists in the other map at this position
		var other_tile_id = other_map.get_cell_item(grid_pos)
		if other_tile_id != -1:  # Tile exists
			var other_tile_size = get_tile_size(other_tile_id)
			if other_tile_size == Vector3i(1,1,1):
				grid_pos.y = 1
				remove_path(grid_pos)
				continue
			# Check if a floor tile with ID 1 exists in the same position
			var drangex = ceil(other_tile_size.x/2)
			var drangez = ceil(other_tile_size.z/2)
			#print(drangex,":",drangez)
			for dx in range(-drangex, drangex):
				for dz in range(-drangez, drangez):
					var check_pos = Vector3i(grid_pos.x + dx, 1, grid_pos.z + dz)
					remove_path(check_pos)

func remove_path(check_pos):
	var floor_tile_id = floor_map.get_cell_item(check_pos)
	if floor_tile_id == 1:  # Tile with ID 1 found
		#print("Collision detected at position: ", check_pos)
		# Remove the floor tile
		floor_map.set_cell_item(check_pos, -1)
		remove_point(check_pos)
		update_neighbors(check_pos)
func get_tile_size(tile_id):
	var mesh = other_map.mesh_library.get_item_mesh(tile_id)
	if mesh:
		var size = mesh.get_aabb().size
		if size >= Vector3(0.1,0.1,0.1):
			return Vector3i(1, 1, 1) 
		return Vector3i(floor(size.x), floor(size.y), floor(size.z))  # Use integer sizes for grid alignment
	return Vector3i(1, 1, 1)  # Default size if the size can't be determined
	pass

func create_AStar_map():
	aS = AStar3D.new()
	var cells = floor_map.get_used_cells()
	
	# Add walkable cells to AStar3D
	for cell in cells:
		if(cell.y == 0):continue
		var cell_pos = Vector3i(cell.x, 1, cell.z)  # Create a Vector3i
		var mesh_id = floor_map.get_cell_item(cell_pos)  # Use Vector3i to get the cell item
		if mesh_id == 1:  # Only add walkable cells
			var index = aS.get_available_point_id()
			aS.add_point(index, floor_map.map_to_local(cell_pos))
			all_points[v3_to_index(cell_pos)] = index
	
	# Connect neighboring points
	for cell in cells:
		if(cell.y == 0):continue
		for offset in [Vector3i(-1, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(0, 0, 1)]:
				var neighbor_cell = cell + offset
				var neighbor_mesh_id = floor_map.get_cell_item(neighbor_cell)  # Use Vector3i for neighbor
				if neighbor_mesh_id == 1 and v3_to_index(neighbor_cell) in all_points:
					var index1 = all_points.get(v3_to_index(cell), -1)  # Add a default value if not found
					var index2 = all_points.get(v3_to_index(neighbor_cell), -1)  # Same for neighbor
					if index1 != -1 and index2 != -1 and !aS.are_points_connected(index1, index2):
						aS.connect_points(index1, index2, true)
	
	
func v3_to_index(v3: Vector3i) -> String:
	# Convert Vector3i to a string key with x,y,z values
	return str(v3.x) + "," + str(v3.y) + "," + str(v3.z)

func find_path(start: Vector3, end: Vector3):
	# Convert world positions to grid map indices
	var gm_start = v3_to_index(floor_map.local_to_map(start))
	var gm_end = v3_to_index(floor_map.local_to_map(end))
	var start_id = 0
	var end_id = 0

	# Safely lookup points in the dictionary
	if all_points.has(gm_start):
		start_id = all_points[gm_start]
	else:
		start_id = aS.get_closest_point(start)
	
	if all_points.has(gm_end):
		end_id = all_points[gm_end]
	else:
		end_id = aS.get_closest_point(end)
	#print(all_points)
	# Generate the path from AStar3D
	
	return aS.get_point_path(start_id, end_id)

func remove_point(cell_pos: Vector3i):
	if v3_to_index(cell_pos) in all_points:
		var point_id = all_points[v3_to_index(cell_pos)]
		aS.remove_point(point_id)  # Remove the point from AStar
		all_points.erase(v3_to_index(cell_pos))  # Remove from the dictionary


func update_neighbors(cell_pos: Vector3i):
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			for z in [-1, 0, 1]:
				var offset = Vector3i(x, y, z)
				if offset == Vector3i(0, 0, 0):
					continue
				
				var neighbor_pos = cell_pos + offset
				if v3_to_index(neighbor_pos) in all_points:
					var neighbor_id = all_points[v3_to_index(neighbor_pos)]
					if floor_map.get_cell_item(neighbor_pos) == 1:
						# Reconnect valid neighbors
						var point_id = all_points.get(v3_to_index(cell_pos), -1)
						if point_id != -1 and !aS.are_points_connected(point_id, neighbor_id):
							aS.connect_points(point_id, neighbor_id, true)
					else:
						# Disconnect invalid neighbors
						aS.disconnect_points(all_points[v3_to_index(cell_pos)], neighbor_id)
