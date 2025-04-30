extends Node

# Holds data about conquered bases
var conquered_bases := []

# Player’s total resources
var resources

# Sequence of maps: each map unlocks when a specific base is conquered
var map_sequence := [
	{ "map_name": "antique", "required_base": "Aklan" },
	{ "map_name": "Ilo-Ilo", "required_base": "antique" },
	{ "map_name": "guimaras", "required_base": "Ilo-ilo" },
	{ "map_name": "negrosOccidental", "required_base": "guimaras" },
	{ "map_name": "negrosOriental", "required_base": "negrosOccidental" },
	{ "map_name": "siquijor", "required_base": "negrosOriental" },
	{ "map_name": "cebu", "required_base": "siquijor" },
	{ "map_name": "bohol", "required_base": "cebu" },
	{ "map_name": "southernLeyte", "required_base": "bohol" },
	{ "map_name": "leyte", "required_base": "southernLeyte" },
	{ "map_name": "biliran", "required_base": "leyte" },
	{ "map_name": "samar", "required_base": "biliran" },
	{ "map_name": "easternSamar", "required_base": "samar" },
	{ "map_name": "northernSamar", "required_base": "easternSamar" },
	{ "map_name": "biringan", "required_base": "northernSamar" },
]

# Start with the first map unlocked
var unlocked_maps := ["Aklan"]

func _ready():
	start_resource_timer()
	SignalManager.new_day.connect(map_report)

# Add a conquered base to the list and check for map unlock
func conquer_base(base_name: String, resource_type: String, rate_per_minute: int):
	conquered_bases.append({
		"name": base_name,
		"resource": resource_type,
		"rate": rate_per_minute,
		"civilian": 0,
		"base_cp": 0,
		"stored_resources": 0
	})
	print("Conquered base: %s now producing %s" % [base_name, resource_type])

	check_map_unlocks(base_name)

# Check if conquering this base unlocks a new map
func check_map_unlocks(conquered_base_name: String):
	for entry in map_sequence:
		# Case-insensitive comparison using to_lower()
		if entry["required_base"].to_lower() == conquered_base_name.to_lower() and entry["map_name"] not in unlocked_maps:
			unlocked_maps.append(entry["map_name"])
			print("🗺️ New map unlocked: %s (via conquering %s)" % [entry["map_name"], conquered_base_name])

# Get the list of currently available maps
func get_available_maps() -> Array:
	return unlocked_maps

# Timer to generate resources every X seconds
func start_resource_timer():
	var timer = Timer.new()
	timer.name = "ResourceTimer"
	timer.wait_time = 5.0  # Every 5 seconds
	timer.one_shot = false
	timer.timeout.connect(_on_resource_tick)
	add_child(timer)
	timer.start()

func _on_resource_tick():
	for base in conquered_bases:
		var rate = base["rate"]
		base["stored_resources"] += rate + (base["civilian"] * 0.5)
		print("Generated %d from %s" % [rate, base["name"]])

func map_report():
	print("---Report---")

	for base in conquered_bases:
		# Battle roll (skip base if lost)
		if randi_range(1, 100) <= 50:
			var base_value = base["rate"] * 240
			var base_cp = base["base_cp"]
			var pressure = base_value / max(base_cp, 1)

			var multiplier = clamp(0.8 + ((pressure - 2) / 8) * 0.4, 0.8, 1.2)
			var enemy_cp = base_cp * multiplier

			if base_cp < enemy_cp or base_cp == 0:
				print("⚔️ Lost: %s" % base["name"])
				conquered_bases.erase(base)
				continue

		var res_type = base["resource"]
		var stored = base["stored_resources"]
		var current = 0
		var cap = 0

		match res_type:
			"Wood":
				current = Global.wood_qty
				cap = Global.get_wood_cap()
			"Stone":
				current = Global.stone_qty
				cap = Global.get_stone_cap()
			"Food":
				current = Global.food_qty
				cap = Global.get_food_cap()

		var space = cap - current
		var to_add = min(space, stored)

		if to_add > 0:
			print("✅ [Collected] %s: +%d (Before: %d)" % [res_type, to_add, current])
			current += to_add
			base["stored_resources"] -= to_add
		else:
			print("❌ [Cap Reached] %s: %d / %d | Stored: %d" % [res_type, current, cap, stored])

		match res_type:
			"Wood": Global.wood_qty = current
			"Stone": Global.stone_qty = current
			"Food": Global.food_qty = current

		base["base_cp"] *= 0.5
