extends Node3D

var tree_scene = load("res://Scene/buildings/tree.tscn")

func _ready():
	generate_trees()

func generate_trees():
	if tree_scene == null:
		print("No Tree Scecne")
		return
		
	for i in range(20):
		var random_x = randi_range(-50,50)
		var random_z = randi_range(-50,50)
		var pos = Vector3(random_x,0,random_z)
		
		var tree_inst = tree_scene.instantiate()
		
		var children = tree_inst.get_children()
		
		var selected_child = children[randi()%4]
		
		selected_child.visible = true
		tree_inst.global_transform.origin = pos
		
		add_child(tree_inst)
		#var area = tree_inst.get_node("Area3D")
		#if area == null:
			#print("area not found")
			#return
		#area.monitoring = true
		#area.connect("input_event", Callable(self, "_on_area_3d_input_event"))
		#print("Tree generated at position:", pos)
	#pass
#func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			#print("test")
