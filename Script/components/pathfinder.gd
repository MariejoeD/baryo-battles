extends Node3D
var pathfinding
func _ready() -> void:
	pathfinding = get_tree().get_first_node_in_group("pathscript")
func findpaths(start:Vector3, end: Vector3):
	return pathfinding.find_path(start,end)
	
	
