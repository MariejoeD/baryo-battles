extends Node3D

@export var Show_Debug: bool
@export var required_cp: int = 100
@export var enemies: Array[PackedScene] 
@export var spell_list: SpellList = preload("res://assets/spells/spells.tres")
@export var preferred_enemies: Array[PackedScene]
@export var base_enemy_count: int = 5
@export var min_enemies: int = 3
@export var max_enemies: int = 10
@export var troops: Dictionary
@export var Objects: Array[Node]
@export var boss_scene: PackedScene  # Reference to the boss scene
var enemies_spawned: bool = false
@onready var ui: Control = $"../UI"
@onready var win_lose_panel = $"../UI/WinLosePanel"
@onready var win_panel = $"../UI/WinLosePanel/winPanel"
@onready var lose_panel = $"../UI/WinLosePanel/losePanel"
@onready var go_home_button = $"../UI/WinLosePanel/goHome"
@onready var food_button = $"../UI/WinLosePanel/winPanel/foodButton"
@onready var wood_button = $"../UI/WinLosePanel/winPanel/woodButton"
@onready var stone_button = $"../UI/WinLosePanel/winPanel/stoneButton"
@onready var a_star: Node3D = %AStar
@onready var grid_map: GridMap = %GridMap
var place_holder


# Enum for spawn conditions
enum BossSpawnCondition {
	SpawnOnLoad,
	SpawnAfterAllEnemiesDead,
	SpawnAfterRandomDelay
}

@export var boss_spawn_condition: BossSpawnCondition = BossSpawnCondition.SpawnOnLoad  # Default to "Spawn on load"


@onready var UI = $"../UI"
@onready var container = UI.get_node("allyPanel/allyContainer")
@onready var camera = $"../SubViewportContainer/SubViewport/Camera3D"
@onready var player_cp = 0


var troop_scenes: Dictionary = {}
var boss_spawned = false
signal finished
func _ready() -> void:
	#show_result("win")
	ui.battle_countdown.times_up.connect(show_result.bind("lose"))
	UI.find_child("surrenderButton").pressed.connect(_on_surrender_button_pressed)
	UI.find_child("cancelButton").pressed.connect(_on_cancel_button_pressed)
	UI.find_child("confirmSurrenderButton").pressed.connect(_on_confirm_surrender_button_pressed)
	
	for troop_name in troops.keys():
		troop_scenes[troop_name] = load(troops[troop_name])
	player_cp = calculate_player_total_cp()
	var enemies = select_enemies_to_spawn()
	await get_tree().physics_frame
	$".".finished.connect($"../Path Generator".create_path_node)
	$"../Path Generator".finished.connect($"../AStar".create_astar)
	$"../AStar".finished.connect($".".spawn_enemy.bind(enemies))
	create_area_and_collision()
	print(boss_spawn_condition)
	ui.battle_countdown.countdown_on = true
	
	
func _process(delta: float) -> void:
# Call spawn boss function based on different conditions
	if place_holder:
		follow_mouse()
	if enemies_spawned:
		_spawn_boss_conditionally()
func _input(event: InputEvent) -> void:
	var panel_clicked = false
	var mouse_pos = get_viewport().get_mouse_position()
	if UI.get_node("allyPanel").get_global_rect().has_point(mouse_pos):
		panel_clicked = true
	if UI.get_node("spellPanel").get_global_rect().has_point(mouse_pos):
		panel_clicked = true
		
	if get_selected_troop() != "":
		if !place_holder:
			place_holder = load("res://Scene/placement_checker.tscn").instantiate()
			get_parent().add_child(place_holder)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not panel_clicked:
			var target_pos = get_mouse_floor_position()
			if target_pos == Vector3.ZERO or target_pos == Vector3.INF:
				return
			
			spawn_troop(target_pos)
	elif get_selected_spell() != "":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not panel_clicked:
			var target_pos = get_mouse_floor_position()
			if target_pos == Vector3.ZERO or target_pos == Vector3.INF:
				return
			cast_spell(target_pos)

