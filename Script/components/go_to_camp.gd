extends Node3D

var speed = 10
var path = []
var path_index = 0
@onready var amap = get_tree().get_first_node_in_group("pathscript")
@onready var character_body = get_parent() as CharacterBody3D  # ✅ Get the parent CharacterBody3D

signal path_ready


func _process(delta: float) -> void:
	if path.size() > 0:
		move(delta)

func move(delta):
	if path_index < path.size():
		character_body.get_node("Skeleton3D").show()
		character_body.get_node("AnimationPlayer").play("run")
		path[path_index].y = .5
		var move_vec = (path[path_index] - global_transform.origin)
		
		if move_vec.length() < 2:  # NPC is close to the target waypoint
			path_index += 1
		else:
			character_body.velocity = move_vec.normalized() * speed
			character_body.move_and_slide()

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

func go_to_camp():
	for kampo in Global.all_kampo:
		if kampo:
			await go_here(kampo.global_transform.origin)
			print("Arrive")
			character_body.get_node("AnimationPlayer").play("idle")
			
			return kampo
	pass
