extends Building
@onready var level_label = %level

var active_panel
@onready var building_name = $UI.get_child(0)
var wood_cap: int:
	get:
		return 500 * (1 + (level-1)*.5)
var stone_cap: int:
	get:
		return 500 * (1 + (level-1)*.5)
var food_cap: int:
	get:
		return 500 * (1 + (level-1)*.5)
@onready var wood_amount: Label = %woodAmount
@onready var stone_amount: Label = %stoneAmount
@onready var food_amount: Label = %foodAmount



	
func on_placed():
	super.on_placed()
	
	add_to_group("Buildings")
	Buildings.reset()
	Buildings.buildings["MalacadabraBtn"] = 0
	change_building_count()
	
	
func _ready() -> void:
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	building_name.find_child("upgradeButton").pressed.connect(_upgrade)

	pass
func instant_build():
	built = true
	if get_tree() and get_tree().current_scene and get_tree().current_scene.has_node("tutorial"):
		var tutorial_node = get_tree().current_scene.get_node("tutorial")
		if is_instance_valid(tutorial_node):
			tutorial_node.step_1.emit()
	else:
		print("Tutorial node is no longer valid, skipping signal emission.")
	Global.all_bodega.append(self)
	Global.all_imbakan.append(self)
	Npc.TH_level = level
	pass

func _on_area_3d_input_event(camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
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
	wood_amount.text = str(wood_cap)
	stone_amount.text = str(stone_cap)
	food_amount.text = str(food_cap)
	
	pass # Replace with function body.


func _on_upgrade_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null("upgrade/upgradePanel")
	active_panel.show()
	
	pass # Replace with function body.

func build():
	var sibilyan = await find_nearest_sibilyan()
	if sibilyan == null:
		return
	sibilyan.add_work(self)
	pass

var start_time := 0.0
var duration := 5
func get_remaining_time():
	return max(0.0,duration - (Global.total_game_time - start_time))
	
func perform_work(worker, duration:= -1):
	if duration < 0.0:
		duration = self.duration
	start_time = Global.total_game_time
	await get_tree().create_timer(duration).timeout
	print("Build Complete")
	#Change  Indicator
	remove_material_override(self)
	instant_build()
	worker.task_complete()
	pass



	
	
func remove_material_override(mesh_instance) -> void:
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, null)

func _upgrade():
	if !DevMode.is_dev_mode_enabled(DevMode.insta_build_dev_mode):
		super.apply_material_override()
		await build()
	#still need condition
	var defeated_count = 0
	for status in Npc.bosses.values():
		if status == true:
			defeated_count += 1
	if level <= defeated_count and level < 3:
		level += 1
		change_building_count()
		SignalManager.TH_upgrade.emit()
	pass

func change_building_count():
	if level == 1:
		Buildings.buildings["KampoBtn"] += 1
	Buildings.buildings["BodegaBtn"] += 1
	Buildings.buildings["SandatahangLakasBtn"] += 1
	Buildings.buildings["KuboBtn"] += 1
	Buildings.buildings["TanimBtn"] += 10
	Buildings.buildings["ImbakanBtn"] += 1
	
	if level >= 2:
		Buildings.buildings["KawaBtn"] += 1
		Buildings.buildings["EstakadaBtn"] += 10
	
	if level >= 3:
		Buildings.buildings["BalwarteBtn"] += 2
		Buildings.buildings["KwitisBtn"] += 2
		
func _on_upgrade_button_pressed() -> void:
	if !DevMode.is_dev_mode_enabled(DevMode.insta_build_dev_mode):
		super.apply_material_override()
		await build()
	if Npc.TH_level <= level:
		return

	level += 1
	level_label.text = "Level: " + str(level)
