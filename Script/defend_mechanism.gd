extends Node

var TH_level: int
var unlocked_defenders = []
var enemies = []

func _ready() -> void:
	SignalManager.night_time.connect(enemy_attack_check)

func enemy_attack_check():
	await get_tree().create_timer(1).timeout

	# Gather all scores
	var seconds_passed = Global.total_game_time
	var time_score = get_time_points(seconds_passed)
	
	# Get wealth score
	var food = Global.food_qty
	var food_cap = Global.get_food_cap()
	var wood = Global.wood_qty
	var wood_cap = Global.get_wood_cap()
	var stone = Global.stone_qty
	var stone_cap = Global.get_stone_cap()
	var wealth_score = calculate_wealth_score(food, food_cap, wood, wood_cap, stone, stone_cap)

	# Get NPC (worker + defender) score
	var npc_score = get_npc_score()
	# Combine all scores with custom weights
	var total_score = (time_score * 0.4) + (wealth_score * 0.3) + (npc_score * 0.3)
	
	# Random roll to decide attack
	var chance = randf_range(0.0, 100.0)
	print("Enemy Attack Chance Roll: ", chance, " / Threshold: ", total_score)
	total_score = 100
	if chance < total_score:
		print("⚠️ Enemy Attack Triggered!")
		var raid_strength = determine_enemy_total_cp(wealth_score, get_defender_score())
		var selected = select_enemies_to_spawn(raid_strength)
		print(selected)
		
	else:
		print("🌙 Quiet night. No attack.")

func get_time_points(seconds_passed: float) -> float:
	var minutes = seconds_passed / 60.0
	return clamp(pow(minutes, 0.8) * 2.0, 0, 100)

func calculate_wealth_score(
	food: int, food_cap: int,
	wood: int, wood_cap: int,
	stone: int, stone_cap: int
) -> float:
	var food_ratio = float(food) / food_cap if food_cap != 0 else 0
	var wood_ratio = float(wood) / wood_cap if wood_cap != 0 else 0
	var stone_ratio = float(stone) / stone_cap if stone_cap != 0 else 0
	
	# Weighted contribution, same as before
	var raw_score = food_ratio * 1.0 + wood_ratio * 1.5 + stone_ratio * 2.0
	
	# Normalize against max possible (which is 4.5 if all are at 100%)
	raw_score /= 4.5
	
	# Add main_building_level multiplier (e.g., from 1 to 3)
	return clamp(raw_score * (TH_level * 0.25) * 100, 0, 100)

func get_npc_score() -> float:
	# We can weight the importance of defenders vs workers
	var defender_weight = 0.7
	var worker_weight = 0.3
	return (get_defender_score() * defender_weight) + (get_worker_score() * worker_weight)
	
func get_worker_score():
	if Global.get_max_civilians() == 0:
		return 0.0
	return clamp(float(Global.get_current_civilian_count()) / Global.get_max_civilians(), 0, 100)

func get_defender_score() -> float:
	var current_cp = get_current_cp()
	var max_cp = estimate_max_cp()
	if max_cp == 0:
		return 0.0
	return clamp(float(current_cp) / max_cp, 0, 100)

func get_current_cp(with_space:= true) -> int:
	var total_cp = 0
	for entities in $"../Base/Entities".get_children():
		if entities.has_node("Stats"):
			if with_space:
				total_cp += entities.find_child("Stats").calculate_cp() * entities.find_child("Stats").space_cost
			else:
				total_cp += entities.find_child("Stats").calculate_cp()
	return total_cp
	
func estimate_max_cp() -> int:
	
	var remaining_space = 0
	for kampo in Global.all_kampo:
		remaining_space += kampo.spaces
	var estimated_cp = 0

	# Sort defenders by CP per space, descending
	unlocked_defenders.sort_custom(func(a, b): return (b.cp / b.space) - (a.cp / a.space))
	#print(unlocked_defenders)
	for unit in unlocked_defenders:
		var count = remaining_space / unit.space
		estimated_cp += int(count) * unit.cp
		remaining_space -= int(count) * unit.space
		if remaining_space <= 0:
			break
	#print (estimated_cp)
	return estimated_cp

func determine_enemy_total_cp(wealth, defenders):
	var raid_strength = get_current_cp(false)
	var ratio = defenders/wealth if wealth != 0 else 1
	print("base cp: ",get_current_cp(false))
	if ratio < 1:
		raid_strength *= defenders/wealth
	print("defenders: ", defenders, " wealth: ", wealth, " ratio: ", ratio," cp: ", raid_strength)
	return raid_strength
	pass

func select_enemies_to_spawn(target_cp):
	var selected_enemies = []
	var total_cp = 0
	
	while total_cp < target_cp:
		var random_enemy = enemies.pick_random()
		var temp_inst = random_enemy.instantiate()
		var stats = temp_inst.find_child("Stats")
		print(stats.calculate_cp())
		total_cp += stats.calculate_cp()
		if total_cp > target_cp:
			total_cp -= stats.calculate_cp()
			break
		selected_enemies.append(temp_inst)
	print(total_cp)
	return selected_enemies
	
func spawn_enemy(sel_enemies):
	for enemy in sel_enemies:
		$"../Base/Entities".add_child(enemy)
