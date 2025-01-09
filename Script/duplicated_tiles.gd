extends Node3D

@onready var parent = get_parent()
@onready var other_map = parent.get_node("GridMap")  # Reference to the other GridMap
  # Node where duplicated meshes will be added
@onready var mesh_lib = other_map.mesh_library  # MeshLibrary from the grid map

# Define the script library: associate tile IDs with their corresponding script paths
@export var script_library: Dictionary = {
	0: preload("res://Script/building scripts/Malacadabra.gd"),  # Example script for tile ID 0
	#1: preload("res://scripts/TileScript2.gd"),  # Example script for tile ID 1
	# Add more tile-to-script mappings as needed
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duplicate_tiles_with_functionality()
	pass

func duplicate_tiles_with_functionality():
	var used_cells = other_map.get_used_cells()  # Adjust range to cover your grid map size
	for grid_position in used_cells:
		var tile_id = other_map.get_cell_item(grid_position)
		if tile_id != -1:  # A valid tile exists at this position
			create_functional_tile(tile_id, grid_position)
		

func create_functional_tile(tile_id: int, grid_position: Vector3i):
	# Get the mesh for the tile from the MeshLibrary
	var tile_mesh = mesh_lib.get_item_mesh(tile_id)
	if tile_mesh:
		# Create a new MeshInstance3D and assign the mesh
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = tile_mesh
		
		var mesh_offset = tile_mesh.get_aabb().position + (tile_mesh.get_aabb().size/2)

		# Set the position of the mesh instance
		var world_position = other_map.map_to_local(grid_position) - mesh_offset
		mesh_instance.transform.origin = world_position

		#Dynamically assign a script if available in the script library
		if script_library.has(tile_id):
			var script = script_library[tile_id]
			mesh_instance.set_script(script)
			# Call an optional setup function in the script (if defined)
			if mesh_instance.has_method("initialize"):
				mesh_instance.initialize(world_position, tile_id)

		 ##Optional: Add collision or additional functionality
		#var static_body = StaticBody3D.new()
		#var shapes = mesh_lib.get_item_shapes(tile_id)
		#for shape in shapes:
			#var collision_shape = CollisionShape3D.new()
			#collision_shape.shape = shape
			#static_body.add_child(collision_shape)

		# Add to the duplicate container in the scene tree
		add_child(mesh_instance)

		# Debug: Print the position
		#print("Created functional tile with script at: ", world_position)
