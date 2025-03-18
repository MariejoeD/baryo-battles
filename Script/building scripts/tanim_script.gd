extends MeshInstance3D


var active_panel
var plot_level = 1  # Example plot level
var base_grow_duration = 5
var multiplier = .08
var duration = base_grow_duration * pow(multiplier, plot_level-1)
var is_harvestable:bool = false
var initial_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = $tanim.position
	grow(duration)  # Grow to the computed height over 3 seconds
	pass # Replace with function body.


#Still need to put leveling system
#still need harvest system


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not $UI.visible:
			$UI.visible = true  # Only open UI, don't toggle it off
		
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




func grow(duration: float = 5.0):
	#indicator.hide()  # Hide indicator during growth
	
	var tween = get_tree().create_tween()
	$tanim.position = initial_pos  # Reset position before growing again
	tween.tween_property($tanim, "position:y", -0.001, duration)
	
	tween.finished.connect(make_harvestable)  # Enable harvesting when done
	
func make_harvestable():
	is_harvestable = true
	#indicator.show()  # Show indicator when ready
	print("Ready to harvest!")
	pass


func harvest() -> void:
	if is_harvestable:
		is_harvestable = false  # Disable harvesting while growing
	#	find nearest sibilyan
		var sibilyan = find_nearest_sibilyan()
	#	add work to it
		sibilyan.add_work(self)
	pass

func perform_work(worker):
	await get_tree().create_timer(5).timeout
	print("Harvest Complete")
	Global.food_qty += 10
	grow(duration)
	#gray
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
