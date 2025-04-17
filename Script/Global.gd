#Global.gd a global script
extends Node



var wood_qty :int = 3000:
	set(wood):
		wood_qty = wood
		SignalManager.update_mats.emit()
	get:
		return wood_qty
		
var stone_qty :int = 3000:
	set(stone):
		stone_qty = stone
		SignalManager.update_mats.emit()
	get:
		return stone_qty
		
var food_qty :int = 3000:
	set(food):
		SignalManager.update_mats.emit()
		food_qty = food
	get:
		return food_qty
var total_space := 0
var used_space := 0

var grid_size :int = 100
var npc_discovered = {}


const DAY_DURATION := 40.0
const HALF_DAY := DAY_DURATION / 2.0

var current_time := 0.0
var time_of_day := 0.0
var has_emitted_night_time := false
var total_game_time := 0.0


#Kubo Tracking
var all_kubos: Array = []  # Stores all Kubo nodes
var all_kampo: Array = []
var all_imbakan: Array =[]
var all_bodega: Array = []
var kampo_troops: Dictionary = {}

var prologue_played = false
func _ready() -> void:
	SignalManager.discovered.connect(npc)
	load_troops_from_file()

func npc(name):
	npc_discovered[name] = true


func _process(delta: float) -> void:
	var current_scene = get_tree().current_scene

	# If we're not in the main scene, skip time progression
	#print(current_scene.name)
	if current_scene == null or current_scene.name != "HomeBase":
		return
	current_time += delta
	total_game_time += delta

	# Emit new day signal when full day duration is reached
	if current_time >= DAY_DURATION:
		SignalManager.new_day.emit()
		current_time = 0.0
		has_emitted_night_time = false  # Reset for next day

	# ✅ Recommended: Safe floating point comparison
	if not has_emitted_night_time and abs(current_time - HALF_DAY) < delta:
		print("Halfway reached (accurate): ", current_time)
		SignalManager.night_time.emit()
		has_emitted_night_time = true
	time_of_day = current_time / DAY_DURATION


func recalculate_space():
	total_space = 0
	used_space = 0

	# Clean invalid kampo instances
	all_kampo = all_kampo.filter(func(k): return is_instance_valid(k))

	for kampo in all_kampo:
		total_space += kampo.spaces

	var entities = get_tree().current_scene.find_child("Entities")
	if entities:
		for entity in entities.get_children():
			var stats = entity.find_child("Stats")
			if stats:
				used_space += stats.space_cost


func get_remaining_space() -> int:
	return total_space - used_space

func get_food_cap():
	var total_food_cap = 0
	print("Imbakan")
	print(all_imbakan)

	all_imbakan = all_imbakan.filter(func(i): return is_instance_valid(i))  # Clean freed ones

	for imbakan in all_imbakan:
		print("Imbakan:", imbakan.food_cap)
		total_food_cap += imbakan.food_cap
	return total_food_cap


func get_wood_cap():
	var total_wood_cap = 0

	all_bodega = all_bodega.filter(func(b): return is_instance_valid(b))  # Clean freed ones

	for bodega in all_bodega:
		total_wood_cap += bodega.wood_cap
	return total_wood_cap


func get_stone_cap():
	var total_stone_cap = 0

	all_bodega = all_bodega.filter(func(b): return is_instance_valid(b))  # Clean freed ones

	for bodega in all_bodega:
		total_stone_cap += bodega.stone_cap
	return total_stone_cap

# Count actual number of civilians in the scene dynamically
func get_current_civilian_count() -> int:
	var stored_civ = 0
	
	# Remove freed kubos
	all_kubos = all_kubos.filter(func(kubo): return is_instance_valid(kubo))
	
	for kubo in all_kubos:
		stored_civ += kubo.stored_sibilyans.size()
	
	return get_tree().get_nodes_in_group("Sibilyan").size() + stored_civ



# Get the total max civilians from all built Kubos
func get_max_civilians() -> int:
	var max_civilians = 0
	for kubo in all_kubos:
		if is_instance_valid(kubo):  # Ensure Kubo is still valid
			max_civilians += kubo.max_sibilyans
	return max_civilians

# Check if we can generate a new civilian
func can_generate_civilian() -> bool:
	print(get_current_civilian_count(),"/",get_max_civilians())
	return get_current_civilian_count() < get_max_civilians()
func load_troops_from_file():
	var file_path = "user://troops_data.save"
	print("Checking file at:", ProjectSettings.globalize_path(file_path))

	if not FileAccess.file_exists(file_path):
		print("File does not exist:", file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()

	if save_data:
		Global.kampo_troops = save_data
		print("Loaded troops successfully from", ProjectSettings.globalize_path(file_path))
