extends Node3D
@onready var floor_map = $"../GridMap"
var aS = null
var all_points = {}
signal  finished


func create_astar():
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
	
	# Now connect the points by adding neighbors
	for cell in cells:
		if cell.y == 0: continue
		var cell_pos = Vector3i(cell.x, 1, cell.z)
		var mesh_id = floor_map.get_cell_item(cell_pos)
		if mesh_id == 1:  # Only process walkable cells
			var index = all_points[v3_to_index(cell_pos)]
			
			# Check for neighboring cells and add edges between them
			var neighbors = [
				Vector3i(cell.x + 1, 1, cell.z),  # Right
				Vector3i(cell.x - 1, 1, cell.z),  # Left
				Vector3i(cell.x, 1, cell.z + 1),  # Down
				Vector3i(cell.x, 1, cell.z - 1),  # Up
			]

			# Loop through neighbors and add valid ones
			for neighbor in neighbors:
				if all_points.has(v3_to_index(neighbor)):
					var neighbor_index = all_points[v3_to_index(neighbor)]
					aS.connect_points(index, neighbor_index)  # Connect the points

	print("AStar3D created and cells added with connections.")
	emit_signal("finished")

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
