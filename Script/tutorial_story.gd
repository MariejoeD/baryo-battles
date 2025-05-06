extends Control

@onready var welcome: Label = $mainPanel/welcome
@onready var _1: Label = $"mainPanel/1"
@onready var _2: Label = $"mainPanel/2"
@onready var _3: Label = $"mainPanel/3"
@onready var _4: Label = $"mainPanel/4"
@onready var _5: Label = $"mainPanel/5"
@onready var _6: Label = $"mainPanel/6"
@onready var _7: Label = $"mainPanel/7"
@onready var _8: Label = $"mainPanel/8"
@onready var _9: Label = $"mainPanel/9"
@onready var _10: Label = $"mainPanel/10"
@onready var _11: Label = $"mainPanel/11"
@onready var _12: Label = $"mainPanel/12"
@onready var _13: Label = $"mainPanel/13"

signal step_1
signal step_2
signal step_3
signal step_4
signal step_5
signal step_6
signal step_7
signal step_8
signal step_9
signal step_10
signal step_11
signal step_12
signal step_13

var steps: Array[Label]
var current_index := -1

func _ready() -> void:
	steps = [_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13]
	await get_tree().create_timer(10).timeout
	welcome.hide()
	_1.show()
	current_index = 0

	# Connect each signal to its corresponding function
	step_1.connect(_on_step_1)
	step_2.connect(_on_step_2)
	step_3.connect(_on_step_3)
	step_4.connect(_on_step_4)
	step_5.connect(_on_step_5)
	step_6.connect(_on_step_6)
	step_7.connect(_on_step_7)
	step_8.connect(_on_step_8)
	step_9.connect(_on_step_9)
	step_10.connect(_on_step_10)
	step_11.connect(_on_step_11)
	step_12.connect(_on_step_12)
	step_13.connect(_on_step_13)

func _advance_to_step(step_number: int) -> void:
	print("Advance")
	if step_number < 1 or step_number > steps.size():
		return
	
	# Hide the current step (unless it's the last step)
	if current_index >= 0 and current_index < steps.size():
		steps[current_index].hide()
		
	# Show the next step
	if step_number <= steps.size():
		steps[step_number].show()
	
	# Update current step index
	current_index = step_number

	# At the last step, just hide it (no label displayed after)
	if current_index == steps.size():
		steps[current_index].hide()  # Hide the last step

# Function for each step
func _on_step_1(): _advance_to_step(1)
func _on_step_2(): _advance_to_step(2)
func _on_step_3(): _advance_to_step(3)
func _on_step_4(): _advance_to_step(4)
func _on_step_5(): _advance_to_step(5)
func _on_step_6(): _advance_to_step(6)
func _on_step_7(): _advance_to_step(7)
func _on_step_8(): _advance_to_step(8)
func _on_step_9(): _advance_to_step(9)
func _on_step_10(): _advance_to_step(10)
func _on_step_11(): _advance_to_step(11)
func _on_step_12(): _advance_to_step(12)
func _on_step_13(): _advance_to_step(13)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed:
		queue_free()
