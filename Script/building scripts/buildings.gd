extends MeshInstance3D

@onready var ui_scene = preload("res://Scene/buildings/building_ui.tscn")
@export var building_name: String
var ui_instance: Control = null  # Ensure UI is a Control node
var building_ui
func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if ui_instance == null:
			ui_instance = ui_scene.instantiate()
			add_child(ui_instance)
		if not ui_instance.visible:
			ui_instance.show()
		building_ui = ui_instance.get_node_or_null(building_name)
		if building_ui:
			building_ui.visible = not building_ui.visible  

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if building_ui and building_ui.visible:
			var viewport = get_viewport()
			var clicked_pos = viewport.get_mouse_position()
			if not building_ui.get_global_rect().has_point(clicked_pos):
				ui_instance.hide()
				building_ui.hide()
		pass
