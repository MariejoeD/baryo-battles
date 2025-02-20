extends Node3D


@export var hbox: HBoxContainer
@export var build_button: Button
@export var attack_button: Button
@export var build_panel: Panel
var amap
var grid
var parent
var grand_parent
var following
var dup_tiles
@onready var mesh_lib : MeshLibrary = preload("res://assets/mesh/meshes.tres")  # Load the MeshLibrary resource
@export var building_dict: building_resource
var buildings = {}
var button
var mesh_instance: MeshInstance3D = null
var camera: Camera3D = null  # Camera reference for projection
var in_building_mode = false
var stone_req
var wood_req
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	grand_parent = parent.get_parent()
	amap = grand_parent.get_node("AMap")
	dup_tiles = amap.get_node("DuplicatedTiles")
	grid = amap.get_child(0)
	camera = grand_parent.get_node("Camera3D")  # Make sure your camera is named "Camera3D"
	
	# Connect the "pressed" signal for each TextureButton child
	for i in hbox.get_children().size():
		var child = hbox.get_child(i)
		buildings[child.name] = i
		if child is TextureButton:
			child.connect("pressed", Callable(self, "_on_btn_pressed").bind(child))  # Use Callable and bind the button
	pass

# Function called when a button is pressed
func _on_btn_pressed(btn: TextureButton) -> void:
	# Print the name of the button
	button = btn
	
	stone_req =button.get_node("resourceAmount/stoneAmount").text
	wood_req =button.get_node("resourceAmount/woodAmount").text
	
	if int(stone_req) > Global.stone_qty or int(wood_req) > Global.wood_qty:
		print("not enough resource")
		return
	
	
	#print("Button pressed:", button.name)
	
	if !parent.button_states[button.name]:
		return
	if button.name == "MalacadabraBtn":
		print("TRUE")
		for key in parent.button_states.keys():
			parent.button_states[key] = !parent.button_states[key]
			print(parent.button_states[key])
	build_button.visible = !build_button.visible
	build_panel.visible = !build_panel.visible
	# Create a new mesh instance and set it up
	if mesh_instance:
		mesh_instance.queue_free()  # Remove the previous instance if any
	mesh_instance = MeshInstance3D.new()
	var inst = building_dict.building_assets[buildings[button.name]].instantiate()  # Get mesh from the library
	var mesh = inst.mesh
	inst = null
	mesh_instance.mesh = mesh
	
	grid.add_child(mesh_instance)
	#add_collision_to_mesh(mesh_instance)
	following = true  # Start following the mouse
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	follow_mouse()
	pass

# Function to add collision to the mesh instance
#func add_collision_to_mesh(mesh_instance: MeshInstance3D) -> void:
	## Create a StaticBody node to hold the collision shape
	#var static_body = StaticBody3D.new()
	#var collision_shape = CollisionShape3D.new()
	#
	## Here we assume a BoxShape for simplicity
	#var box_shape = BoxShape3D.new()
	#box_shape.extents = mesh_instance.mesh.get_aabb().size / 2  # Use the mesh's size as the extents for the box
	#print(mesh_instance.mesh.get_aabb().size)
	#collision_shape.shape = box_shape
	#static_body.add_child(collision_shape)
	##print("added collision")
	## Position the static body at the same position as the mesh instance
	#static_body.transform.origin = mesh_instance.transform.origin
	#
	## Add the StaticBody as a child to the current scene
	#add_child(static_body)
	##print("added static body")
	
