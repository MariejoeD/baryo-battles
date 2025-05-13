extends Building

var inday_scene = load("res://Scene/Characters/super_inday.tscn")
func build():
	var sibilyan = await find_nearest_sibilyan()
	if sibilyan == null:
		return
	sibilyan.add_work(self)
	pass

func on_placed():
	super.on_placed()
	add_to_group("Buildings")
	Buildings.buildings["SuperIndayBtn"] -= 1
func instant_build():
	built = true
	# 🪖 Spawn the troop when construction is complete
	if inday_scene:
		var inday_instance = inday_scene.instantiate()
		get_tree().current_scene.find_child("Entities").add_child(inday_instance)
		inday_instance.global_transform.origin = self.global_transform.origin
		
		# Duplicate the shape to avoid modifying shared resource
		var collision_shape = inday_instance.get_node("Detection/CollisionShape3D")
		var shape = collision_shape.shape.duplicate()
		collision_shape.shape = shape

		# Only resize if not resized already
		if not collision_shape.has_meta("resized"):
			collision_shape.shape.radius *= 0.2
			collision_shape.set_meta("resized", true)
		pass
