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
@onready var mesh_lib : MeshLibrary = preload("res://assets/mesh/meshes.tres")  # Load the MeshLibrary resource
var buildings = {
	"KampoBtn": 0,
	"KuboBtn": 1
}
var mesh_instance: MeshInstance3D = null
var camera: Camera3D = null  # Camera reference for projection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	grand_parent = parent.get_parent()
	amap = grand_parent.get_node("AMap")
	grid = amap.get_child(0)
	camera = grand_parent.get_node("Camera3D")  # Make sure your camera is named "Camera3D"

	# Connect the "pressed" signal for each TextureButton child
	for child in hbox.get_children():
		if child is TextureButton:
			child.connect("pressed", Callable(self, "_on_btn_pressed").bind(child))  # Use Callable and bind the button
	pass

# Function called when a button is pressed
func _on_btn_pressed(button: TextureButton) -> void:
	# Print the name of the button
	print("Button pressed:", button.name)
	build_button.visible = !build_button.visible
	build_panel.visible = !build_panel.visible
	
	# Create a new mesh instance and set it up
	if mesh_instance:
		mesh_instance.queue_free()  # Remove the previous instance if any
	mesh_instance = MeshInstance3D.new()
	var mesh = mesh_lib.get_item_mesh(buildings[button.name])  # Get mesh from the library
	mesh_instance.mesh = mesh
	
	grid.add_child(mesh_instance)
	following = true  # Start following the mouse
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mesh_instance:
		# Get the mouse position in screen space
		var space_state = get_world_3d().direct_space_state
		var camera = grand_parent.get_node("SubViewportContainer/SubViewport/Camera3D") # Ensure this points to your Camera3D node
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
			
			# Snap to integer positions
			mesh_instance.transform.origin = Vector3(
				floor(hit_position.x),  # Snap X to integer
				floor(hit_position.y),  # Snap Y to integer
				floor(hit_position.z)   # Snap Z to integer
			)
			#print("Ray hit at position (snapped): ", mesh_instance.transform.origin)

			# Only follow if it's valid
			if not following:
				following = true  # Resume following the mouse if hit

		# If no raycast hit (invalid result), stop following
		elif following:
			following = false
			print("No hit, stopped following the mouse")

	# If right mouse button is pressed, stop following the mouse and place the object
	if Input.is_mouse_button_pressed(1) and mesh_instance:  # "ui_select" is typically mapped to the right mouse button
		print("press")
		if following:
			following = false  # Stop following the mouse
			print("Mesh dropped at: ", mesh_instance.transform.origin)
			mesh_instance = null
			attack_button.visible = !attack_button.visible
			build_button.visible = !build_button.visible
			
