extends NpcState

var target : CharacterBody3D = null
var path = []
var current_target_index = 0
var speed = 10.0  # Movement speed
var end
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes
var start
func enter(_previous_state_path: String, data := {}) -> void:
	if not is_instance_valid(data.get("target", null)):
		fsm._transition_to_next_state("Idle")
		return
	target = data.get("target", null)
	start = fsm.npc_root_node.global_transform.origin
	
	if not is_instance_valid(target):
		print("Target invalid when setting end point. Transitioning to Idle.")
		fsm._transition_to_next_state("Idle")
		return
	
	end = data.get("target", null).global_transform.origin
	path = fsm.pathfinder_component.findpaths(start, end)  # Adjusted the method name to match the pathfinding function
	
	if path == null:
		print("No path found")
		fsm._transition_to_next_state("Idle")
		return

	current_target_index = 0  # Start from the first point in the path

func update(delta: float) -> void:
	if not is_instance_valid(target):
		print("lost target")
		fsm._transition_to_next_state("Idle")  # Change to idle or another state if the target is lost
		return
	fsm.targeting_component._find_nearest_target()
	var new_target = fsm.targeting_component.target
		
	if is_instance_valid(new_target) and new_target != target and new_target:  # Only update target if it's a new one
		print("New target found.")
		target = new_target
		# Recalculate path to the new target
		start = fsm.npc_root_node.global_transform.origin
		
		end = target.global_transform.origin
		path = fsm.pathfinder_component.findpaths(start, end)
		if not path:
			print("No path to new target. Transitioning to Idle.")
			fsm._transition_to_next_state("Idle")
			return
		current_target_index = 0
	pass
	
	if fsm.npc_root_node.global_transform.origin.distance_to(target.global_transform.origin) <.6:
		print("Reached the end of the path1.")
		fsm._transition_to_next_state("Attack",{"target":target}) 
		
	#if fsm.npc_root_node.global_transform.origin.distance_to(end) < 1 or target.global_transform.origin.distance_to(end) > 1:
		#start = fsm.npc_root_node.global_transform.origin
		#end = target.global_transform.origin
		#path = fsm.pathfinder_component.findpaths(start, end)
		#current_target_index = 0
		#pass
	
	
	var char_body = fsm.npc_root_node as CharacterBody3D
	if current_target_index < path.size():
		fsm.anim_player.play("run")
		var move_vec = (path[current_target_index] - char_body.global_transform.origin)
		
		# If close to the target waypoint, proceed to the next
		if move_vec.length() <= 1.65:
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