func update_placeholder_color(can_place: bool) -> void:
	if not is_instance_valid(place_holder):
		return

	var mesh_instance = place_holder as MeshInstance3D
	if not mesh_instance:
		return

	var active_mat := mesh_instance.get_active_material(0)
	if active_mat == null:
		return

	# Duplicate the material to avoid editing the original
	var mat := active_mat.duplicate()
	mat.albedo_color = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)
	mat.emission = Color(0, 1, 0) if can_place else Color(1, 0, 0)
	# Assign the modified material to override
	mesh_instance.set_surface_override_material(0, mat)

func follow_mouse():
	var fixed_y= 1.5
	var viewport = get_tree().current_scene.find_child("SubViewport")
	var camera = viewport.get_node("Camera3D")
	if not camera:
		return
	
	var mouse_pos = viewport.get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	# Plane at a fixed Y position
	var t = (fixed_y - ray_origin.y) / ray_dir.y
	var target_position = ray_origin + ray_dir * t

	# Snap to the GridMap
	var grid_cell_size = grid_map.cell_size  # Assumes GridMap uses uniform cells
	var snapped_x = snappedf(target_position.x, grid_cell_size.x)
	var snapped_z = snappedf(target_position.z, grid_cell_size.z)

	# Apply snapped position (keeping fixed Y)
	if is_instance_valid(place_holder):
		var final_pos = Vector3(snapped_x, fixed_y, snapped_z)
		place_holder.global_transform.origin = final_pos
		var can_place = await is_position_valid(final_pos)
		update_placeholder_color(can_place)

	
func get_mouse_floor_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.set_collision_mask(1)
	var result = space_state.intersect_ray(query)

	if result:
		result.position.y = 0
		return result.position
	return Vector3.INF

func troopCount():
	var troop_count = 0
	for troop in UI.troop_data.keys():
		troop_count += UI.troop_data[troop][0]
	return troop_count

func spawn_troop(target_position: Vector3):
	var selected_troop = get_selected_troop()
	if selected_troop == "":
		return

	var troop_count = UI.troop_data[selected_troop][0]
	if troop_count <= 0:
		return

	var Troop_Scene = troop_scenes.get(selected_troop)
	#print("Troop scene for selected troop: ", Troop_Scene)

	if not Troop_Scene:
		return

	var temp_instance = Troop_Scene.instantiate()
	
	var collision_shape = temp_instance.get_node_or_null("CollisionShape3D")
	if not collision_shape:
		temp_instance.queue_free()
		return

	if not await is_position_valid(place_holder.global_transform.origin):
		
		temp_instance.queue_free()
		return

	UI.troop_data[selected_troop][0] -= 1
	if UI.troop_data[selected_troop][0] == 0:
		get_parent().remove_child(place_holder)
		place_holder.queue_free()
	UI.update_troop_count_label(container.get_node(selected_troop), UI.troop_data[selected_troop][0])
	temp_instance.position = a_star.find_closest_pos(target_position)
	print("Position Spawned: ",temp_instance.position)
	temp_instance.position.y = 1.25
	temp_instance.find_child("Stats").apply_spawn_scaling()
	temp_instance.find_child("Stats").level = Npc.troops_level[selected_troop]
	add_child(temp_instance)

func get_selected_troop() -> String:
	for troop_name in UI.troop_data.keys():
		if UI.troop_data[troop_name][1]:
			return troop_name
	return ""

func get_spell_scene(spell_name: String) -> PackedScene:
	for spell in spell_list.spells:
		if spell.Name == spell_name:
			return spell.Scene
	return null

