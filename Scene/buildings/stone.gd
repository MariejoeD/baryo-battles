extends Node3D


@onready var panel = $UI
@onready var mine_button = $UI/Mine
@onready var area = $Area3D
@onready var Entities = get_tree().current_scene.find_child("Entities")
@onready var worker_assigned = false
var is_panel_visible = false
@export var stone_harvest := 10
var start_time := 0.0
var duration := 5

func _ready() -> void:
	area.monitoring = true
	panel.visible = false


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if $"../../Control/Build".building_mode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if panel.visible:
				panel.visible = false
				is_panel_visible = false
			else:
				panel.visible = true
				is_panel_visible = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if is_panel_visible:
			var viewport = get_viewport()
			var clicked_pos = viewport.get_mouse_position()
			if not mine_button.get_global_rect().has_point(clicked_pos):
				panel.visible = false
				is_panel_visible = false


func pressed_mine():
	if not worker_assigned:
		panel.visible = false
		is_panel_visible = false
		if Global.get_stone_cap() == Global.stone_qty or Global.get_stone_cap() == 0:
			return
		var sibilyan = find_nearest_sibilyan()
		worker_assigned = true
		sibilyan.add_work(self)


func get_remaining_time():
	return max(0.0,duration - (Global.total_game_time - start_time))
	
func perform_work(worker, duration:= -1):
	if duration < 0.0:
		duration = self.duration
	start_time = Global.total_game_time
	await get_tree().create_timer(duration).timeout
	print("Harvest Complete")
	Global.stone_qty += 10
	if Global.get_stone_cap() < Global.stone_qty:
		Global.stone_qty = Global.get_stone_cap()
	self.queue_free()
	worker.task_complete()
	pass

func find_nearest_sibilyan() -> Node:
	# First, check if we have stored Sibilyans in any Kubo
	for kubo in Global.all_kubos:
		if kubo.stored_sibilyans.size() > 0:
			var sib = kubo.stored_sibilyans.pop_front()  # Take the first stored Sibilyan
			print(sib)
			Entities.add_child(sib)  # Add to the scene
			print(sib.get_path())
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
