extends NpcState

var target : Node3D = null
var path = []
var current_target_index = 0
var recheck_timer: float = 0.0
var recheck_down: float = 0.75
var path_recalculation_cooldown: float = 0.5  # Time in seconds before recalculating the path (adjust as needed)
var path_recalculation_timer: float = 0.0  # Timer to track the cooldown
var prev_direction: Vector3 = Vector3.ZERO
var end
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes
@onready var stats = fsm.get_parent().get_node("Stats")
@onready var speed = stats.get_scaled_movement_speed()
var start

# Get the NPC's size (assuming it uses a CollisionShape3D)
@onready var shape_rad = fsm.get_parent().get_node("CollisionShape3D").shape.radius  # Get diameter
@onready var collision_scale = fsm.get_parent().get_node("CollisionShape3D").global_transform.basis.get_scale()
@onready var npc_size = shape_rad * collision_scale.x
# Adjust the distance threshold dynamically based on NPC size
var target_update_timer = 0.0
var target_update_interval = .5
var building_check_timer := 0.0
var building_check_interval := 0.25

var last_target_position: Vector3 = Vector3.ZERO  # Track the last target position for recalculation

# New variable to detect collision with building area
@onready var building_area: Area3D = null  # This will be set to the building's Area3D for collision detection

func enter(_previous_state_path: String, data := {}) -> void:
	# Initialize pathfinding and set up the target
	var two_models = fsm.two_models
	if two_models:
			fsm.npc_root_node.get_child(2).visible = false
			fsm.npc_root_node.get_child(1).visible = true
		
	fsm.anim_player.play("run")
	recheck_timer =recheck_down
	path_recalculation_timer = path_recalculation_cooldown
	
	target = data.get("target", null)
	start = fsm.npc_root_node.global_transform.origin
	if not is_instance_valid(target):
		print("[DEBUG] Transitioning to Idle: Target is invalid during enter()")
		fsm._transition_to_next_state("Idle")
		return
	
	end = target.global_transform.origin
	# Calculate the initial path
	path = fsm.pathfinder_component.findpaths(start, end)
	print("Path: ", path)
	if not path:
		print("[DEBUG] Transitioning to Idle: No path found during enter()")
		#print("Start:",start)
		#print("Closest_pos: ",fsm.pathfinder_component.find_closest(start))
		fsm._transition_to_next_state("Idle")
		return
	
	#print("Initial path: ", path)
	current_target_index = 0  # Start from the first point in the path
	last_target_position = target.global_transform.origin  # Track initial target position

	# Set the building_area to the target building's Area3D (if available)
	if target.is_in_group("Buildings"):
		#print("Buildings")
		building_area = target.get_node("Area3D")  # Assuming the building has an Area3D node


