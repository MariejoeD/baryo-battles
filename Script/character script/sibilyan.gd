extends CharacterBody3D

var speed = 10
var path = []
var path_index = 0
@onready var amap = get_tree().get_first_node_in_group("pathscript")
var workload = []  # Stores work tasks
var assigned_kubo
signal path_ready
var returning = false
var current_work :Node = null
var remaining :float = 0
 # Emits when work is completed

func _ready() -> void:
	$AnimationPlayer.play("idle")

func _process(delta: float) -> void:
	if path.size() > 0:
		move(delta)
	if returning and assigned_kubo and global_position.distance_to(assigned_kubo.global_position) < 3:
		store_in_kubo()

func move(delta):
	if path_index < path.size():
		$Skeleton3D.show()
		$AnimationPlayer.play("walk")
		path[path_index].y = .5
		var move_vec = (path[path_index] - global_transform.origin)
		if move_vec.length() < 2:  # NPC is close to the target waypoint
			path_index += 1
		else:
			velocity = move_vec.normalized() * speed
			move_and_slide()

			var direction = move_vec.normalized()
			var target_rotation_y = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 5)

	if path_index >= path.size() and path.size() > 0:
		path.clear()  # Clear path when target is reached
		path_ready.emit()  # NPC has reached destination

func set_path(target_pos: Vector3):
	var current_pos = global_transform.origin
	#current_pos.y = 0
	#target_pos.y = 0
	
	path = amap.find_path(current_pos, target_pos)
	path_index = 0

func go_here(target):
	set_path(target)
	await path_ready  # Wait until NPC reaches the target

func add_work(task_target):
	returning = false
	workload.append(task_target)
	print("Added work:", task_target.name, "Current workload size:", workload.size())
	if workload.size() == 1:  # Start immediately if idle
		execute_next_work()


func execute_next_work():
	if workload.size() > 0:
		var work = workload[0]  # Get first task in queue
		#print("Going to:", work.name)
		await go_here(work.global_transform.origin)  # Wait until NPC reaches the target location

		#print("Reached target location:", work.name)  # Debugging line
		if work.has_method("perform_work"):
			$Skeleton3D.hide()
			$Skeleton3D2.show()
			$AnimationPlayer.play("chopping")
			if current_work == work:
				work.perform_work(self,remaining)  # Execute the task and wait for completion
			else:
				work.perform_work(self)  # Execute the task and wait for completion
			
	

func task_complete():
	$Skeleton3D2.hide()
	$Skeleton3D.show()
	$AnimationPlayer.play("idle")
	workload.pop_front()  # Remove completed task
	  # Signal work completion

		# If more work remains, execute the next task
	if workload.size() > 0:
		execute_next_work()
	else:
		returning = true
		return_to_kubo()
		pass


func return_to_kubo():
	if assigned_kubo:
		print("Returning to Kubo:", assigned_kubo.name)
		set_path(assigned_kubo.global_transform.origin)  # Move to the Kubo position
	else:
		print("No assigned Kubo! Searching for the nearest one...")
		assigned_kubo = find_nearest_kubo()
		
		
		if assigned_kubo:
			assigned_kubo.current_sibilyan += 1
			assigned_kubo.update_value()
			set_path(assigned_kubo.global_transform.origin)



func store_in_kubo():
	print("Sibilyan stored in Kubo:", assigned_kubo.name)
	assigned_kubo.stored_sibilyans.append(self)
	
	get_parent().remove_child(self)  # Remove Sibilyan from the world
	
func find_nearest_kubo() -> Node:
	var nearest_kubo = null
	var min_distance = INF

	for kubo in Global.all_kubos:
		var distance = global_position.distance_to(kubo.global_position)
		if distance < min_distance and kubo.current_sibilyan < kubo.max_sibilyans:
			nearest_kubo = kubo
			min_distance = distance

	return nearest_kubo

func get_workload() -> int:
	return workload.size()
