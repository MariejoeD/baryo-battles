extends CharacterBody3D

var speed = 10
var path = []
var path_index = 0
@onready var amap = get_tree().get_first_node_in_group("pathscript")
var workload = []  # Stores work tasks

signal path_ready
 # Emits when work is completed

func _ready() -> void:
	$AnimationPlayer.play("idle")

func _process(delta: float) -> void:
	if path.size() > 0:
		move(delta)
	

func move(delta):
	if path_index < path.size():
		$Skeleton3D.show()
		$AnimationPlayer.play("walk")
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
	current_pos.y = 1
	target_pos.y = 1
	
	path = amap.find_path(current_pos, target_pos)
	path_index = 0

func go_here(target):
	set_path(target)
	await path_ready  # Wait until NPC reaches the target

func add_work(task_target):
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
	pass

func get_workload() -> int:
	return workload.size()
