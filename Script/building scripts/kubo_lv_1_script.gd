extends MeshInstance3D


var active_panel
var built: bool =false
var food_req = 60
@onready var building_name = $UI.get_child(0)
@export var sibilyan_scene: PackedScene
@onready var current_sibilyan: int = int($UI/Kubo/generateCivilian/Panel/current.text)
@onready var max_sibilyans: int = int($UI/Kubo/generateCivilian/Panel/max.text)
@onready var Entities = get_tree().get_root().get_node("Root/Base/Entities")
@onready var stored_sibilyans: Array = []
func _ready() -> void: 


	Global.all_kubos.append(self)  # Register this Kubo in Global
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	building_name.get_node("generateCivilian").pressed.connect(_on_generate_civilian_pressed)
	building_name.get_node("generateCivilian/Panel/Button").pressed.connect(generate_civilian)
	# Initialize sibilyan values (avoid crashing if text isn't set yet)
	
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
	update_value()
	active_panel.show()
	pass
	# Check if we can generate a new civilian
func show_max_civilian_warning() -> void:
	var warning_label = get_tree().current_scene.find_child("maxCivilianReached")
	warning_label.visible = true  # Show warning label

	# Hide after 3 seconds
	await get_tree().create_timer(3.0).timeout
	warning_label.visible = false  # Hide warning label
func generate_civilian() -> void:
	if Global.food_qty < food_req:
		display_warning()
		return
	if Global.can_generate_civilian():
		print("Civilian generated!")
		if current_sibilyan >= max_sibilyans:
			show_max_civilian_warning()  # Show warning for 3 seconds
			add_sibilyan_to_other_kubo()
			return
		current_sibilyan += 1
		store_sibilyans()
		update_value()
	else:
		print("Max civilians reached!")
		show_max_civilian_warning()
		return



func display_warning() -> void:
	var warning_label = get_tree().current_scene.find_child("notEnoughFood")
	warning_label.visible = true  # Show warning label

	# Hide after 3 seconds
	await get_tree().create_timer(3.0).timeout
	warning_label.visible = false  # Hide warning label
	
func store_sibilyans():
	var sib_inst = sibilyan_scene.instantiate()
	stored_sibilyans.append(sib_inst)
	sib_inst.assigned_kubo = self
	Global.food_qty -= food_req
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
	# First, check if we have stored Sibilyans in any Kubo
	for kubo in Global.all_kubos:
		if kubo.stored_sibilyans.size() > 0:
			var sib = kubo.stored_sibilyans.pop_front()  # Take the first stored Sibilyan
			Entities.add_child(sib)  # Add to the scene
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

func update_value() -> void:
	building_name.get_node("generateCivilian/Panel").get_node("current").text = "Current: " + str(current_sibilyan)
	
func add_sibilyan_to_other_kubo() -> void:
	for kubo in Global.all_kubos:
		if kubo.current_sibilyan < kubo.max_sibilyans:
			kubo.generate_civilian()
			return
		
	
func remove_material_override(mesh_instance) -> void:
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, null)
