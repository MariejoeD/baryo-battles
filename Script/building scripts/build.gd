extends Node3D

@onready var placeable = false
var building_mode = false
var current_building: Node3D = null
@export var instant_build: bool = false
@export var building_data: building_resource
@onready var grid_map = get_node("/root/Root/Base/AMap/GridMap")  # Reference to your GridMap node
@export var fixed_y: float = 1.0  # The Y position where the building will stay
var stone_req
var wood_req
func _ready() -> void:
	for btn in get_node("../BuildInventoryPanel/HScrollContainer/HBoxContainer").get_children():
		if btn is TextureButton:
			btn.pressed.connect(_on_btn_pressed.bind(btn))

func _on_btn_pressed(btn: TextureButton) -> void:
	stone_req = int(btn.get_node("resourceAmount/stoneAmount").text)
	wood_req = int(btn.get_node("resourceAmount/woodAmount").text)
	
	if not get_parent().button_states[btn.name]:
		print("Building Not Yet Unlock")
		return
	
	if Global.wood_qty < wood_req or Global.stone_qty < stone_req:
		print("Not Enough Resource")
		return
	
	var scene = building_data.buildings[btn.name]
	current_building = scene.instantiate()
	
	grid_map.add_child(current_building)
	$"../BuildInventoryPanel".hide()
	$"../BuildButton".hide()
	
	building_mode = true

func _process(delta: float) -> void:
	if building_mode and current_building:
		follow_mouse()
		if is_fully_on_floor(current_building) and not is_colliding_with_other_objects(current_building):
			apply_material_override(current_building,Color(0, 1, 0, 0.5))  # Greenish transparent
		else:
			apply_material_override(current_building,Color(1, 0, 0, 0.5))  # Red transparent

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if building_mode:
			if is_fully_on_floor(current_building) and not is_colliding_with_other_objects(current_building):
				building_mode = false
				$"../BuildButton".show()
				$"../AttackButton".show()
				Global.wood_qty -= wood_req
				Global.stone_qty -= stone_req
				if instant_build:
					remove_material_override(current_building)
					if "built" in current_building:
						current_building.built = true
				else:
					apply_material_override(current_building)
					if current_building.has_method("build"):
						current_building.build()
				if current_building.has_method("change_states"):
					get_parent().button_states = current_building.change_states(get_parent().button_states)
		pass

func follow_mouse():
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	if not camera:
		return
	
	var mouse_pos = viewport.get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	# Plane at a fixed Y position
	var t = (fixed_y - ray_origin.y) / ray_dir.y
	var target_position = ray_origin + ray_dir * t

	# Snap to the GridMap
	var grid_cell_size = grid_map.cell_size  # Assumes GridMap uses uniform cells
	var snapped_x = snappedf(target_position.x, grid_cell_size.x)
	var snapped_z = snappedf(target_position.z, grid_cell_size.z)

	# Apply snapped position (keeping fixed Y)
	current_building.global_transform.origin = Vector3(snapped_x, fixed_y, snapped_z)

func is_fully_on_floor(building) -> bool:
	var space_state = get_world_3d().direct_space_state
	var building_transform = building.global_transform
	var size = building.mesh.get_aabb().size  # Get the mesh size
	
	# Define corner offsets
	var offsets = [
		Vector3(-size.x / 2, 0, -size.z / 2),  # Front-left
		Vector3(size.x / 2, 0, -size.z / 2),   # Front-right
		Vector3(-size.x / 2, 0, size.z / 2),   # Back-left
		Vector3(size.x / 2, 0, size.z / 2)     # Back-right
	]

	# Cast a ray downwards from each corner
	for offset in offsets:
		var check_position = building_transform.origin + offset + Vector3(0, 1, 0)
		var ray_end = check_position - Vector3(0, 5, 0)

		var query = PhysicsRayQueryParameters3D.create(check_position, ray_end)
		query.collide_with_bodies = true
		var result = space_state.intersect_ray(query)

		# If any corner does not detect the floor, return false
		if not result:
			
			return false
	
	# If all corners are on the floor, return true
	return true

func is_colliding_with_other_objects(building) -> bool:
	# Get the Area3D node inside the building
	var area_3d = building.get_node_or_null("Area3D")
	if not area_3d:
		return false  # No collision if there's no Area3D

	# Check for overlapping bodies (other objects with a collision body)
	for body in area_3d.get_overlapping_bodies():
		if not body.is_in_group("floor"):  # Ignore GridMaps (add them to a group)
			return true  # Collision detected

	# Check for overlapping areas (trees, stones, other buildings)
	for area in area_3d.get_overlapping_areas():
		if not area.is_in_group("floor"):  # Ignore GridMaps
			return true  # Collision detected

	return false  # No collision


func apply_material_override(mesh_instance, color = Color(0.5, 0.5, 1.0, 0.5)) -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = color  # Light blue with 50% transparency
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_unshaded = true  # Optional: makes it unaffected by lighting
	
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, material)

func remove_material_override(mesh_instance) -> void:
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, null)
