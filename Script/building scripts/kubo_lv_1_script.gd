extends MeshInstance3D


var active_panel
var built: bool =false
@onready var building_name = $UI.get_child(0)
@export var sibilyan_scene: PackedScene
var max_sibilyans: int = 3
func _ready() -> void: 
	Global.all_kubos.append(self)  # Register this Kubo in Global
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	building_name.get_node("generateCivilian").pressed.connect(_on_generate_civilian_pressed)
	building_name.get_node("generateCivilian/Panel/Button").pressed.connect(generate_civilian)

	pass

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if built and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not $UI.visible:
			$UI.visible = true  # Only open UI, don't toggle it off
		
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var button_clicked = false
		var panel_clicked = false

			# Check if clicking a button
		for button in building_name.get_children():
			if button.get_global_rect().has_point(mouse_pos):
				button_clicked = true
				break
		# Check if clicking inside an active panel
		if active_panel and active_panel.visible:
			if active_panel.get_global_rect().has_point(mouse_pos):
				panel_clicked = true
		# Hide UI only if clicking outside both buttons and panel
		if not button_clicked and not panel_clicked:
			$UI.visible = false
			if active_panel:
				active_panel.hide()
				active_panel = null
			
			
func _on_view_information_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null("viewInformation/InformationPanel")
	active_panel.show()
	
	pass # Replace with function body.


func _on_upgrade_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null("upgrade/upgradePanel")
	active_panel.show()
	pass # Replace with function body.
	
func _on_generate_civilian_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null("generateCivilian/Panel")
	active_panel.show()
	pass
func generate_civilian() -> void:
	if Global.food_qty < int(active_panel.get_node("foodAmount").text):
		print("Not Enough Food")
		return
	# Check if we can generate a new civilian
	if Global.can_generate_civilian():
		print("Civilian generated!")
	else:
		print("Max civilians reached!")
		return
	
	pass
func build():
	var sibilyan = find_nearest_sibilyan()
	sibilyan.add_work(self)
	pass

func perform_work(worker):
	await get_tree().create_timer(10).timeout
	print("Build Complete")
	#Change  Indicator
	remove_material_override(self)
	built = true
	
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
	
	
func remove_material_override(mesh_instance) -> void:
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, null)