func update(delta: float) -> void:
	#print("Path: ", path)
	
	path_recalculation_timer -= delta
	building_check_timer -= delta
	recheck_timer -= delta
	if fsm.npc_root_node.global_transform.origin.distance_to(prev_direction) <= 2 or recheck_timer <= 0.0:
		var new_target = fsm.targeting_component._find_nearest_target()

		# Check if there's a valid new target
		if new_target == null or !is_instance_valid(new_target):
			# If current target is also invalid, go idle
			if target == null or !is_instance_valid(target):
				print("[DEBUG] Transitioning to Idle: No new or current target found during recheck")
				fsm._transition_to_next_state("Idle")
				return
		else:
			var npc_pos = fsm.npc_root_node.global_transform.origin
			var new_distance = npc_pos.distance_to(new_target.global_transform.origin)
			
			# If current target is valid, compare distances
			if target != null and is_instance_valid(target):
				var current_distance = npc_pos.distance_to(target.global_transform.origin)
				if new_distance < current_distance:
					target = new_target  # Only switch if the new target is closer
					print("[DEBUG] Switched to closer target")
				else:
					print("[DEBUG] Kept current target - closer or equal")
			else:
				target = new_target  # No valid current target, accept new one

		end = target.global_transform.origin
		path = fsm.pathfinder_component.findpaths(fsm.npc_root_node.global_transform.origin, end)
		if not path:
			print("[DEBUG] Transitioning to Idle: No path to target after recheck")
			fsm._transition_to_next_state("Idle")
			return

		current_target_index = 0
		recheck_timer = recheck_down


	# Reduce the cooldown timer
	if not is_instance_valid(target):
		#print("Lost target.")
		var new_target = fsm.targeting_component._find_nearest_target()
		if new_target == null or !is_instance_valid(new_target):
			print("[DEBUG] Transitioning to Idle: Lost target during update")
			fsm._transition_to_next_state("Idle")
			return
		else:
			target = new_target
			end = target.global_transform.origin
			path = fsm.pathfinder_component.findpaths(fsm.npc_root_node.global_transform.origin, end)
			if not path:
				print("[DEBUG] Transitioning to Idle: Target moved but new path not found")
				fsm._transition_to_next_state("Idle")
				return
			current_target_index = 0

	
	# Step 1: Check if the target has moved significantly to recalculate the path
	var target_position = target.global_transform.origin
	if path_recalculation_timer <= 0.0 and target_position.distance_to(last_target_position) >= 3:
		# Recalculate the path if the target moved significantly
		#print("Target moved significantly, recalculating path...")
		start = fsm.npc_root_node.global_transform.origin
		end = target.global_transform.origin
		path = fsm.pathfinder_component.findpaths(start, end)
		if not path:
			#print("No path found after target moved. Transitioning to Idle.")
			fsm.targeting_component._find_nearest_target()  # Change to idle or another state if the target is lost

			return
		current_target_index = 0
		path_recalculation_timer = path_recalculation_cooldown  # Reset the cooldown timer
		last_target_position = target_position  # Update the last target position after recalculation
	

	# Step 2: Check for collision with the building's area
	if building_check_timer <= 0:
		building_check_timer = building_check_interval
		if building_area != null and building_area.get_overlapping_bodies().size() > 0:
			#print("NPC is colliding with building. Stopping movement.")
			fsm._transition_to_next_state("Attack", {"target" : target})
			return

	
	# Step 3: Check if we are in attack range
	var npc_position = fsm.npc_root_node.global_transform.origin
	var target_stats = target.find_child("Stats")
	if npc_position.distance_to(target_position) <= npc_size + stats.get_scaled_attack_ranged():  # Check if within attack range
		#print(target_stats.Name," within attack range! Stopping ", stats.Name," and transitioning to Attack state.")
		fsm._transition_to_next_state("Attack", {"target" : target})  # Transition to attack state once in range
		return
	
	# Step 4: Continue moving along the path if not in attack range
	if path and current_target_index < len(path):
		var path_target_position = path[current_target_index]  # Get the next target point
		path_target_position.y = 0  # Ensure the target stays on the ground level
		
		# Move smoothly towards the target position
		var direction = (path_target_position - npc_position).normalized()  # Get the direction towards the target
		# Rotate the NPC to face the direction it's walking
		if direction.length() > 0.1 and not direction.is_equal_approx(prev_direction):
			var npc_pos = fsm.npc_root_node.global_transform.origin
			var target_pos = npc_position + direction
			# Make the NPC look at the target position while preserving its scale
			var look_rotation = fsm.npc_root_node
			var target_rotation_y = atan2(direction.x, direction.z)
			fsm.npc_root_node.rotation.y = lerp_angle(fsm.npc_root_node.rotation.y, target_rotation_y, delta * 5)

		# Smooth movement towards the target point
		var move_distance = speed * delta
		fsm.npc_root_node.global_transform.origin = npc_position.move_toward(path_target_position, move_distance)


		# Step 5: Check if we've reached the current target point
		if npc_position.distance_to(path_target_position) <= npc_size *.5:
			current_target_index += 1  # Move to the next target in the path
	
	# Check for a new target every update while following the path
	#fsm.targeting_component._find_nearest_target()  # This ensures the Tirador will always be aware of the closest target
