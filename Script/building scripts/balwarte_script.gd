extends Building
@onready var level_label = %level
var current_enemy :CharacterBody3D = null
var enemies_in_range: Array[CharacterBody3D]
var active_panel
@onready var building_name = $UI.get_child(0)
var attack_rate: float = 1.00
@export var projectile_type: PackedScene
var attack_cooldown = Timer.new()
func _ready() -> void:
	attack_cooldown.wait_time = 1/attack_rate
	attack_cooldown.one_shot = true
	add_child(attack_cooldown)
	
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	
	

	pass
func _process(delta: float) -> void:
	if enemies_in_range.size() > 0:
		_maybe_fire()
	

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

func build():
	var sibilyan = await find_nearest_sibilyan()
	if sibilyan == null:
		return
	sibilyan.add_work(self)
	pass
func on_placed():
	super.on_placed()
	add_to_group("Buildings")
	Buildings.buildings["BalwarteBtn"] -= 1
func instant_build():
	built = true
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
		
func _on_upgrade_button_pressed() -> void:
	if !DevMode.is_dev_mode_enabled(DevMode.insta_build_dev_mode):
		super.apply_material_override()
		await build()
	if Npc.TH_level <= level:
		return
	%CollisionShape3D.shape.radius *= 1.5
	level += 1
	level_label.text = "Level: " + str(level)


func _on_attack_range_body_entered(body: CharacterBody3D) -> void:
	if !body.is_in_group("Enemy"):
		return
	if current_enemy == null:
		current_enemy = body
	enemies_in_range.append(body)
	#print(current_enemy)
	pass # Replace with function body.

func _maybe_fire():
	if attack_cooldown.time_left == 0:
		#print("Fire!!")
		var projectile:Projectile = projectile_type.instantiate()
		projectile.starting_position = $Projectile_Spawn.global_position
		projectile.target = current_enemy
		add_child(projectile)
		attack_cooldown.start()
func _on_attack_range_body_exited(body: CharacterBody3D) -> void:
	enemies_in_range.erase(body)
	pass # Replace with function body.
