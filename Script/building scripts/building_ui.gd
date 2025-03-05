extends Control

var active_panel: Panel = null
var button_clicked = false
func _ready():
	# Connect all buttons inside buildings to toggle their respective panels
	for building in get_children():
		for button in building.get_children():
			if button is TextureButton:
				button.pressed.connect(_on_button_pressed.bind(button))

func _on_button_pressed(button: TextureButton):
	button_clicked = !button_clicked
	var panel = button.get_child(0) if button.get_child_count() > 0 else null
	if panel and panel is Panel:  # Ensure it's a Panel node
		if active_panel and active_panel != panel:
			active_panel.visible = false  # Hide previous panel
		
		panel.visible = !panel.visible  # Toggle new panel visibility
		active_panel = panel if panel.visible else null

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var clicked_inside_ui = false

		# Check if mouse click is inside an active panel
		if active_panel and active_panel.visible:
			var rect = active_panel.get_global_rect()
			if rect.has_point(mouse_pos):
				clicked_inside_ui = true

		# Hide UI if clicked outside any active panel
		if not clicked_inside_ui:
			button_clicked = false
			if active_panel:
				active_panel.visible = false
				active_panel = null
			else:
				self.visible = false  # Hide the whole UI
