extends Building

var inday_scene = load("res://Scene/Characters/super_inday.tscn")
var active_panel
var start_time := 0.0
var inday_instance
var duration = 10
var troops: Array = []

@onready var building_name = $UI.get_child(0)
func get_save_data() -> Dictionary:
	var data = super.get_save_data()
	
	return data
func _ready() -> void:
		%feedButton.pressed.connect(feed_revive)
		self.get_child(0).input_event.connect(_on_area_3d_input_event)
		building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
func feed_revive():
	if int(%viewInformation.find_child("foodAmount").text) > Global.food_qty:
		show_warning_label("Not Enough Food")
		return
	instant_scene()
	%ProgressBar.max_value = inday_instance.find_child("Stats").get_scaled_hp() 
	%ProgressBar.value = inday_instance.find_child("Stats").current_hp
	Global.food_qty -= int(%viewInformation.find_child("foodAmount").text)
func _on_view_information_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = building_name.get_node_or_null("viewInformation/InformationPanel")
	active_panel.show()
	if is_instance_valid(inday_instance):
		%feedButton.text = "FEED"
		%ProgressBar.max_value = inday_instance.find_child("Stats").get_scaled_hp() 
		%ProgressBar.value = inday_instance.find_child("Stats").current_hp
	else:
		%feedButton.text = "REVIVE"
		%ProgressBar.max_value = 1
		%ProgressBar.value = 0
	
	pass # Replace with function body.

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
			
func build():
	var sibilyan = await find_nearest_sibilyan()
	if sibilyan == null:
		return
	sibilyan.add_work(self)
	pass

func on_placed():
	super.on_placed()
	add_to_group("Buildings")
	Buildings.buildings["SuperIndayBtn"] -= 1
func instant_build():
	built = true
	if self not in Global.all_kampo:
		Global.all_kampo.append(self)
	# 🪖 Spawn the troop when construction is complete
	if inday_scene:
		instant_scene()
func instant_scene():
	inday_instance = inday_scene.instantiate()
	find_parent("HomeBase").find_child("Entities").add_child(inday_instance)
	print(inday_instance.get_parent())
	inday_instance.global_transform.origin = self.global_transform.origin
	inday_instance.global_transform.origin.z +=3
	# Duplicate the shape to avoid modifying shared resource
	var collision_shape = inday_instance.get_node("Detection/CollisionShape3D")
	var shape = collision_shape.shape.duplicate()
	collision_shape.shape = shape
	if not Global.kampo_troops.has(self.name):
		Global.kampo_troops[self.name] = {}

	if not Global.kampo_troops[self.name].has("super_inday"):
		Global.kampo_troops[self.name]["super_inday"] = 1
	# Only resize if not resized already
	if not collision_shape.has_meta("resized"):
		collision_shape.shape.radius *= 0.2
		collision_shape.set_meta("resized", true)
	troops.append({"name": "super_inday", "duration": 10, "scene": "res://Scene/Characters/super_inday.tscn"})
	
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