func cast_spell(target_position: Vector3):
	var selected_spell = get_selected_spell()
	if selected_spell == "":
		return
	if UI.spell_data[selected_spell][0] <= 0:
		return
	
	var spell_scene = get_spell_scene(selected_spell)
	if spell_scene == null:
		print("Spell scene not found!")
		return
	
	var spell_instance = spell_scene.instantiate()
	UI.spell_data[selected_spell][0] -= 1
	UI.find_child(selected_spell).get_child(0).text = str(UI.spell_data[selected_spell][0])
	spell_instance.find_child("CollisionShape3D").shape.radius = 1.5
	target_position.y =1
	spell_instance.global_position = target_position
	add_child(spell_instance)
	spell_instance.scale = Vector3(3,3,3)

	

func get_selected_spell() -> String:
	for spell_name in UI.spell_data.keys():
		if UI.spell_data[spell_name][1]:
			return spell_name
	return ""
	
func is_position_valid(position: Vector3) -> bool:
	var closest_point = a_star.aS.get_closest_point(position)
	if not a_star.aS.has_point(closest_point):
		return false
	var closest_position = a_star.aS.get_point_position(closest_point)
	var distance = position.distance_to(closest_position)
	return distance < 3.0  # Adjust this threshold as needed based on your grid scale

	
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

				# Create the area and collision shape
				var area = Area3D.new()
				var collision = CollisionShape3D.new()
				var box = BoxShape3D.new()

				# Set the extents (half of the AABB size)
				box.extents = aabb.size / 2
				collision.shape = box
				
				# Calculate the center of the AABB and position the collision shape
				var center = aabb.position + aabb.size / 2
				collision.position = mesh_inst.position + center

				area.add_child(collision)

				if Show_Debug:
					# Optionally add a debug visualizer to see the collision bounds in the editor
					var debug_mesh = MeshInstance3D.new()
					debug_mesh.mesh = BoxMesh.new()
					debug_mesh.scale = aabb.size
					debug_mesh.position = aabb.position + aabb.size / 2  # Position the debug mesh at the center of the AABB
					debug_mesh.material_override = preload("res://materials/debug_material.tres")  # Add your debug material
					area.add_child(debug_mesh)

				# Add the area as a child of the mesh instance (or its parent)
				mesh_inst.add_child(area)

	emit_signal("finished")


func _spawn_boss_conditionally() -> void:
	if boss_spawned:
		return
	if boss_scene:
		if Npc.bosses[boss_scene.resource_path.get_file().get_basename()]:
			return
	match boss_spawn_condition:
		# Condition 0: Spawn boss on load
		BossSpawnCondition.SpawnOnLoad:
			#print("on load")
			if !boss_spawned:
				spawn_boss()

		# Condition 1: Spawn boss after all enemies are dead
		BossSpawnCondition.SpawnAfterAllEnemiesDead:
			if all_enemies_defeated() and !boss_spawned:
				spawn_boss()

		# Condition 2: Spawn boss after a random delay
		BossSpawnCondition.SpawnAfterRandomDelay:
			if randf() < 0.1 and !boss_spawned:  # 10% chance on each frame to spawn the boss
				spawn_boss()

func spawn_boss() -> void:
	if not boss_spawned and boss_scene:
		var boss = boss_scene.instantiate()
		# Find a valid position to spawn the boss
		var random_position = get_random_position()
		var collision_shape = boss.get_node_or_null("CollisionShape3D")
		if collision_shape and await is_position_valid(random_position):
			boss.position = random_position
		
		if boss.find_child("Stats").has_method("apply_spawn_scaling"):
			boss.find_child("Stats").apply_spawn_scaling()
		add_child(boss)
		boss.add_to_group("boss")  # ✅ Add boss to group for tracking
		boss_spawned = true
		#print("Boss spawned at position: ", valid_position)

func all_enemies_defeated() -> bool:
	# Logic to check if all enemies are defeated
	# You can implement this by checking the active enemies in the scene
	# This is a placeholder implementation
	var enemies_remaining = get_tree().get_nodes_in_group("Enemy")  # Assuming enemies are in the "enemies" group
	for enemy in enemies_remaining:
		if enemy.is_inside_tree() and enemy.visible:  # Example check if the enemy is still alive
			return false
	return true

