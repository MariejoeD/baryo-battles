extends Building
@onready var level_label = %level

var active_panel
var base_grow_duration = 120
var multiplier = .08
var grow_duration = base_grow_duration * pow(multiplier, level-1)
var is_harvestable:bool = false
var initial_pos
var grow_start_time := 0.0
var duration = 10
func get_save_data() -> Dictionary:
	var data = super.get_save_data()
	data["is_harvestable"] = is_harvestable
	data["y_position"] = $tanim.position.y
	data["duration"] = grow_duration
	data["remaining_grow_time"] = get_remaining_grow_time()
	data["grow_start_time"] = grow_start_time
	return data
	
func load_from_data(data: Dictionary) -> void:
	super.load_from_data(data)

	is_harvestable = data.get("is_harvestable", false)
	grow_duration = data.get("duration", 600)
	$tanim.position.y = data.get("y_position", $tanim.position.y)
	grow_start_time = data.get("grow_start_time", 0.0)

	if not is_harvestable:
		var remaining = data.get("remaining_grow_time", 0.0)
		if remaining > 0.0:
			await self.ready
			grow(remaining)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = $tanim.position
	
	pass # Replace with function body.


#Still need to put leveling system
#still need harvest system


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not $UI.visible:
			$UI.visible = true  # Only open UI, don't toggle it off
			$"Selection Box".visible = true
		
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var button_clicked = false
		var panel_clicked = false

			# Check if clicking a button
		for button in $UI/Tanim.get_children():
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
			$"Selection Box".visible = false
			if active_panel:
				active_panel.hide()
				active_panel = null
			


func _on_view_information_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = $UI/Tanim/viewInformation/InformationPanel
	active_panel.show()
	
	pass # Replace with function body.


func _on_upgrade_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = $UI/Tanim/upgrade/upgradePanel
	active_panel.show()
	pass # Replace with function body.


func grow(duration: float = -1.0):
	if duration < 0.0:
		duration = grow_duration
	grow_start_time = Global.total_game_time
	var tween = get_tree().create_tween()
	$tanim.position = initial_pos
	tween.tween_property($tanim, "position:y", -0.001, duration)
	tween.finished.connect(make_harvestable)

func get_remaining_grow_time() -> float:
	var elapsed = Global.total_game_time - grow_start_time
	return max(0.0, grow_duration - elapsed)
	
func make_harvestable():
	is_harvestable = true
	$UI/Tanim/Harvest.texture_normal = load("res://assets/button/ready_to_harvest.png") # Update texture
	print("Ready to harvest!")



func harvest() -> void:
	if is_harvestable:
		is_harvestable = false  # Disable harvesting while growing
	#	find nearest sibilyan
		var sibilyan = await find_nearest_sibilyan()
		if sibilyan == null:
			return
	#	add work to it
		if Global.get_food_cap() == Global.food_qty or Global.get_food_cap() == 0:
			return
		sibilyan.add_work(self)
	pass
	
func build():
	var sibilyan = await find_nearest_sibilyan()
	if sibilyan == null:
		return
	sibilyan.add_work(self)
	pass
func on_placed():
	super.on_placed()
	add_to_group("Buildings")
	Buildings.buildings["TanimBtn"] -= 1
func instant_build():
	built = true

	if get_tree() and get_tree().current_scene and get_tree().current_scene.has_node("tutorial"):
		var tutorial_node = get_tree().current_scene.get_node("tutorial")
		if is_instance_valid(tutorial_node):
			tutorial_node.step_6.emit()
	else:
		print("Tutorial node is no longer valid, skipping signal emission.")
	pass


var start_time := 0.0

func get_remaining_time():
	return max(0.0,duration - (Global.total_game_time - start_time))
	
func perform_work(worker, duration:= -1):
	if duration < 0.0:
		duration = self.duration
	if built:
		start_time = Global.total_game_time
		await get_tree().create_timer(duration).timeout
		$UI/Tanim/Harvest.texture_normal = load("res://assets/button/harvest.png")
		print("Harvest Complete")
		Global.food_qty += randi_range(30,40)
		if Global.get_food_cap() < Global.food_qty:
			Global.food_qty = Global.get_food_cap()
		#Change  Indicator
		grow(grow_duration)
		#gray
		worker.task_complete()
	else:
		start_time = Global.total_game_time
		await get_tree().create_timer(duration).timeout
		print("Build Complete")
		#Change  Indicator
		remove_material_override(self)
		instant_build()
		grow(grow_duration)
		worker.task_complete()




func remove_material_override(mesh_instance) -> void:
	for i in range(mesh_instance.mesh.get_surface_count()):
		mesh_instance.set_surface_override_material(i, null)
func _on_upgrade_button_pressed() -> void:
	if !DevMode.is_dev_mode_enabled(DevMode.insta_build_dev_mode):
		super.apply_material_override()
		built = false
		await build()
	if Npc.TH_level <= level:
		return

	level += 1
	level_label.text = "Level: " + str(level)
