extends CharacterBody3D

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
var target_resource  # Can be a tree or stone
var resource_type    # "tree" or "stone"

func _ready():
	SignalManager.discovered.emit(self.name)
	parent = get_parent()
	gparent = parent.get_parent()
	base = gparent.get_parent()
	amap = base.get_node("AMap/floor setup")
	animation = $AnimationPlayer
	animation.play("idle", -1, 1, true)


func _process(delta: float):
	if moveb:
		move(delta)
		if animation.current_animation != "walk":
			animation.play("walk", -1, 1, true)
	else:
		if animation.current_animation != "idle":
			animation.play("idle", -1, 1, true)


func move(delta):
	if path_index < path.size():
		var move_vec = (path[path_index] - global_transform.origin)

		if move_vec.length() < 2:
			path_index += 1
		else:
			velocity = move_vec.normalized() * speed
			move_and_slide()

			var direction = move_vec.normalized()
			var target_rotation_y = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 5)
	else:
		if resource_type == "tree":
			chop_tree()
		elif resource_type == "stone":
			mine_stone()
		moveb = false


func chop(target, resource):
	target_resource = resource
	resource_type = "tree"
	moveb = true
	set_path(target)


func mine(target, resource):
	target_resource = resource
	resource_type = "stone"
	moveb = true
	set_path(target)


func chop_tree():
	print("Chopping tree...")
	switch_to_sibilyan("chopping")
	start_timer("_on_chopped_tree")


func mine_stone():
	print("Mining stone...")
	switch_to_sibilyan("mining")
	start_timer("_on_mined_stone")


func switch_to_sibilyan(animation_name: String):
	self.visible = false
	var sibilyan = $"../sibilyanWithAxe"
	sibilyan.transform = self.transform
	sibilyan.visible = true
	sibilyan.get_node("AnimationPlayer").play(animation_name, -1, 1, true)


func start_timer(callback: String):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5
	timer.one_shot = true
	timer.connect("timeout", Callable(self, callback))
	timer.start()


func _on_chopped_tree():
	if target_resource:
		SignalManager.tree_remove.emit(target_resource)
		target_resource.queue_free()
	finalize_action("tree", 5)


func _on_mined_stone():
	if target_resource:
		SignalManager.stone_remove.emit(target_resource)
		target_resource.queue_free()
	finalize_action("stone", 3)


func finalize_action(resource_type: String, reward: int):
	var sibilyan = $"../sibilyanWithAxe"
	sibilyan.visible = false
	self.visible = true
	if resource_type == "tree":
		Global.wood_qty += reward
	elif resource_type == "stone":
		Global.stone_qty += reward


func set_path(target_pos: Vector3):
	var current_pos = global_transform.origin
	current_pos.y = 1
	target_pos.y = 1
	path = amap.find_path(current_pos, target_pos)
	path_index = 0
