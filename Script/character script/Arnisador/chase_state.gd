extends NpcState

var target : CharacterBody3D = null
var path = []
var current_target_index = 0
var path_recalculation_cooldown: float = 1.0  # Time in seconds before recalculating the path (adjust as needed)
var path_recalculation_timer: float = 0.0  # Timer to track the cooldown

var end
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes
@onready var stats = fsm.get_parent().get_node("Stats")
@onready var speed = stats.movement_speed
var start

# Get the NPC's size (assuming it uses a CollisionShape3D)
@onready var npc_size = fsm.get_parent().get_node("CollisionShape3D").shape.radius * 2  # Get diameter

# Adjust the distance threshold dynamically based on NPC size
@onready var distance_threshold = npc_size * .6  # You can tweak this multiplier based on desired behavior

var last_target_position: Vector3 = Vector3.ZERO  # Track the last target position for recalculation

func enter(_previous_state_path: String, data := {}) -> void:
	# Initialize pathfinding and set up the target
	fsm.anim_player.play("run")
	path_recalculation_timer = path_recalculation_cooldown
	if not is_instance_valid(data.get("target", null)):
		fsm._transition_to_next_state("Idle")
		return
	
	target = data.get("target", null)
	start = fsm.npc_root_node.global_transform.origin
	if not is_instance_valid(target):
		print("Target invalid when setting end point. Transitioning to Idle.")
		fsm._transition_to_next_state("Idle")
		return
	
	end = target.global_transform.origin
	# Calculate the initial path
	path = fsm.pathfinder_component.findpaths(start, end)
	if not path:
		print("No path found. Transitioning to Idle.")
		fsm._transition_to_next_state("Idle")
		return
	
	print("Initial path: ", path)
	current_target_index = 0  # Start from the first point in the path
	last_target_position = target.global_transform.origin  # Track initial target position

func update(delta: float) -> void:
	# Reduce the cooldown timer
	if path_recalculation_timer > 0:
		path_recalculation_timer -= delta

	# If no target or invalid target, find a new one
	if not is_instance_valid(target):
		print("Lost target.")
		fsm._transition_to_next_state("Idle")  # Change to idle or another state if the target is lost
		fsm.targeting_component._find_nearest_target()  # Try to acquire a new target
		return
	
	# Step 1: Check if the target has moved significantly to recalculate the path
	var target_position = target.global_transform.origin
	if target_position.distance_to(last_target_position) > npc_size * 1.0:  # Adjust threshold if needed
		# Recalculate the path if the target moved significantly
		print("Target moved significantly, recalculating path...")
		start = fsm.npc_root_node.global_transform.origin
		end = target.global_transform.origin
		path = fsm.pathfinder_component.findpaths(start, end)
		if not path:
			print("No path found after target moved. Transitioning to Idle.")
			fsm._transition_to_next_state("Idle")
			return
		current_target_index = 0
		path_recalculation_timer = path_recalculation_cooldown  # Reset the cooldown timer
		last_target_position = target_position  # Update the last target position after recalculation

	# Step 2: Check if we are in attack range
	var npc_position = fsm.npc_root_node.global_transform.origin
	if npc_position.distance_to(target_position) <= npc_size * stats.attack_range:  # Check if within attack range
		print("Target within attack range! Stopping movement and transitioning to Attack state.")
		fsm._transition_to_next_state("Attack", {"target" : target})  # Transition to attack state once in range
		return
	
	# Step 3: Continue moving along the path if not in attack range
	if path and current_target_index < len(path):
		var path_target_position = path[current_target_index]  # Get the next target point
		path_target_position.y = 0  # Ensure the target stays on the ground level
		
		# Move smoothly towards the target position
		var direction = (path_target_position - npc_position).normalized()  # Get the direction towards the target
		var movement = direction * speed * delta  # Calculate the movement step

		# Smooth movement towards the target point
		fsm.npc_root_node.global_transform.origin = npc_position.lerp(path_target_position, 0.1)  # Smooth movement with interpolation

		# Step 4: Check if we've reached the current target point
		if npc_position.distance_to(path_target_position) < distance_threshold:
			current_target_index += 1  # Move to the next target in the path
	
	# Check for a new target every update while following the path
	fsm.targeting_component._find_nearest_target()  # This ensures the Tirador will always be aware of the closest target
