extends Node3D

@export var required_cp: int = 100
@export var enemies: Array[PackedScene]
@export var preferred_enemies: Array[PackedScene]
@export var base_enemy_count: int = 5
@export var min_enemies: int = 3
@export var max_enemies: int = 10
@export var troops: Dictionary
@export var Objects: Array[Node]

@onready var UI = $"../UI"
@onready var container = UI.get_node("allyPanel/allyContainer")
@onready var camera = $"../SubViewportContainer/SubViewport/Camera3D"
@onready var player_cp = 0

var in_area = false

func _ready() -> void:
	create_area_and_collision()
	player_cp = calculate_player_total_cp()
	var enemies = select_enemies_to_spawn()
	spawn_enemy(enemies)

func _input(event: InputEvent) -> void:
	if get_selected_troop() != "":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var target_pos = get_mouse_floor_position()
			if target_pos == Vector3.ZERO or target_pos == Vector3.INF:
				return
			spawn_troop(target_pos)

func get_mouse_floor_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		return result.position
	return Vector3.INF

func spawn_troop(target_position: Vector3):
	var selected_troop = get_selected_troop()
	if selected_troop == "":
		return

	var troop_count = UI.troop_data[selected_troop][0]
	if troop_count <= 0:
		return

	var Troop_Scene = load(troops[selected_troop])
	print("Troop scene for selected troop: ", Troop_Scene)

	if not Troop_Scene:
		return

	var temp_instance = Troop_Scene.instantiate()
	
	var collision_shape = temp_instance.get_node_or_null("CollisionShape3D")
	if not collision_shape:
		temp_instance.queue_free()
		return

	if not await is_position_valid(target_position, collision_shape):
		temp_instance.queue_free()
		return

	UI.troop_data[selected_troop][0] -= 1
	UI.update_troop_count_label(container.get_node(selected_troop), UI.troop_data[selected_troop][0])
	temp_instance.position = target_position
	#temp_instance.scale *= 1.5
	add_child(temp_instance)

func get_selected_troop() -> String:
	for troop_name in UI.troop_data.keys():
		if UI.troop_data[troop_name][1]:
			return troop_name
	return ""

func is_position_valid(position: Vector3, collision_shape: CollisionShape3D) -> bool:
	var temp_area = Area3D.new()
	var temp_col = CollisionShape3D.new()
	temp_col.shape = collision_shape.shape
	temp_area.add_child(temp_col)
	temp_area.position = position
	add_child(temp_area)

	await get_tree().physics_frame

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = temp_col.shape
	query.transform.origin = position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.set_collision_mask(1)

	var results = space_state.intersect_shape(query)
	temp_area.queue_free()

	var valid = true
	for result in results:
		if result.collider is GridMap:
			continue
		if result.collider == temp_area:
			continue
		valid = false

	return valid
	
func create_area_and_collision():
	for group in Objects:
		for child in group.get_children():
			var mesh_instances: Array[MeshInstance3D] = []
			if child is MeshInstance3D:
				mesh_instances.append(child)
			else:
				for sub_child in child.get_children():
					if sub_child is MeshInstance3D:
						mesh_instances.append(sub_child)

			for mesh_inst in mesh_instances:
				var aabb = mesh_inst.get_aabb()
				if aabb.size == Vector3.ZERO:
					continue

				var area = Area3D.new()
				var collision = CollisionShape3D.new()
				var box = BoxShape3D.new()

				box.extents = aabb.size / 2
				collision.shape = box
				area.add_child(collision)
				collision.owner = mesh_inst.owner
				area.owner = mesh_inst.owner
				mesh_inst.add_child(area)

func calculate_player_total_cp():
	var total_cp = 0
	for troop_name in UI.troop_data.keys():
		if troop_name in troops:
			var troop_scene = load(troops[troop_name])
			var troop_instance = troop_scene.instantiate()

			if troop_instance.has_node("Stats"):
				total_cp += UI.troop_data[troop_name][0] * troop_instance.get_node("Stats").calculate_cp()

			troop_instance.queue_free()

	return total_cp

func calculate_enemy_count():
	if player_cp == 0:
		return max_enemies
	
	var enemy_count = clampi(
		base_enemy_count + ((required_cp - player_cp) / required_cp) * base_enemy_count,
		min_enemies,
		max_enemies
	)

	return int(enemy_count)

func pick_weighted_enemy(preferred_enemies: Array, remaining_enemies: Array) -> PackedScene:
	var all_enemies = []
	var weights = []

	for enemy in preferred_enemies:
		all_enemies.append(enemy)
		weights.append(2)

	for enemy in remaining_enemies:
		all_enemies.append(enemy)
		weights.append(1)

	var total_weight = sum_array(weights)
	var rand = randf_range(0, total_weight)

	var cumulative_weight = 0
	for i in range(all_enemies.size()):
		cumulative_weight += weights[i]
		if rand < cumulative_weight:
			return all_enemies[i]

	return all_enemies[0]

func select_enemies_to_spawn():
	var enemy_count = calculate_enemy_count()
	var target_cp = required_cp
	if player_cp < required_cp * 0.8:
		target_cp = required_cp * 1.5
	elif player_cp > required_cp * 1.2:
		target_cp = required_cp * 0.75

	var remaining_enemies = enemies.duplicate()
	var selected_enemies = []
	var total_cp = 0
	var selected_enemy_types = {}

	for enemy_scene in enemies:
		if not selected_enemy_types.has(enemy_scene):
			var temp_enemy = enemy_scene.instantiate()
			var stats_node = temp_enemy.get_node_or_null("Stats")
			if stats_node:
				var enemy_cp = stats_node.calculate_cp()
				total_cp += enemy_cp
				selected_enemies.append(temp_enemy)
				selected_enemy_types[enemy_scene] = true

	while selected_enemies.size() < enemy_count:
		var next_enemy_scene = pick_weighted_enemy(preferred_enemies, remaining_enemies)

		var next_enemy = next_enemy_scene.instantiate()
		var stats_node = next_enemy.get_node_or_null("Stats")
		if stats_node:
			var enemy_cp = stats_node.calculate_cp()
			total_cp += enemy_cp
			selected_enemies.append(next_enemy)

		if total_cp >= target_cp:
			break

	return selected_enemies

func spawn_enemy(enemies):
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var found_pos = false
			for i in range(max_enemies * 5):
				var random_position = get_random_position()
				var collision_shape = enemy.get_node_or_null("CollisionShape3D")
				if collision_shape and await is_position_valid(random_position, collision_shape):
					enemy.position = random_position
					add_child(enemy)
					found_pos = true
					break

			if not found_pos:
				print("[ERROR] No valid position found for enemy!")

func get_random_position() -> Vector3:
	var x = randf_range(-50, 50)
	var y = 0
	var z = randf_range(-50, 50)
	return Vector3(x, y, z)

func sum_array(arr: Array) -> float:
	var total = 0.0
	for value in arr:
		total += value
	return total
