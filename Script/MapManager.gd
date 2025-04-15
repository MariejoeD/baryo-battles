extends Node

# Holds data about conquered bases
var conquered_bases := []

# Player’s total resources
var resources

# Called when the game starts
func _ready():
	start_resource_timer()
	SignalManager.new_day.connect(map_report)

# Add a conquered base to the list
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
		base["stored_resources"] += rate + (base["civilian"] * .5)
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
