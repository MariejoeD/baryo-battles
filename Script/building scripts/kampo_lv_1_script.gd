extends MeshInstance3D


var active_panel
var built: bool =false
@onready var building_name = $UI.get_child(0)
var troops: Array = []
@export var troopImagePath : String
@onready var container = get_node("UI/Kampo/ManageTroops/manageTroopsPanel/ScrollContainer/ScrollContainer/HBoxContainer")
var spaces = 100

func update_ui_container():
	# Step 1: Count each troop type
	var troop_counts = {}
	for troop in troops:
		if troop.name in troop_counts:
			troop_counts[troop.name] += 1
		else:
			troop_counts[troop.name] = 1
	print(troop_counts)
	# Step 2: Loop through counted troops
	for troop_name in troop_counts.keys():
		var count = troop_counts[troop_name]

		# Check if UI element already exists
		var existing_entry = container.get_node_or_null(troop_name)
		if existing_entry:
			# Just update the label
			var count_label = existing_entry.get_node("qty_label")
			count_label.text = "x" + str(count)
		else:
			# Create new troop icon
			var troop_display = TextureRect.new()
			troop_display.name = troop_name
			troop_display.texture = load(troopImagePath + troop_name + ".png")
			
			var qty_label = Label.new()
			qty_label.name = "qty_label"
			qty_label.text = "x" + str(count)
			qty_label.add_theme_font_size_override("font_size", 20)
			qty_label.add_theme_color_override("font_color", Color(1, 1, 1))

			# Positioning
			qty_label.anchor_right = 1.0
			qty_label.anchor_top = 0.0
			qty_label.anchor_left = 1.0
			qty_label.anchor_bottom = 0.0
			qty_label.position = Vector2(-30, 5)

			troop_display.add_child(qty_label)
			container.add_child(troop_display)


func _ready() -> void:
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	building_name.get_node("ManageTroops").pressed.connect(_on_manage_troops_pressed)
	

	pass
func instant_build():
	built = true
	add_to_group("Buildings")
	Global.all_kampo.append(self)
	Buildings.buildings["KampoBtn"] -= 1
	# Restore troops if saved
	if Global.kampo_troops.has(self.get_instance_id()):
		troops = Global.kampo_troops[self.get_instance_id()]
		update_ui_container()  # Refresh UI after restoring troops
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

func _on_manage_troops_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null("ManageTroops/manageTroopsPanel")
	active_panel.show()
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
	instant_build()
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

	
	
func remove_material_override(mesh_instance) -> void:
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, null)