func win_lose_check():
	# Wait for the next frame to ensure nodes have been processed (queue_free is done)
	await get_tree().process_frame
	_spawn_boss_conditionally()
	var enemies_remaining
	var troops_remaining
	# Get all enemies and troops
	if get_tree() and get_tree().has_group("Enemy"):
		enemies_remaining = get_tree().get_nodes_in_group("Enemy")
	else:
		enemies_remaining = []

	if get_tree() and get_tree().has_group("Good"):
		troops_remaining = get_tree().get_nodes_in_group("Good")
	else:
		troops_remaining = []


	# Check if any enemies are alive
	var all_enemies_defeat = true
	var boss_dead = true

	for enemy in enemies_remaining:
		# Skip boss check for now
		if enemy.is_in_group("boss"):
			if enemy.is_inside_tree():
				boss_dead = false
			continue
		
		# For regular enemies, check if they are still alive
		if enemy.is_inside_tree() and enemy.visible:
			all_enemies_defeat = false
			break  # If one is alive, no need to continue checking

	# New logic to check if the player has any troops left to spawn
	var no_more_troops = true
	for troop in UI.troop_data.values():
		if troop[0] > 0:  # troop[0] = available count
			no_more_troops = false
			break
	# Determine win or lose
	if all_enemies_defeat and boss_dead:
		print("✅ WIN!")
		show_result("win")
	elif troops_remaining.size() == 0 and no_more_troops:
		print("❌ LOSE!")
		show_result("lose")

#win or lose
func show_result(result: String):
	win_lose_panel.visible = true  # Show the result panel
	ui.battle_countdown.countdown_on = false
	
	if result == "win":
		win_panel.visible = true
		lose_panel.visible = false

		go_home_button.visible = false  # Hide the Go Home button initially
		#choose_resource_to_generate()
		print("YOU WIN!")
		Global.food_qty = min(Global.food_qty + 500, Global.get_food_cap())
		Global.wood_qty = min(Global.wood_qty + 500, Global.get_wood_cap())
		Global.stone_qty = min(Global.stone_qty + 500, Global.get_stone_cap())
		SaverLoader.save_resources()
		# Connect resource buttons to show the go home button
		if not food_button.is_connected("pressed", Callable(self, "choose_resource_to_generate")):
			food_button.pressed.connect(choose_resource_to_generate.bind("Food"))

		if not wood_button.is_connected("pressed", Callable(self, "choose_resource_to_generate")):
			wood_button.pressed.connect(choose_resource_to_generate.bind("Wood"))

		if not stone_button.is_connected("pressed", Callable(self, "choose_resource_to_generate")):
			stone_button.pressed.connect(choose_resource_to_generate.bind("Stone"))

	elif result == "lose":

		win_panel.visible = false
		lose_panel.visible = true
		go_home_button.visible = true  # Show Go Home immediately on loss
		print("YOU LOSE!")
		# Connect the go home button
		if not go_home_button.is_connected("pressed", Callable(self, "_on_go_home_pressed")):
			go_home_button.connect("pressed", Callable(self, "_on_go_home_pressed"))

func _on_resource_selected():
	go_home_button.visible = true

func _on_go_home_pressed():
	SaverLoader.clear_used_troops()
	SceneManager.go_to_scene("res://Scene/HomeBase.tscn")

func choose_resource_to_generate(resource:= "Food"):
	MapManager.conquer_base(get_parent().name,resource, 5)
	SaverLoader.save_battle_data()
	SaverLoader.clear_used_troops()
	SceneManager.go_to_scene("res://Scene/HomeBase.tscn")
	pass


func _on_surrender_button_pressed():
	UI.find_child("surrenderPanel").visible = true


func _on_cancel_button_pressed():
	UI.find_child("surrenderPanel").visible = false


