extends Node3D

@onready var bounds = $UI/Panel
@onready var panel = $UI
@onready var mine_button = $UI/Mine
@onready var area = $Area3D
@onready var entities = $"../../Entities"

var is_panel_visible = false

func _ready() -> void:
	area.monitoring = true
	panel.visible = false


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if $"../../Control/Build".in_building_mode:
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
			if not bounds.get_global_rect().has_point(clicked_pos):
				panel.visible = false
				is_panel_visible = false


func pressed_mine():
	panel.visible = false
	is_panel_visible = false
	var target_pos = global_transform.origin
	var miner = find_nearest_miner(target_pos)
	var worker = miner[0].get_child(0)
	worker.mine(target_pos, miner[1])


func find_nearest_miner(ref_pos):
	var nearest_miner: Node3D = null
	var shortest_distance: float = INF

	for miner in get_tree().get_nodes_in_group("Pandays"):
		var distance = ref_pos.distance_to(miner.global_transform.origin)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_miner = miner

	return [nearest_miner, self]
