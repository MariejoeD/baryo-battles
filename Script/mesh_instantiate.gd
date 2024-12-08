extends Node3D
@onready var parent = get_parent()
var grid_range
var other_map
var new_arr_pos
var old_arr_pos
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_range = parent.grid_range
	other_map = parent.other_map
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	new_arr_pos = other_map.get_used_cells
	if old_arr_pos != new_arr_pos:
		for
	
	pass