func _on_confirm_surrender_button_pressed():
	surrender()


func surrender():
	SaverLoader.clear_used_troops()
	SceneManager.go_to_scene("res://Scene/HomeBase.tscn")

func calculate_player_total_cp():
	var total_cp = 0
	print("=== Calculating Player Total CP ===")
	print("UI.troop_data keys: ", UI.troop_data.keys())
	print("troops keys: ", troops.keys())

	for troop_name in UI.troop_data.keys():
		if troop_name in troops:
			var troop_scene = load(troops[troop_name])
			var troop_instance = troop_scene.instantiate()

			if troop_instance.has_node("Stats"):
				var troop_count = UI.troop_data[troop_name][0]
				var cp = troop_instance.get_node("Stats").calculate_cp()
				var troop_cp_total = troop_count * cp
				print("✅ Troop: %s | Count: %d | CP per unit: %d | Total CP: %d" % [troop_name, troop_count, cp, troop_cp_total])
				total_cp += troop_cp_total
			else:
				print("⚠️ Troop '%s' does not have a 'Stats' node." % troop_name)

			troop_instance.queue_free()
		else:
			print("❌ Troop '%s' found in UI.troop_data but missing in troops dictionary." % troop_name)

	print(">> ✅ Total Player CP: %d" % total_cp)
	return total_cp


func calculate_enemy_count():
	if player_cp == 0:
		return max_enemies
	
	var enemy_count = clampi(
		base_enemy_count + ((required_cp/player_cp) - 1) * base_enemy_count,
		min_enemies,
		max_enemies
	)
	#print(enemy_count)
	return int(enemy_count)

func pick_weighted_enemy(preferred_enemies: Array, remaining_enemies: Array) -> PackedScene:
	var all_enemies = []
	var weights = []

	for enemy in preferred_enemies:
		all_enemies.append(enemy)
		var check = enemy.instantiate()
		if check.has_node("Stats"):
			var defeated_count = 0
			for status in Npc.bosses.values():
				if status == true:
					defeated_count += 1
			check.get_node("Stats").level = defeated_count+ 1
			weights.append(check.get_node("Stats").calculate_cp()*2)
		check.queue_free()



	for enemy in remaining_enemies:
		all_enemies.append(enemy)
		var check = enemy.instantiate()
		if check.has_node("Stats"):
			var defeated_count = 0
			for status in Npc.bosses.values():
				if status == true:
					defeated_count += 1
			check.get_node("Stats").level = defeated_count+ 1
			weights.append(check.get_node("Stats").calculate_cp())
		check.queue_free()

	var total_weight = sum_array(weights)
	var rand = randf_range(0, total_weight)

	var cumulative_weight = 0
	for i in range(all_enemies.size()):
		cumulative_weight += weights[i]
		if rand < cumulative_weight:
			return all_enemies[i]

	return all_enemies[0]

#func get_max_cp():
	#var max_cp = 0
	#for enemy_scene in enemies:
		#var temp_enemy = enemy_scene.instantiate()
		#var stats_node = temp_enemy.get_node_or_null("Stats")
		#
		#if stats_node:
			#stats_node.level = Npc.TH_level if Npc.TH_level !=0 else 1
			#var enemy_cp = stats_node.calculate_cp()
			#max_cp = max(enemy_cp * max_enemies,max_cp)
			#temp_enemy.queue_free()
	#return max_cp

