extends Node3D

@onready var gridmap = $"../GridMap"
@onready var cells = gridmap.get_used_cells()
@export var Create_path: bool
signal finished

func create_path_node():
	if Create_path:
		var temp_area = Area3D.new()
		var temp_collision = CollisionShape3D.new()
		var temp_box = BoxShape3D.new()
		temp_box.size = Vector3(2, 10, 2)
		temp_collision.shape = temp_box
		temp_area.add_child(temp_collision)
		temp_area.collision_mask = 1
		add_child(temp_area)

		# Process each cell
		for cell in cells:
			temp_area.global_transform.origin = gridmap.map_to_local(cell)
			await get_tree().physics_frame

			if not temp_area.has_overlapping_areas():
				var new_cell = Vector3i(cell.x, cell.y + 1, cell.z)
				gridmap.set_cell_item(new_cell, 1)

		# Clean up
		temp_area.queue_free()

		# Create a PackedScene and pack the gridmap into it
		var packed_scene = PackedScene.new()
		packed_scene.pack(gridmap)

		# Save the packed scene as a file to the specified path
		var save_path = "res://floor_1_gridmap.tscn"
		var result = ResourceSaver.save(packed_scene, save_path)

		if result == OK:
			print("Gridmap saved successfully to", save_path)
		else:
			print("Error saving gridmap!")

	emit_signal("finished")
