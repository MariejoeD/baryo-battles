extends Building
@onready var level_label = %level

var active_panel
@onready var training_timer: Timer = Timer.new()
var trainingTroops: Array = []
var sacrificeSib: Array = []
@export var troopImagePath : String
@onready var building_name = $UI.get_child(0)
var training_panel
var troopsDict = {
	"arnisador": {"trainingTime": 1, "scene": "res://Scene/Characters/arnisador.tscn", "required_level": 1},
	"lakanWarrior": {"trainingTime": 1, "scene": "res://Scene/Characters/lakan_warrior.tscn", "required_level": 2},
	"tirador": {"trainingTime": 1, "scene": "res://Scene/Characters/tirador.tscn", "required_level": 3},
	"manggagamot": {"trainingTime": 1, "scene": "res://Scene/Characters/manggagamot.tscn", "required_level": 2},
	"marites": {"trainingTime": 1, "scene": "res://Scene/Characters/marites.tscn", "required_level": 3},
}


func get_save_data() -> Dictionary:
	var data = super.get_save_data()

	var training_data: Array = []
	for i in trainingTroops.size():
		var troop = trainingTroops[i]
		var troop_dict = {
			"name": troop.name,
			"scene": troop.scene,
			"duration": troop.duration,
		}
		# Save remaining time only for the first troop (the one currently being trained)
		if i == 0 and training_timer != null:
			troop_dict["remaining_time"] = training_timer.time_left
		training_data.append(troop_dict)
	
	data["trainingTroops"] = training_data
	return data


func load_from_data(data: Dictionary) -> void:
	super.load_from_data(data)

	trainingTroops.clear()
	var loaded_queue: Array = data.get("trainingTroops", [])
	for troop_dict in loaded_queue:
		trainingTroops.append({
			"name": troop_dict.get("name", ""),
			"scene": troop_dict.get("scene", ""),
			"duration": troop_dict.get("duration", 1),
			"remaining_time": troop_dict.get("remaining_time", null),
		})

	if trainingTroops.size() > 0:
		training()

		
func _ready() -> void:
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	building_name.get_node("trainTroops").pressed.connect(_on_train_troops_pressed)
	training_panel = building_name.get_node("trainTroops/mainPanel/trainingPanel/ScrollContainer/HBoxContainer")
	for troop in building_name.get_node("trainTroops/mainPanel/troopsPanel/ScrollContainer/HBoxContainer").get_children():
		troop.pressed.connect(_on_troop_pressed.bind(troop))
	find_child("upgradeButton").pressed.connect(upgrade)
	pass


func show_warning_label(label_name: String) -> void:
	var warning_label = get_tree().current_scene.find_child(label_name, true, false)
	if warning_label:
		warning_label.visible = true
		
		# Ensure the label is on top by setting its Z-Index to a high value
		warning_label.z_index = 10  # Adjust this value to suit your needs
		
		await get_tree().create_timer(3.0).timeout
		warning_label.visible = false
	else:
		print("Warning label NOT found:", label_name)



func _on_troop_pressed(troop) -> void:
	# Check available Sibilyans
	var total_sibilyans = Global.get_current_civilian_count()
	
	print("Total Sibilyans: ", total_sibilyans)
	print(troop.get_node("cost/cost").text)
	var food_cost :int = int(troop.find_child("foodCost").text)
	var wood_cost :int = int(troop.find_child("woodCost").text)
	var space_cost :int = int(troop.get_node("cost/cost").text)
	var stone_cost :int = int(troop.find_child("stoneCost").text)
	Global.recalculate_space()
	var remaining_space :int = Global.get_remaining_space()
	
	if remaining_space < space_cost or Global.food_qty < food_cost or Global.wood_qty < wood_cost or Global.stone_qty < stone_cost:
		# warning resource not enough
		return
	
	
	if sacrificeSib.size() >= total_sibilyans:
		print("No available Sibilyan to sacrifice!")
		show_warning_label("noAvailableCivilian")
		return

	var sib = find_nearest_sibilyan()	
	if sib == null:
		print("No valid Sibilyan found!")
		show_warning_label("noValidSibilyanFound")
		return
	Global.food_qty -= food_cost
	Global.wood_qty -= wood_cost
	Global.stone_qty -= stone_cost
	
	sacrificeSib.append(sib)
	if sib.assigned_kubo:
		var kubo = sib.assigned_kubo
		kubo.current_sibilyan -= 1
		kubo.stored_sibilyans.erase(sib)

	await sib.go_here(self.global_transform.origin)
	sacrificeSib.erase(sib)
	sib.queue_free()

	# Check if the troop already exists in the training panel
	var existing_entry = training_panel.get_node_or_null(NodePath(str(troop.name)))
	
	if existing_entry:
		# If the troop already exists, increase the count
		var count_label = existing_entry.get_node("CountLabel")
		count_label.text = "x" + str(int(count_label.text.substr(1)) + 1)  # Increment count
	else:
		# Create a new entry if it doesn't exist
		# Create TextureButton
		var textureBtn = TextureButton.new()
		textureBtn.name = troop.name
		textureBtn.texture_normal = load(troopImagePath + troop.name + ".png")

		# Create Count Label as a child of TextureButton
		var count_label = Label.new()
		count_label.name = "CountLabel"
		count_label.text = "x1"  # Initialize count
		count_label.add_theme_font_size_override("font_size", 20)
		count_label.add_theme_color_override("font_color", Color(1, 1, 1))

		# Correct Positioning: Anchor to top-right inside TextureButton
		count_label.anchor_right = 1.0
		count_label.anchor_top = 0.0
		count_label.anchor_left = 1.0
		count_label.anchor_bottom = 0.0

		# Use `position` instead of `margin` to place it inside the button
		count_label.position = Vector2(-30, 5)  # Adjust X and Y to fit inside
		
		# Add Count Label to TextureButton
		textureBtn.add_child(count_label)

		# Add TextureButton to training panel
		training_panel.add_child(textureBtn)

	var duration = troopsDict[troop.name]["trainingTime"]
	var scene = troopsDict[troop.name]["scene"]
	trainingTroops.append({"name": troop.name, "duration": duration, "scene":scene})

	if trainingTroops.size() == 1:
		training()


