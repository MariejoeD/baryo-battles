extends Node3D

# Dictionary to store popups for each tree

# Reference to the popup and other nodes
@onready var bounds = $UI/Panel
@onready var panel = $UI
@onready var cut_button = $UI/Cut
@onready var uproot_button = $UI/Uproot
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
			if not bounds.get_global_rect().has_point(clicked_pos):
				panel.visible = false
				is_panel_visible = false



func pressed_cut():
	panel.visible = false
	is_panel_visible = false
	var target_pos = global_transform.origin
	var panday = find_nearest_panday(target_pos)
	
	var sibilyan = panday[0].get_child(0)
	sibilyan.chop(target_pos,panday[1])
	pass

func pressed_uproot():
	
	pass

func find_nearest_panday(ref_pos):
	var nearest_panday: Node3D = null
	var shortest_distance: float = INF
	
	for panday in get_tree().get_nodes_in_group("Pandays"):
		var distance = ref_pos.distance_to(panday.global_transform.origin)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_panday = panday
		
	return [nearest_panday, self]
