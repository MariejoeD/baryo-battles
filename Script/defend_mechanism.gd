extends Node

var TH_level: int
var unlocked_defenders = []
var enemies = []
var available = []

func _ready() -> void:
	SignalManager.night_time.connect(enemy_attack_check)
	


func enemy_attack_check():
	await get_tree().create_timer(1).timeout
	TH_level = Npc.TH_level
	#print("\n[enemy_attack_check] --- BEGIN NIGHT CHECK ---")
	
	var seconds_passed = Global.total_game_time
	var time_score = get_time_points(seconds_passed)
	#print("[Time] Seconds passed:", seconds_passed, " => Time Score:", time_score)
	
	var food = Global.food_qty
	var food_cap = Global.get_food_cap()
	var wood = Global.wood_qty
	var wood_cap = Global.get_wood_cap()
	var stone = Global.stone_qty
	var stone_cap = Global.get_stone_cap()
	var wealth_score = calculate_wealth_score(food, food_cap, wood, wood_cap, stone, stone_cap)
	#print("[Wealth] Score:", wealth_score)

	var npc_score = get_npc_score()
	#print("[NPC] Total NPC Score:", npc_score)

	var total_score = (time_score * 0.4) + (wealth_score * 0.3) + (npc_score * 0.3)
	#print("[TOTAL SCORE] Combined Score:", total_score)

	var chance = randf_range(0.0, 100.0)
	#print("[Chance] Roll:", chance, " vs Threshold:", total_score)
	
	#total_score = 100
	if chance < total_score:
		#print("⚠️ Enemy Attack Triggered!")
		var defender_score = get_defender_score()
		var raid_strength = determine_enemy_total_cp(wealth_score, defender_score)
		var selected = select_enemies_to_spawn(raid_strength)
		#print("[ENEMIES SELECTED]", selected)
		available = get_unassigned_troop()
		
		#$"Defend Control".show_defense_warning()
		#spawn_enemy(selected)
	else:
		#print("🌙 Quiet night. No attack.")
	#print("[enemy_attack_check] --- END ---\n")
		pass

func get_time_points(seconds_passed: float) -> float:
	var minutes = seconds_passed / 60.0
	var score = clamp(pow(minutes, 0.8) * 2.0, 0, 100)
	#print("[get_time_points] Minutes:", minutes, " => Score:", score)
	return score

func calculate_wealth_score(
	food: int, food_cap: int,
	wood: int, wood_cap: int,
	stone: int, stone_cap: int
) -> float:
	var food_ratio = float(food) / food_cap if food_cap != 0 else 0
	var wood_ratio = float(wood) / wood_cap if wood_cap != 0 else 0
	var stone_ratio = float(stone) / stone_cap if stone_cap != 0 else 0

	var raw_score = food_ratio * 1.0 + wood_ratio * 1.5 + stone_ratio * 2.0
	var normalized = raw_score / 4.5
	var final_score = clamp(normalized * 100, 0, 100)

	#print("[calculate_wealth_score]")
	#print(" Food:", food, "/", food_cap, "=>", food_ratio)
	#print(" Wood:", wood, "/", wood_cap, "=>", wood_ratio)
	#print(" Stone:", stone, "/", stone_cap, "=>", stone_ratio)
	#print(" Raw Score:", raw_score, " Normalized:", normalized, " => Final Score:", final_score)

	return final_score

func get_npc_score() -> float:
	var defender_score = get_defender_score()
	var worker_score = get_worker_score()
	var total = (defender_score * 0.7) + (worker_score * 0.3)
	#print("[get_npc_score] Defenders:", defender_score, " Workers:", worker_score, " => NPC Score:", total)
	return total
	
func get_worker_score():
	if Global.get_max_civilians() == 0:
		#print("[get_worker_score] Max civilians is 0!")
		return 0.0
	var ratio = float(Global.get_current_civilian_count()) / Global.get_max_civilians()
	var result = clamp(ratio * 100, 0, 100)
	#print("[get_worker_score] Civilians:", Global.get_current_civilian_count(), "/", Global.get_max_civilians(), "=>", result)
	return result

func get_defender_score() -> float:
	var current_cp = get_current_cp()
	var max_cp = estimate_max_cp()
	if max_cp == 0:
		#print("[get_defender_score] Max CP is 0!")
		return 0.0
	var score = clamp((float(current_cp) / max_cp) * 100, 0, 100)
	#print("[get_defender_score] Current CP:", current_cp, " Max CP:", max_cp, " => Score:", score)
	return score

func get_current_cp(with_space:= true) -> int:
	var total_cp = 0
	for entities in $"../Base/Entities".get_children():
		if entities.has_node("Stats"):
			var cp = entities.find_child("Stats").calculate_cp()
			var space = entities.find_child("Stats").space_cost if with_space else 1
			total_cp += cp * space
	#print("[get_current_cp] with_space =", with_space, " => Total CP:", total_cp)
	return total_cp
	
func estimate_max_cp() -> int:
	var remaining_space = 0
	Global.all_kampo = Global.all_kampo.filter(func(k): return is_instance_valid(k))
	for kampo in Global.all_kampo:
		if is_instance_valid(kampo):
			remaining_space += kampo.spaces
	
	unlocked_defenders.sort_custom(func(a, b): return (b.cp / b.space) - (a.cp / a.space))
	
	var estimated_cp = 0
	for unit in unlocked_defenders:
		var count = remaining_space / unit.space
		estimated_cp += int(count) * unit.cp
		remaining_space -= int(count) * unit.space
		if remaining_space <= 0:
			break
	#print("[estimate_max_cp] Estimated CP:", estimated_cp)
	return estimated_cp

