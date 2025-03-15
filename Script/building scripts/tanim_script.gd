extends MeshInstance3D

var button_clicked = false
var active_panel
var plot_level = 1  # Example plot level
var base_grow_duration = 5
var multiplier = .08
var duration = base_grow_duration * pow(multiplier, plot_level-1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grow(duration)  # Grow to the computed height over 3 seconds
	pass # Replace with function body.


#Still need to put leveling system
#still need harvest system


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if $UI.visible:
			$UI.hide()
		$UI.visible = true
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and button_clicked == false:
		if $UI.visible:
			var mouse_pos = get_viewport().get_mouse_position()
			for button in $UI/Tanim.get_children():
				if button.get_global_rect().has_point(mouse_pos):
					button_clicked = true
					
					return 
			if button_clicked == false:
				$UI.visible = false
		pass
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if $UI.visible:
			$UI.visible = false
			button_clicked = false
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
	var tween = get_tree().create_tween()
	tween.tween_property($tanim, "position:y", -0.001, duration)
