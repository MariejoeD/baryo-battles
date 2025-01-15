extends CharacterBody3D

#@onready var amap = $"Base/AMap/floor setup"
var speed = 10
var path = []
var path_index = 0
var parent
var gparent
var base
var camera
var amap
var moveb
var animation
var tree
func _ready():
	parent = get_parent()
	gparent = parent.get_parent()
	base = gparent.get_parent()
	amap = base.get_node("AMap/floor setup")
	animation = $AnimationPlayer
	animation.play("idle",-1,1,true)
	pass
func _process(delta: float):
	if moveb:
		#global_transform.origin.y = 0
		move(delta)
		if animation.current_animation != "walk":
			animation.play("walk", -1, 1, true)
	else:
		if animation.current_animation != "idle":
			animation.play("idle", -1, 1, true)
		
	pass

func move(delta):
	if path_index < path.size():
		var move_vec = (path[path_index] - global_transform.origin)
		
		# If close to the target waypoint, proceed to the next
		if move_vec.length() < 2:
			path_index += 1
		else:
			# Move towards the target
			velocity = move_vec.normalized() * speed
			move_and_slide()

			# Calculate target rotation based on direction
			var direction = move_vec.normalized()
			var target_rotation_y = atan2(direction.x, direction.z)  # atan2 gives the correct Y-axis rotation

			# Smoothly interpolate current rotation to the target rotation (360-degree wrapping)
			rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 5)  # Use lerp_angle for smooth shortest-path rotation
	else:
		var tree_pos = path[path.size() - 1]
		if global_transform.origin.distance_to(tree_pos):
			chop_tree()
			moveb = false
			


		
	pass
	
func chop(target,tree):
	self.tree = tree
	moveb = true
	set_path(target)
	
	#put timer for 5 second when destintaion reach then run a command to remove the tree
	pass
	
func chop_tree():
	print("tree")
	self.visible = false
	$"../sibilyanWithAxe".transform = self.transform
	$"../sibilyanWithAxe".visible = true
	$"../sibilyanWithAxe/AnimationPlayer".play("chopping",-1,1,true)
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5
	timer.one_shot = true
	timer.connect("timeout", Callable(self,"_on_chopped_tree"))
	timer.start()
	pass

func _on_chopped_tree():
	var _tree_pos = path[path.size() - 1]
	if tree:
		SignalManager.tree_remove.emit(tree)
		tree.queue_free()
	$"../sibilyanWithAxe".visible = false
	self.visible = true
	Global.wood_qty += 5
	pass
func idle():
	pass

func set_path(target_pos: Vector3):
	# Calculate path to the target position
	var current_pos = global_transform.origin
	current_pos.y = 1  # Keep pathfinding on the XZ plane
	target_pos.y = 1
	path = amap.find_path(current_pos, target_pos)
	path_index = 0