func determine_enemy_total_cp(wealth, defenders):
	var base_cp = get_current_cp(false)
	var ratio = defenders / wealth if wealth != 0 else 1.0
	var raid_strength = base_cp

	if ratio < 1:
		# Base aggression factor
		var aggression = 1.0 + (1.0 - ratio)

		# 🧱 Cap aggression early to prevent wipeouts
		var max_aggression = 1.25 if TH_level <= 2 else 2.0
		aggression = clamp(aggression, 1.0, max_aggression)

		raid_strength *= aggression

		#print("[determine_enemy_total_cp] AGGRESSION Applied")
		#print(" Base CP:", base_cp)
		#print(" Defenders:", defenders, " Wealth:", wealth, " Ratio:", ratio)
		#print(" Aggression Multiplier:", aggression)
		#print(" => Final Raid Strength:", raid_strength)

		# 🛡️ Optional: Safety net for early-game players with really low CP
		if base_cp < estimate_max_cp() * 0.2 and TH_level <= 2:
			#print("⚠️ [Early Game Safety Net Triggered] Raid Strength Reduced!")
			raid_strength *= 0.75  # Give them a slim chance to survive

	else:
		#print("[determine_enemy_total_cp] NO Aggression (Balanced or Over-defended)")
		#print(" Base CP:", base_cp)
		#print(" => Final Raid Strength:", raid_strength)
		pass

	return raid_strength


func select_enemies_to_spawn(target_cp):
	var selected_enemies = []
	var total_cp = 0
	#print("[select_enemies_to_spawn] Target CP:", target_cp)
	if target_cp == 0  and not TH_level == 0:
		var random_enemy = enemies.pick_random()
		var temp_inst = random_enemy.instantiate()
		selected_enemies.append(temp_inst)
		
	var attempts = 0
	while total_cp < target_cp and attempts < 100:
		attempts += 1
		var random_enemy = enemies.pick_random()
		var temp_inst = random_enemy.instantiate()
		var stats = temp_inst.find_child("Stats")
		var cp = stats.calculate_cp()

		if total_cp + cp > target_cp:
			continue # Skip this and try another enemy

		total_cp += cp
		selected_enemies.append(temp_inst)
		#print(" +", cp, "=> Current Total CP:", total_cp)

	
	#print("[select_enemies_to_spawn] Final Total CP:", total_cp)
	return selected_enemies
	
func spawn_enemy(sel_enemies):
	var gridmap = $"../Base/AMap/Floor"  # Your GridMap node
	var entities_parent = $"../Base/Entities"
	var grid_range = floor(Global.grid_size / 2.0)  # Grid size range
	var used_cells = gridmap.get_used_cells()  # Get used cells from the GridMap

	# Step 1: Find the outer edges
	var edge_cells = []
	for cell in used_cells:
		# Check if it's on the edge (min/max x or z)
		if abs(cell.x) == grid_range or abs(cell.z) == grid_range:
			edge_cells.append(cell)

	if edge_cells.is_empty():
		#print("⚠️ No edge cells found!")
		return

	# Step 2: Spawn enemies at random edge cells
	for enemy in sel_enemies:
		var spawn_cell = edge_cells.pick_random()  # Pick a random edge cell
		var spawn_pos = gridmap.map_to_local(spawn_cell)  # Get the world position of the cell
		enemy.global_transform.origin = spawn_pos  # Set the enemy's position
		entities_parent.add_child(enemy)
		enemy.get_node("Detection/CollisionShape3D").shape.radius = 150  # Add the enemy to the scene
		#print("👹 Spawned enemy at:", spawn_cell, "=>", spawn_pos)

func _input(event: InputEvent) -> void:
	if get_selected_troop() != "":
		var mouse_pos = get_viewport().get_mouse_position()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not $UI.get_node("allyPanel").get_global_rect().has_point(mouse_pos):
			var target_pos = get_mouse_floor_position()
			if target_pos == Vector3.ZERO or target_pos == Vector3.INF:
				return
			station_selected_troop(target_pos)

func get_mouse_floor_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = $"../Base".get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		result.position.y = 0
		return result.position
	return Vector3.INF

func is_position_valid(position: Vector3, collision_shape: CollisionShape3D) -> bool:
	var temp_area = Area3D.new()
	var temp_col = CollisionShape3D.new()
	temp_col.shape = collision_shape.shape
	temp_area.add_child(temp_col)
	temp_area.position = position
	add_child(temp_area)

	await get_tree().physics_frame

	var space_state = $"../Base".get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = temp_col.shape
	query.transform.origin = position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.set_collision_mask(2)

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

func get_unassigned_troop():
	var entities = get_tree().current_scene.find_child("Entities")
	var available = []
	for entity in entities.get_children():
		if entity.is_in_group("Good") and entity.has_node("Stats"):
			available.append(entity)
	return available

func get_selected_troop() -> String:
	for troop_name in $UI.troop_data.keys():
		if $UI.troop_data[troop_name][1]:
			return troop_name
	return ""
func station_selected_troop(target_pos: Vector3):
	var selected_troop = get_selected_troop()
	#print(available)
	for troop in available:
		var name = troop.get_node("Stats").Name
		if name == selected_troop:
			var collision_shape = troop.get_node_or_null("CollisionShape3D")
			if not await is_position_valid(target_pos, collision_shape):
				return
			troop.position = target_pos
			available.erase(troop)
			$UI.troop_data[selected_troop][0] -= 1
