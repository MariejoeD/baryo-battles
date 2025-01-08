@tool
extends Area3D

@export var collision_radius: float = 1.0:
	set(value):
		collision_radius = value
		update_collision_radius()

@export var collision_height: float = 2.0:
	set(value):
		collision_height = value
		update_collision_radius()

@onready var collision_shape: CollisionShape3D = null

# Called when the script is loaded or when entering the scene tree
func _ready() -> void:
	# Ensure collision_shape is properly initialized in editor
	if collision_shape == null and Engine.is_editor_hint():
		print("CollisionShape3D not found in the scene. Attempting to locate it.")
		collision_shape = get_node_or_null("CollisionShape3D")

	# If collision shape is still not found, create it manually
	if collision_shape == null and Engine.is_editor_hint():
		print("Creating CollisionShape3D node.")
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		add_child(collision_shape)

	# Proceed with updating the radius if the shape is valid
	update_collision_radius()

# Update collision radius and height
func update_collision_radius():
	if collision_shape:
		if collision_shape.shape == null:
			print("No shape found. Assigning a new CylinderShape3D.")
			collision_shape.shape = CylinderShape3D.new()

		if collision_shape.shape is CylinderShape3D:
			var shape = collision_shape.shape as CylinderShape3D
			shape.radius = collision_radius
			shape.height = collision_height
			print("Collision shape updated: radius = ", collision_radius, ", height = ", collision_height)

			# Force the editor to update the gizmo for the visual representation
			if Engine.is_editor_hint():
				collision_shape._update_gizmo()  # Forces the editor to refresh the shape
		else:
			print("CollisionShape3D shape is not a CylinderShape3D. Current shape: ", collision_shape.shape)
	else:
		print("CollisionShape3D node still not found!")
