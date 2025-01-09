@tool
extends GridMap
@export var test: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if test:
		clear_map()
	pass


func clear_map():
	for cell in get_used_cells():
		set_cell_item(cell, -1)
	update_gizmos()
	test = false
	pass
