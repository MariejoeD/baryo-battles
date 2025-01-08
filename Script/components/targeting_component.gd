extends Node3D

@export var detection_area: Area3D  # Exported Area3D to check for bodies
@export var target_group: String  # Target group to find, e.g., "enemies"
var target: Node3D = null  # Current target

func _ready():
	# Check if the detection_area is valid
	if detection_area:
		# Connect signals for when bodies enter and exit the detection area
		detection_area.area_entered.connect(_on_area_entered)
		detection_area.area_exited.connect(_on_area_exited)
	else:
		print("Detection Area not assigned!")

# Called when a body enters the detection area
func _on_area_entered(body: Node3D) -> void:
	body = body.get_parent()
	if body.is_in_group(target_group):  # Check if body belongs to the target group
		_find_nearest_target()

# Called when a body exits the detection area
func _on_area_exited(body: Node3D) -> void:
	body = body.get_parent()
	if body == target:
		print("Target lost: ", target.name)
		target = null  # Reset target when it's lost
		_find_nearest_target()

# Method to find the nearest target within the area
func _find_nearest_target() -> void:
	var nearest_target: Node3D = null
	
	var nearest_distance: float = INF  # Initialize to a very large number
	for area in detection_area.get_overlapping_areas():
		var body = area.get_parent()
		if body.is_in_group(target_group):  # Filter only valid target group members
			var distance = global_position.distance_to(body.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_target = body
	target = nearest_target
	if target:
		print("Target acquired: ", target.name)
	else:
		print("No target detected.")
