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
		food_qty = food
		SignalManager.update_mats.emit()
	get:
		return food_qty

var grid_size :int = 100
var npc_discovered = {}

const DAY_DURATION = 1200
var current_time = 0.0
var time_of_day: float


#Kubo Tracking
var all_kubos: Array = []  # Stores all Kubo nodes
var all_kampo: Array = []
var kampo_troops: Dictionary = {}
func _ready() -> void:
	SignalManager.discovered.connect(npc)
	load_troops_from_file()

func npc(name):
	npc_discovered[name] = true

func _process(delta: float) -> void:
	current_time += delta
	if current_time >= DAY_DURATION:
		SignalManager.new_day.emit()
		current_time = 0.0
	time_of_day = current_time / DAY_DURATION


# Count actual number of civilians in the scene dynamically
func get_current_civilian_count() -> int:
	return get_tree().get_nodes_in_group("Sibilyan").size()


# Get the total max civilians from all built Kubos
func get_max_civilians() -> int:
	var max_civilians = 0
	for kubo in all_kubos:
		if is_instance_valid(kubo):  # Ensure Kubo is still valid
			max_civilians += kubo.max_sibilyans
	print(max_civilians)
	return max_civilians

# Check if we can generate a new civilian
func can_generate_civilian() -> bool:
	return get_current_civilian_count() < get_max_civilians()
func load_troops_from_file():
	if not FileAccess.file_exists("user://troops_data.save"):
		print("dont exist")
		return

	var file = FileAccess.open("user://troops_data.save", FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()

	if save_data:
		Global.kampo_troops = save_data