func follow_mouse():
	if mesh_instance:
		in_building_mode = true
		# Get the mouse position in screen space
		var space_state = get_world_3d().direct_space_state
		camera = grand_parent.get_node("SubViewportContainer/SubViewport/Camera3D") # Ensure this points to your Camera3D node
		var mouse_position = get_viewport().get_mouse_position()  # Get the mouse position in screen coordinates

		# Create a ray from the camera to the mouse position
		var from = camera.project_ray_origin(mouse_position)
		var to = from + camera.project_ray_normal(mouse_position) * 1000  # Adjust the length as needed
		#print("Ray from: ", from, " to: ", to)  # Debug ray direction

		var query = PhysicsRayQueryParameters3D.create(from, to)

		# Perform a raycast to find where to spawn the NPC
		var result = space_state.intersect_ray(query)
		
		if result and result.has("position"):
			# Raycast hit something valid, update the mesh position and resume following
			var hit_position = result["position"]
			
			# Snap the hit position to the grid
			var cell = grid.local_to_map(hit_position)
			var snapped_position = grid.map_to_local(cell)
			snapped_position.y = 0.6
			# Snap to integer positions
			mesh_instance.transform.origin = snapped_position
			#print("Ray hit at position (snapped): ", mesh_instance.transform.origin)

			# Only follow if it's valid
			if not following:
				following = true  # Resume following the mouse if hit

		# If no raycast hit (invalid result), stop following
		elif following:
			following = false
			#print("No hit, stopped following the mouse")

	# If right mouse button is pressed, stop following the mouse and place the object
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mesh_instance:
		if following:
			following = false
			in_building_mode = false

			# Snap final position to the grid and check for placement validity
			var cell = grid.local_to_map(mesh_instance.transform.origin)  # Use local position for snapping
			var snapped_position = grid.map_to_local(cell)
			snapped_position.y = 0  # Align with the ground level
			
			if not is_area_free(snapped_position, mesh_instance):
				print("Cannot place tile; overlaps with existing tile.")
				return

			mesh_instance.transform.origin = snapped_position  # Set the position locally
			grid.set_cell_item(cell, buildings[button.name])  # Place the tile

			dup_tiles.duplicate_tiles_with_functionality()
			mesh_instance.queue_free()
			mesh_instance = null
			attack_button.visible = !attack_button.visible
			build_button.visible = !build_button.visible
			Global.stone_qty -= int(stone_req)
			Global.wood_qty -= int(wood_req)
			

	pass
	
func is_area_free(start_pos: Vector3i, new_tile_instance: MeshInstance3D):
	# Get the new tile's bounding box in world space
	var new_tile_aabb = get_tile_bounding_box(start_pos, new_tile_instance)
	print(new_tile_instance)
	# Iterate over all the existing tiles and check for overlap
	for existing_tile_pos in grid.get_used_cells():
		var existing_tile_item = grid.get_cell_item(existing_tile_pos)
		if existing_tile_item == -1:
			continue  # Skip empty cells
		# Get the existing tile's mesh and bounding box
		var existing_tile_instance = mesh_lib.get_item_mesh(existing_tile_item)  # Assuming StaticBody3D child
		if existing_tile_instance:
			var existing_tile_aabb = get_tile_bounding_box_for_existing_tile(existing_tile_pos, existing_tile_instance)
			# Check for overlap between the two bounding boxes
			if new_tile_aabb.intersects(existing_tile_aabb):
				return false # Found an overlap, so can't place the new tile
				
	for tree_parent in get_tree().get_nodes_in_group("Trees"):
		for child in tree_parent.get_children():
			if child is MeshInstance3D and child.visible == true:
				var tree_mesh = child
				var tree_aabb = get_tile_bounding_box_for_existing_tile(child.global_transform.origin, tree_mesh.mesh)
				if new_tile_aabb.intersects(tree_aabb):
					print("overlaps")
					return false
	return true # No Overlapped
	
	

func get_tile_bounding_box(position: Vector3i, tile_instance: MeshInstance3D) -> AABB:
	# Assuming the mesh has a valid AABB. If not, calculate it using the tile's size.
	var mesh_aabb = tile_instance.mesh.get_aabb()
	
	# Adjust the AABB to the position of the tile in world space
	var world_position = tile_instance.transform.origin
	var tile_size = mesh_aabb.size  # Use the mesh's size to represent the tile's bounding box
	return AABB(world_position - tile_size / 2, tile_size)  # Return AABB in world space
	
	
func get_tile_bounding_box_for_existing_tile(position:Vector3i, tile_instance: Mesh) -> AABB:
	# Get the AABB of the existing tile's mesh
	var mesh_aabb = tile_instance.get_aabb()
	# Adjust the position of the tile in the grid
	var grid_world_position = grid.map_to_local(position)
	return AABB(grid_world_position - mesh_aabb.size / 2, mesh_aabb.size)
	
	
