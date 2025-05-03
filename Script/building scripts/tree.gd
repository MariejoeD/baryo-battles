extends Node3D

# Dictionary to store popups for each tree

# Reference to the popup and other nodes
@onready var panel = $UI
@onready var cut_button = $UI/Cut
@onready var area = $Area3D
@onready var entities = $"../../Entities"
var worker_assigned = false
var is_panel_visible = false
func _ready() -> void:
	area.monitoring = true
	panel.visible = false
	area.input_event.connect(_on_area_3d_input_event)
	#print("Area monitoring:", area.monitoring)
	#print("Area input pickable:", area.input_ray_pickable)
	#print("Collision layer:", area.collision_layer)
	#print("Collision mask:", area.collision_mask)


func init():
	print("Tree init:", self.name)
	area.input_event.disconnect(_on_area_3d_input_event)
	if not area.is_connected("input_event", _on_area_3d_input_event):
		print("Connected")
		area.input_event.connect(_on_area_3d_input_event)
	area.monitoring = true


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#print("Area received event:", event)

	if $"../../Control/Build".building_mode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("test")
			if panel.visible:
				panel.visible = false  # hide the panel when already visible
				is_panel_visible = false
			else:
				panel.visible = true # show panel
				is_panel_visible = true
				
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if is_panel_visible:
			var viewport = get_viewport()
			var clicked_pos = viewport.get_mouse_position()
			
			#checked if the click is outside the panel
			if not cut_button.get_global_rect().has_point(clicked_pos):
				panel.visible = false
				is_panel_visible = false



func pressed_cut():
	if not worker_assigned:
		panel.visible = false
		is_panel_visible = false
		if Global.get_wood_cap() == Global.wood_qty or Global.get_wood_cap() == 0:
			return
		var sibilyan = find_nearest_sibilyan()
		if sibilyan == null:
			return
		worker_assigned = true
		sibilyan.add_work(self)
		pass



	
var start_time := 0.0
var duration := 5
func get_remaining_time():
	return max(0.0,duration - (Global.total_game_time - start_time))
	
func perform_work(worker, duration:= -1):
	if duration < 0.0:
		duration = self.duration
	start_time = Global.total_game_time
	await get_tree().create_timer(duration).timeout
	print("Harvest Complete")
	Global.wood_qty += randi_range(20, 30)
	if Global.get_wood_cap() < Global.wood_qty:
		Global.wood_qty = Global.get_wood_cap()
	get_parent().spawn_tree_after_delay()
	self.queue_free()
	worker.task_complete()
	pass

func find_nearest_sibilyan() -> Node:
	# First, check if we have stored Sibilyans in any Kubo
	for kubo in Global.all_kubos:
		if kubo.stored_sibilyans.size() > 0:
			var sib = kubo.stored_sibilyans.pop_front()  # Take the first stored Sibilyan
			get_tree().current_scene.find_child("Entities").add_child(sib)  # Add to the scene
			sib.global_transform.origin = kubo.global_transform.origin  # Spawn near the Kubo
			print("Spawned stored Sibilyan from Kubo:", kubo)
			return sib  # Return this Sibilyan for work

	# If no stored Sibilyans, find the nearest active one
	var sibilyans = get_tree().get_nodes_in_group("Sibilyan")
	var nearest_sibilyan = null
	var min_distance = INF
	var min_workload = INF

	for sib in sibilyans:
		var distance = global_position.distance_to(sib.global_position)
		var workload = sib.get_workload()

		if workload < min_workload or (workload == min_workload and distance < min_distance):
			nearest_sibilyan = sib
			min_distance = distance
			min_workload = workload

	return nearest_sibilyan
