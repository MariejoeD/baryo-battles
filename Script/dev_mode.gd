extends Node

signal dev_mode_changed

enum DevState {
	FOLLOW_GLOBAL,
	FORCE_ON,
	FORCE_OFF
}

@export var dev_mode: bool = false:
	set(value):
		if dev_mode == value:
			return
		dev_mode = value
		dev_mode_changed.emit()

# This will allow you to change the mode at runtime from the editor
@export var map_dev_mode: DevState = DevState.FOLLOW_GLOBAL:
	set(value):
		if map_dev_mode == value:
			return
		map_dev_mode = value
		dev_mode_changed.emit()
@export var insta_build_dev_mode: DevState = DevState.FOLLOW_GLOBAL:
	set(value):
		if insta_build_dev_mode == value:
			return
		insta_build_dev_mode = value
		dev_mode_changed.emit()
@export var save_path_dev_mode: DevState = DevState.FOLLOW_GLOBAL:
	set(value):
		if save_path_dev_mode == value:
			return
		save_path_dev_mode = value
		dev_mode_changed.emit()

func _ready() -> void:
	if dev_mode:
		Global.save_path = "res://save.tres"
	else:
		Global.save_path = "user://save.tres"

func is_dev_mode_enabled(mode_setting: int) -> bool:
	match mode_setting:
		DevState.FORCE_ON:
			return true
		DevState.FORCE_OFF:
			return false
		DevState.FOLLOW_GLOBAL:
			return dev_mode
		_:
			return false
