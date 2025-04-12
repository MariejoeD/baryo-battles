extends Node3D

@export var detection_area: Area3D  # Exported Area3D to check for bodies and areas
@export var target_group: Array[String] = []  # Target groups to find, e.g., "enemies", "buildings"

var target: Node3D = null  # Current target
var forced_target: Node3D = null
@onready var healer: bool = get_parent().find_child("Stats").is_healer
@onready var targeting_enabled: bool = true

func _ready():
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
		detection_area.area_entered.connect(_on_area_entered)
		detection_area.area_exited.connect(_on_area_exited)
	else:
		print("Detection Area not assigned!")

func _on_body_entered(body: Node3D) -> void:
	for group in target_group:
		if body.is_in_group(group):
			_find_nearest_target()
			break

func _on_body_exited(body: Node3D) -> void:
	if body == target:
		target = null
		_find_nearest_target()

func _on_area_entered(area: Area3D) -> void:
	for group in target_group:
		print(group)
		if area.get_parent().is_in_group(group):
			print("Test")
			_find_nearest_target()
			break

func _on_area_exited(area: Area3D) -> void:
	if area == target:
		target = null
		_find_nearest_target()

func _find_nearest_target() -> void:
	if not targeting_enabled:
		return

	if forced_target and is_instance_valid(forced_target):
		target = forced_target
		return

	var nearest_target: Node3D = null
	var nearest_distance: float = INF
	var self_pos = get_global_transform().origin

	# Check all bodies
	for body in detection_area.get_overlapping_bodies():
		if body == get_parent():
			continue
		var is_valid_target = false
		for group in target_group:
			if body.is_in_group(group):
				is_valid_target = true
				break
		if not is_valid_target:
			continue

		var distance = self_pos.distance_to(body.get_global_transform().origin)

		if healer and body is CharacterBody3D:
			var target_stats = body.get_node("Stats")
			if target_stats.current_hp < target_stats.get_scaled_hp() and distance < nearest_distance:
				nearest_distance = distance
				nearest_target = body
		elif body is CharacterBody3D:
			if body.is_in_group("flying") and get_parent().is_in_group("range"):
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_target = body
			elif not body.is_in_group("flying") and distance < nearest_distance:
				nearest_distance = distance
				nearest_target = body
	
	var highest_priority_score := -INF  # Track the highest dynamic priority score
	# Check all areas (e.g., buildings)
	for area in detection_area.get_overlapping_areas():
		if area == get_parent():
			continue
		var parent_node := area.get_parent()
		var is_valid_target = false
		for group in target_group:
			if parent_node.is_in_group(group):
				is_valid_target = true
				break
		if not is_valid_target:
			continue

		var distance = self_pos.distance_to(area.get_global_transform().origin)
		# Check if it has a calculate_priority_score method
		if parent_node.has_method("calculate_priority_score"):
			var priority_score = parent_node.calculate_priority_score()

			# Example logic: prefer closer targets but break ties with higher priority
			var combined_score = priority_score - distance * 0.1  # Adjust distance penalty weight as needed

			if combined_score > highest_priority_score:
				highest_priority_score = combined_score
				nearest_target = parent_node
		else:
			# Fallback if the building doesn't support priority logic
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_target = parent_node

	# Assign new target if changed
	if nearest_target != target:
		target = nearest_target
