extends Node3D


@onready var panel = $UI
@onready var mine_button = $UI/Mine
@onready var area = $Area3D
@onready var entities = $"../../Entities"
@onready var worker_assigned = false
var is_panel_visible = false

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
		worker_assigned = true
		var sibilyan = find_nearest_sibilyan()
		sibilyan.add_work(self)


	
	
func perform_work(worker):
	await get_tree().create_timer(5).timeout
	print("Harvest Complete")
	Global.stone_qty += 10
	self.queue_free()
	worker.task_complete()
	pass

func find_nearest_sibilyan() -> Node:
	var sibilyans = get_tree().get_nodes_in_group("Sibilyan")  
	var nearest_sibilyan = null
	var min_distance = INF
	var min_workload = INF

	for sib in sibilyans:
		
		var distance = global_position.distance_to(sib.global_position)
		var workload = sib.get_workload()  # Now stored per instance

		if workload < min_workload or (workload == min_workload and distance < min_distance):
			nearest_sibilyan = sib
			min_distance = distance
			min_workload = workload

	return nearest_sibilyan
