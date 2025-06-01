extends Control
@onready var age: LineEdit = $Panel/age
@onready var button: Button = $Panel/Button
@onready var check_box: CheckBox = $Panel/CheckBox
@onready var exit_button: Button = $under13/exitButton
@onready var under_13: Panel = $under13
@onready var panel: Panel = $Panel
@onready var pan: Panel = $Panel/Pan
@onready var label: Label = $Panel/Pan/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(proceed)
	exit_button.pressed.connect(exit)
	pan.visibility_changed.connect(pan_close)
	pass # Replace with function body.
func proceed():
	var age_value := age.text.strip_edges()
	if age_value == "" or not age_value.is_valid_int():
		label.text = "Invalid age input"
		pan.show()
		
		return
	
	if not check_box.button_pressed:
		label.text = "Please Click The Check Box If You Agree with the terms & privacy to proceed"
		pan.show()
		return
	if int(age_value) < 13:
		under_13.show()
		return
	var agree = Agreement.new()
	agree.agreement = true
	ResourceSaver.save(agree, "user://agreement.tres")
	get_tree().change_scene_to_file("res://Scene/Story/Prologue.tscn")
	
func exit():
	get_tree().quit()
	pass
func pan_close():
	await get_tree().create_timer(3).timeout
	pan.hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
