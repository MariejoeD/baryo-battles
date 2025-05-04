extends Node3D

@export var detection_perimeter: Area3D 
@export var target_group: Array[String] = []

var target: Node3D = null
var forced_target: Node3D = null
@onready var healer: bool = get_parent().find_child("Stats").is_healer
@onready var targeting_enabled: bool = true

func _ready() -> void:
	if detection_perimeter == null:
		detection_perimeter = $"../Detection"
	# Turn off all collision layers (0–19)
	for i in 32:
		detection_perimeter.set_collision_layer_value(i, false)
		detection_perimeter.set_collision_mask_value(i, false)

	# Just in case — turn off physics monitoring
	detection_perimeter.monitoring = false
	detection_perimeter.monitorable = false


func _process(_delta):
	_find_nearest_target()

func _find_nearest_target():
	if not targeting_enabled:
		return

	if forced_target and is_instance_valid(forced_target):
		target = forced_target
		return

	var self_pos = global_transform.origin
	# Get the radius/extent of the Area's collision shape
	var shape = detection_perimeter.get_node("CollisionShape3D").shape
	var extents: Vector3
	if shape is SphereShape3D:
		extents = Vector3.ONE * shape.radius
	elif shape is BoxShape3D:
		extents = shape.size / 2.0
	elif shape is CylinderShape3D:
		extents = Vector3(shape.radius, shape.height / 2.0, shape.radius)
	else:
		return # Unsupported shape

	var detection_aabb = AABB(self_pos - extents, extents * 2)

	var nearest_target: Node3D = null
	var nearest_distance: float = INF
	var highest_priority_score := -INF

	for group in target_group:
		for node in get_tree().get_nodes_in_group(group):
			if node == get_parent() or not is_instance_valid(node):
				continue

			var node_pos: Vector3 = node.global_transform.origin

			if not detection_aabb.has_point(node_pos):
				continue

			var distance = self_pos.distance_to(node_pos)

			if healer and node is CharacterBody3D:
				var stats = node.get_node("Stats")
				if stats.current_hp < stats.get_scaled_hp() and distance < nearest_distance:
					nearest_target = node
					nearest_distance = distance
				continue

			if node is CharacterBody3D:
				if node.is_in_group("flying") and get_parent().is_in_group("range"):
					if distance < nearest_distance:
						nearest_target = node
						nearest_distance = distance
				elif not node.is_in_group("flying") and distance < nearest_distance:
					nearest_target = node
					nearest_distance = distance
				continue

			if node.has_method("calculate_priority_score"):
				var priority = node.calculate_priority_score()
				var combined_score = priority - distance * 0.1
				if combined_score > highest_priority_score:
					highest_priority_score = combined_score
					nearest_target = node
			elif distance < nearest_distance:
				nearest_target = node
				nearest_distance = distance

	if nearest_target != target:
		target = nearest_target