func select_enemies_to_spawn():
	max_enemies = max(troopCount(), max_enemies)
	var soft_enemy_count = calculate_enemy_count()

	# Ensure player_cp doesn't cause target_cp to go below required_cp
	var ratio = clampf(required_cp / player_cp if player_cp != 0 else 1, 1.0, 1.5)
	var target_multiplier = lerpf(1.0, 1.5, (ratio - 1.0) / (1.5 - 1.0))
	var target_cp = required_cp * target_multiplier

	#target_cp = min(target_cp, get_max_cp())  # Final safety check
	

	#print(get_max_cp())
	print("required: ",required_cp)
	print("playe cp: ", calculate_player_total_cp())
	var best_cp = 0
	var best_selection = []

	var attempts = 5
	while attempts > 0:
		var remaining_enemies = enemies.duplicate()
		var selected_enemies = []
		var total_cp = 0
		var selected_enemy_types = {}

		# Add boss CP
		if boss_scene:
			var boss = boss_scene.instantiate()
			var boss_stats_node = boss.get_node_or_null("Stats")
			if boss_stats_node:
				total_cp += boss_stats_node.calculate_cp()

		# Pick one of each unique enemy type
		for enemy_scene in enemies:
			if not selected_enemy_types.has(enemy_scene):
				var temp_enemy = enemy_scene.instantiate()
				var stats_node = temp_enemy.get_node_or_null("Stats")
				if stats_node:
					var defeated_count = 0
					for status in Npc.bosses.values():
						if status == true:
							defeated_count += 1
					stats_node.level = defeated_count+ 1
					var enemy_cp = stats_node.calculate_cp()
					if total_cp + enemy_cp > target_cp:
						break
					total_cp += enemy_cp
					selected_enemies.append(temp_enemy)
					selected_enemy_types[enemy_scene] = true

		# Fill remaining slots
		while total_cp < target_cp:
			var next_enemy_scene = pick_weighted_enemy(preferred_enemies, remaining_enemies)
			var next_enemy = next_enemy_scene.instantiate()
			var stats_node = next_enemy.get_node_or_null("Stats")
			if stats_node:
				var defeated_count = 0
				for status in Npc.bosses.values():
					if status == true:
						defeated_count += 1
				stats_node.level = defeated_count+ 1
				var enemy_cp = stats_node.calculate_cp()
				#if total_cp + enemy_cp > target_cp:
					#break
				total_cp += enemy_cp
				selected_enemies.append(next_enemy)
		
		print("Target CP: ", target_cp)
		print("Enemy CP after loop: ", total_cp)
		print("Enemy count: ", selected_enemies.size())

		# Acceptable result found
		if total_cp >= best_cp:
			best_cp = total_cp
			best_selection = selected_enemies
			print(best_cp)
		# If CP is too low and enemy count is nearly max, retry
		if total_cp < target_cp * 0.9 and selected_enemies.size() >= max_enemies - 1:
			print("Retrying selection: low CP, high count")
			attempts -= 1
			continue


		break  # exit if good enough
		

	return best_selection



func spawn_enemy(enemies):
	#print(enemies)
	for enemy in enemies:
		#print(enemy)
		if enemy and is_instance_valid(enemy):
			var found_pos = false
			for i in range(max_enemies * 5):
				var random_position = get_random_position()
				var collision_shape = enemy.get_node_or_null("CollisionShape3D")
				if collision_shape and await is_position_valid(random_position):
					random_position.y = 0
					enemy.position = random_position
					if enemy.find_child("Stats").has_method("apply_spawn_scaling"):
						enemy.find_child("Stats").apply_spawn_scaling()
					var stats_node = enemy.get_node_or_null("Stats")
					if stats_node:
						var defeated_count = 0
						for status in Npc.bosses.values():
							if status == true:
								defeated_count += 1
						stats_node.level = defeated_count+ 1
					add_child(enemy)
					found_pos = true
					break

			if not found_pos:
				#print("[ERROR] No valid position found for enemy!")
				pass
	enemies_spawned = true

func get_random_position() -> Vector3:
	var x = randf_range(-70, 70)
	var y = 0
	var z = randf_range(-70, 70)
	var snapped_pos = a_star.find_closest_pos(Vector3(x, 0, z))
	return snapped_pos

func sum_array(arr: Array) -> float:
	var total = 0.0
	for value in arr:
		total += value
	return total
