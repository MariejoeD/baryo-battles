extends Node3D

@export var detection_area: Area3D  # Exported Area3D to check for bodies
@export var target_group: String  # Target group to find, e.g., "enemies"
var target: CharacterBody3D = null  # Current target

func _ready():
	# Check if the detection_area is valid
	if detection_area:
		# Connect signals for when bodies enter and exit the detection area
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	else:
		print("Detection Area not assigned!")

# Called when a body enters the detection area
func _on_body_entered(body: Node3D) -> void:
	#print(get_parent().name,"Body entered: ", body.name)  # Debug to check if this is triggered
	if body.is_in_group(target_group):  # Check if body belongs to the target group
		_find_nearest_target()

# Called when a body exits the detection area
func _on_body_exited(body: Node3D) -> void:
	print("Body exited: ", body.name)  # Debug to check if this is triggered
	if body == target:
		print("Target lost: ", target.name)
		target = null  # Reset target when it's lost
		_find_nearest_target()  # Find a new target immediately when the current target is lost

# Method to find the nearest target within the area
func _find_nearest_target() -> void:
	var nearest_target: CharacterBody3D = null
	var nearest_distance: float = INF  # Initialize to a very large number

	# Get overlapping bodies in the detection area
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group(target_group):  # Filter only valid target group members
			# Cast the body to CharacterBody3D, assuming it's a CharacterBody3D
			if body is CharacterBody3D:
				var distance = get_global_transform().origin.distance_to(body.get_global_transform().origin)
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_target = body

	# Update the target if a new nearest target is found
	if nearest_target != target:  # Only update if the new target is different
		print("New target acquired: ", nearest_target.name)
		target = nearest_target
		# If you want to trigger a state transition or update NPC's state, do it here:
		# e.g., fsm._transition_to_next_state("Chase", {"target": target})
	#else:
		#print("No new target detected.")
