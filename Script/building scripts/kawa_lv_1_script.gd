extends Building
@onready var level_label = %level

var active_panel
var stored_spell : Dictionary = {}
const BREW_TIME := 600.0 # 10 minutes in seconds
var to_brew: Array = [] # Queue of spells waiting
var brewing_spells: Array = [] # Currently brewing (max 2)
var max_concurrent_brews := 2
@export var spell_pack: PackedScene
var spell_instance
@onready var building_name = $UI.get_child(0)
@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var brew_and_manage_spells: TextureButton = %BrewAndManageSpells
@onready var brew_display: HBoxContainer = $UI/Kawa/BrewAndManageSpells/Panel/brewedPanel/ScrollContainer/HBoxContainer


func get_save_data() -> Dictionary:
	return {"stored_spell": stored_spell}

func get_load_data(data: Dictionary):
	stored_spell = data.get("stored_spell",{})

func _ready() -> void:
	self.get_child(0).input_event.connect(_on_area_3d_input_event)
	building_name.get_node("viewInformation").pressed.connect(_on_view_information_pressed)
	building_name.get_node("upgrade").pressed.connect(_on_upgrade_pressed)
	brew_and_manage_spells.pressed.connect(_on_brew_pressed)
	for child in h_box_container.get_children():
		if child is TextureButton:
			child.pressed.connect(brew.bind(child))
	

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
	
func _on_brew_pressed() -> void:
	if active_panel:
		active_panel.hide()
	active_panel = brew_and_manage_spells.get_node_or_null("Panel")
	active_panel.show()
	pass # Replace with function body.


func brew(spellbtn):
	var food_amount = int(spellbtn.find_child("foodAmount").text)
	if food_amount > Global.food_qty:
		print("Not enough food.")
		return

	Global.food_qty -= food_amount
	spell_instance = spell_pack.instantiate()
	brew_display.add_child(spell_instance)
	spell_instance.texture_normal = spellbtn.texture_normal
	to_brew.append({"btn": spellbtn, "instance": spell_instance})
	check_brewing_slots()

func check_brewing_slots():
	while brewing_spells.size() < max_concurrent_brews and to_brew.size() > 0:
		var next = to_brew.pop_front()
		start_brewing(next["btn"], next["instance"])


func start_brewing(spellbtn, spell_instance):
	var timer = Timer.new()
	timer.wait_time = BREW_TIME
	timer.one_shot = true
	timer.timeout.connect(_on_brew_finished.bind(spellbtn, spell_instance, timer))
	add_child(timer)
	timer.start()

	var update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.one_shot = false
	update_timer.autostart = true
	update_timer.timeout.connect(_update_brew_time.bind(spell_instance, timer, update_timer))
	add_child(update_timer)

	brewing_spells.append({
		"spell": spellbtn,
		"instance": spell_instance,
		"timer": timer,
		"update_timer": update_timer
	})

	print("Started brewing:", spellbtn.name)

func _update_brew_time(spell_instance, brew_timer, update_timer):
	if not spell_instance.is_inside_tree():
		return

	var time_left = brew_timer.time_left
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	var label = spell_instance.find_child("timeLeft")

	if label:
		label.text = "%02d:%02d" % [minutes, seconds]

	if time_left <= 0:
		update_timer.stop()
		update_timer.queue_free()



func _on_brew_finished(spellbtn, timer):
	print("Finished brewing:", spellbtn.name)

	# Remove from brewing list
	for i in brewing_spells.size():
		if brewing_spells[i]["spell"] == spellbtn:
			brewing_spells.remove_at(i)
			break

	timer.queue_free()

	# Here you can increment inventory or stored spell count
	# stored_spell[spellbtn] = stored_spell.get(spellbtn, 0) + 1

	check_brewing_slots()


func build():
	var sibilyan = find_nearest_sibilyan()
	sibilyan.add_work(self)
	pass

func instant_build():
	built = true
	add_to_group("Buildings")
	Buildings.buildings["KawaBtn"] -= 1
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


func _on_view_brewed_spells_pressed():
	var brewed_spells = $UI/Kawa/BrewAndManageSpells.get_node_or_null("brewedSpells")
	var panel = $UI/Kawa/BrewAndManageSpells.get_node_or_null("Panel")
	
	if brewed_spells:
		brewed_spells.show()
	else:
		print("❌ brewedSpells panel not found")

	if panel:
		panel.hide()
