extends NpcState

var target : Node3D = null
var path = []
var current_target_index = 0
var speed = 5.0  # Movement speed
var end
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes

func enter(previous_state_path: String, data := {}) -> void:
	target = data.get("target", null)
	end = data.get("target", null).global_transform.origin
	path = fsm.pathfinder_component.findpaths(fsm.npc_root_node.global_transform.origin, end)  # Adjusted the method name to match the pathfinding function
	
	if path == null:
		print("No path found")
		return

	current_target_index = 0  # Start from the first point in the path
	print("Path calculated:", path, "\nstarting movement")

func update(delta: float) -> void:
	if not target:
		print("lost target")
		fsm._transition_to_next_state("Idle")  # Change to idle or another state if the target is lost
		return
	
	var char_body = fsm.npc_root_node as CharacterBody3D
	if current_target_index < path.size():
		fsm.anim_player.play("run")
		var move_vec = (path[current_target_index] - char_body.global_transform.origin)
		
		# If close to the target waypoint, proceed to the next
		if move_vec.length() <= 1.65:
			print(move_vec.length())
			current_target_index += 1
		else:
			# Move towards the target
			char_body.velocity = move_vec.normalized() * speed 
			char_body.move_and_slide()
			char_body.global_transform.origin.y = 0
			# Calculate target rotation based on direction
			var direction = move_vec.normalized()
			var target_rotation_y = atan2(direction.x, direction.z)  # atan2 gives the correct Y-axis rotation

			# Smoothly interpolate current rotation to the target rotation (360-degree wrapping)
			char_body.rotation.y = lerp_angle(char_body.rotation.y, target_rotation_y, delta * 5)  # Use lerp_angle for smooth shortest-path rotation
	else:
		print("Reached the end of the path.")
		fsm._transition_to_next_state("Attack",{"target":target})  # Change to idle or another state when the path is completed
