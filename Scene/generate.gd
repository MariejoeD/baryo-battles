extends Node3D

var tree_scene = load("res://Scene/buildings/tree.tscn")

func _ready():
	generate_trees()

func generate_trees():
	if tree_scene == null:
		print("No Tree Scecne")
		return
		
	for i in range(10):
		var random_x = randi_range(-50,50)
		var random_z = randi_range(-50,50)
		var pos = Vector3(random_x,0,random_z)
		
		var tree_inst = tree_scene.instantiate()
		tree_inst.global_transform.origin = pos
		
		add_child(tree_inst)
		
		print("Tree generated at position:", pos)
	pass
