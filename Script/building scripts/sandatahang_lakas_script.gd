extends MeshInstance3D


var active_panel
var built: bool =false
var trainingTroops: Array = []
var sacrificeSib: Array = []
@export var troopImagePath : String
@onready var building_name = $UI.get_child(0)
var training_panel
var troopsDict = {
	"arnisador": {"trainingTime": 5},
	"lakanWarrior": {"trainingTime": 10},
	"tirador": {"trainingTime": 10},
	"manggagamot": {"trainingTime": 15},
	"marites": {"trainingTime": 15},
}

func _ready() -> void:
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	building_name.get_node("trainTroops").pressed.connect(_on_train_troops_pressed)
	training_panel = building_name.get_node("trainTroops/mainPanel/trainingPanel/ScrollContainer/HBoxContainer")
	for troop in building_name.get_node("trainTroops/mainPanel/troopsPanel/ScrollContainer/HBoxContainer").get_children():
		troop.pressed.connect(_on_troop_pressed.bind(troop))

	pass
	

func _on_troop_pressed(troop) -> void:
	# Count active Sibilyans
	var active_sibilyans = Global.get_current_civilian_count()
	
	# Count stored Sibilyans in all Kubos
	var stored_sibilyans = 0
	for kubo in Global.all_kubos:
		stored_sibilyans += kubo.stored_sibilyans.size()

	# Get total available Sibilyans
	var total_sibilyans = active_sibilyans + stored_sibilyans
	
	# Ensure there's at least one available Sibilyan
	if sacrificeSib.size() >= total_sibilyans:
		print("No available Sibilyan to sacrifice!")
		return

	var sib = find_nearest_sibilyan()

	# If no valid Sibilyan is found, stop the function
	if sib == null:
		print("No valid Sibilyan found!")
		return

	sacrificeSib.append(sib)
	if sib:
		if sib.assigned_kubo:
			var kubo = sib.assigned_kubo
			kubo.current_sibilyan -= 1
			kubo.stored_sibilyans.erase(sib)

		await sib.go_here(self.global_transform.origin)
		sib.queue_free()

		var textureBtn = TextureButton.new()
		textureBtn.name = troop.name
		textureBtn.texture_normal = load(troopImagePath + troop.name + ".png")
		training_panel.add_child(textureBtn)

		var duration = troopsDict[troop.name]["trainingTime"]
		trainingTroops.append({"name": troop.name, "duration": duration})

		if trainingTroops.size() == 1:
			training()

func training() -> void:
	if trainingTroops.is_empty():
		return
	
	var currentTroop = trainingTroops.front()
	await get_tree().create_timer(currentTroop["duration"]).timeout

	if training_panel.get_child_count() > 0:
		training_panel.get_child(0).queue_free()

	trainingTroops.pop_front()

	if not trainingTroops.is_empty():
		training()


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

func _on_train_troops_pressed() -> void:
	_toggle_panel("trainTroops/mainPanel")

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

func perform_work(worker) -> void:
	await get_tree().create_timer(10).timeout
	print("Build Complete")
	remove_material_override(self)
	built = true
	worker.task_complete()

func find_nearest_sibilyan() -> Node:
	# First, check if we have stored Sibilyans in any Kubo
	for kubo in Global.all_kubos:
		if kubo.stored_sibilyans.size() > 0:
			var sib = kubo.stored_sibilyans.pop_front()  # Take the first stored Sibilyan
			get_tree().get_root().get_node("Root/Base/Entities").add_child(sib)  # Add to the scene
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
