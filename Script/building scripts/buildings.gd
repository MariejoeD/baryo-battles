extends MeshInstance3D

@onready var ui_scene = preload("res://Scene/buildings/building_ui.tscn")
@export var building_name: String
var ui_instance:Control = null
var building_ui
var button_clicked:bool = false 


func _ready() -> void:
	if ui_instance == null:
		ui_instance = ui_scene.instantiate()
		add_child(ui_instance)
		building_ui = ui_instance.get_node_or_null(building_name)
		building_ui.visible = true

func clicked_building(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		ui_instance.visible = !ui_instance.visible
		pass
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and button_clicked == false:
		if ui_instance.visible:
			var mouse_pos = get_viewport().get_mouse_position()
			for button in building_ui.get_children():
				if button.get_global_rect().has_point(mouse_pos):
					button_clicked = true
					
					return 
			if button_clicked == false:
				ui_instance.visible = false
		pass
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if ui_instance.visible:
			ui_instance.visible = false
			button_clicked = false
	pass


















#func _ready() -> void:
	#print(building_name)
	#
	#if ui_instance == null:
		#ui_instance = ui_scene.instantiate()
		#add_child(ui_instance)  # Add the entire UI instance
		#ui_instance.hide()
		#building_ui = ui_instance.get_node_or_null(building_name)
		#if building_ui:
			#print("Building UI found:", building_ui.name)
		#else:
			#print("Error: Building UI not found in the UI scene.")
#
#func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("Pressed"+building_name)
		#ui_instance.visible = not ui_instance.visible
		#if building_ui:
			#
			#building_ui.visible = not building_ui.visible
			#print("Toggled UI:", building_ui.name)
		#else:
			#print("Error: Cannot toggle, UI is null.")
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#if building_ui and building_ui.visible:
			#var viewport = get_viewport()
			#var clicked_pos = viewport.get_mouse_position()
			#if not building_ui.get_global_rect().has_point(clicked_pos) and not ui_instance.button_clicked:
				#ui_instance.hide()
				#building_ui.hide()