func training() -> void:
	if trainingTroops.is_empty():
		return

	var current = trainingTroops[0]
	var duration = current.get("remaining_time", current.duration)
	
	training_timer.start(duration)

	# Find the troop entry in the training panel
	var troop_entry = training_panel.get_node_or_null(NodePath(current["name"]))
	if troop_entry:
		var count_label = troop_entry.get_node("CountLabel")
		var count = int(count_label.text.substr(1))  # Extract number from "xN"
		
		if count > 1:
			count_label.text = "x" + str(count - 1)  # Decrease count
		else:
			troop_entry.queue_free()  # Remove when count reaches 0
	send_to_kampo(current)
	trainingTroops.pop_front()  # Remove the troop from the queue
	
	if not trainingTroops.is_empty():
		training()  # Continue training the next troop

func send_to_kampo(troop):
	var troop_inst = load(troop["scene"]).instantiate()
	troop_inst.find_child("Targeting Component").targeting_enabled = false
	get_tree().current_scene.find_child("Entities").add_child(troop_inst)
	troop_inst.global_transform.origin = self.global_transform.origin
	troop_inst.get_node("Detection/CollisionShape3D").shape.radius *= 0.4
	
	var kampo = await troop_inst.get_node("GoToCamp").go_to_camp()
	kampo.troops.append(troop)
	kampo.update_ui_container()
	pass
	

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if built and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not $UI.visible:
			$UI.visible = true  # Only open UI, don't toggle it off



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
	_toggle_panel("viewInformation/InformationPanel")

func _on_upgrade_pressed() -> void:
	_toggle_panel("upgrade/upgradePanel")

func upgrade():
	if Npc.TH_level == level:
		#upgrade limit reach
		return
	level += 1

func _on_train_troops_pressed() -> void:
	_toggle_panel("trainTroops/mainPanel")
	var troop_buttons = building_name.get_node("trainTroops/mainPanel/troopsPanel/ScrollContainer/HBoxContainer").get_children()
	for troop_btn in troop_buttons:
		var troop_name = troop_btn.name
		if troopsDict.has(troop_name):
			var required_level = troopsDict[troop_name].get("required_level", 1)
			troop_btn.visible = level >= required_level

func _toggle_panel(panel_path: String) -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null(panel_path)
	if active_panel:
		active_panel.show()
	


func build() -> void:
	var sibilyan = find_nearest_sibilyan()
	if sibilyan:
		sibilyan.add_work(self)

func on_placed():
	super.on_placed()
	add_to_group("Buildings")
	Buildings.buildings["SandatahangLakasBtn"] -= 1
	
func instant_build():
	built = true
	pass

func perform_work(worker) -> void:
	await get_tree().create_timer(10).timeout
	print("Build Complete")
	remove_material_override(self)
	instant_build()
	worker.task_complete()

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
		if sib in sacrificeSib:
			continue
		
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
func _on_upgrade_button_pressed() -> void:
	if Npc.TH_level <= level:
		return

	level += 1
	level_label.text = "Level: " + str(level)
