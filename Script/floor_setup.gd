extends Node3D

@onready var parent = get_parent()
@onready var floor_map = parent.get_node("Floor")
@onready var other_map = parent.get_node("GridMap")
@export var grid_size: int = 100
var grid_range = floor(grid_size/2)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_map()
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
	check_for_tile_collision()
	pass
	
# Function to check if a collision exists at a given position
func check_for_tile_collision():
	var range = floor(grid_size/2)
	for x in range(-range, range+1):
		for z in range(-range, range+1):
			# Check if a tile exists in the other map at this position
			var other_tile_id = other_map.get_cell_item(Vector3i(x, 0, z))
			if other_tile_id != -1:  # Tile exists
				var other_tile_size = get_tile_size(other_tile_id)
				# Check if a floor tile with ID 1 exists in the same position
				var drangex = ceil(other_tile_size.x/2)
				var drangez = ceil(other_tile_size.z/2)
				for dx in range(-drangex, drangex):
					for dz in range(-drangez, drangez):
						var check_pos = Vector3i(x + dx, 1, z + dz)
						var floor_tile_id = floor_map.get_cell_item(check_pos)
						if floor_tile_id == 1:  # Tile with ID 1 found
							#print("Collision detected at position: ", check_pos)
							# Remove the floor tile
							floor_map.set_cell_item(check_pos, -1)


func get_tile_size(tile_id):
	var mesh = other_map.mesh_library.get_item_mesh(tile_id)
	if mesh:
		var size = mesh.get_aabb().size
		return Vector3i(floor(size.x), floor(size.y), floor(size.z))  # Use integer sizes for grid alignment
	return Vector3i(1, 1, 1)  # Default size if the size can't be determined
	pass
