extends Control

var base_name = "base"
var resource_type = "Wood"
var rate = 0
var addRate = 0
var baseCp = 0
var addCp = 0

var troops_scene = {
	"arnisador" : load("res://Scene/Characters/arnisador.tscn"),
	"lakan_warrior" : load("res://Scene/Characters/lakan_warrior.tscn"),
	"mangagamot" : load("res://Scene/Characters/manggagamot.tscn"),
	"tirador" : load("res://Scene/Characters/tirador.tscn"),
	"marites" : load("res://Scene/Characters/marites.tscn")
}
func _ready() -> void:
	for child in %troops.get_children():
		child.pressed.connect(add_troop.bind(child))
		pass
	for child in %addedTroops.get_children():
		child.pressed.connect(remove_troop.bind(child))
		pass
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if %infoPanel.visible:
			var mouse_pos = get_viewport().get_mouse_position()
			if not %infoPanel.get_global_rect().has_point(mouse_pos):
				%infoPanel.hide()

func update_troop_qty():
	for troop in %addedTroops.get_children():
		troop.hide()
		troop.get_node("qty").text = str(0)
	
	for kampo in Global.kampo_troops.values():
		for troop in %troops.get_children():
			if kampo.has(troop.name):
				troop.get_node("qty").text = str(kampo[troop.name])
			else:
				troop.get_node("qty").text = str(0)
	# Called when the node enters the scene tree for the first time.
func update():
	%baseName.text = base_name
	%type.text = resource_type
	%rate.text = str(rate)+"/m"
	%addedRate.text = "+"+str(addRate)+"/m"
	%currentCP.text = str(baseCp)
	%toBeAddedCP.text = "+"+str(addCp)
func start():
	addRate = 0
	addCp = 0
	%sibilyanQty.text = str(0)
	update()
	update_troop_qty()
func add_troop(troop):
	var qty_label := troop.get_node("qty") as Label
	var qty := int(qty_label.text)
	if qty == 0:
		return
	qty = max(qty - 1, 0)
	qty_label.text = str(qty)

	var add_troop_node := %addedTroops.find_child(troop.name)
	if add_troop_node:
		# Instantiate the troop scene
		var inst = troops_scene[troop.name].instantiate()
		var stats = inst.find_child("Stats")

		# Ensure "Stats" node exists before calling calculate_cp
		if stats:
			var troop_cp = stats.calculate_cp()
			if troop_cp != null:
				addCp += troop_cp
				update()
			else:
				print("Error: calculate_cp() returned null")
		else:
			print("Error: 'Stats' node not found for ", troop.name)
		var aqty_label := add_troop_node.get_node("qty") as Label
		var aqty := int(aqty_label.text)
		aqty += 1
		aqty_label.text = str(aqty)
		add_troop_node.show()
	else:
		print("Troop not found in addedTroops: ", troop.name)
	pass

func remove_troop(troop: Node):
	var aqty_label := troop.get_node("qty")
	var aqty := int(aqty_label.text)
	aqty = max(aqty - 1, 0)
	aqty_label.text = str(aqty)

	# Optionally hide if quantity is 0
	if aqty == 0:
		troop.hide()

	# Find the corresponding troop in %troops
	var main_troop := %troops.find_child(troop.name, true, false)
	if main_troop:
		var qty_label := main_troop.get_node("qty")
		var qty := int(qty_label.text)
		qty += 1
		qty_label.text = str(qty)
		# Instantiate the troop scene
		var inst = troops_scene[troop.name].instantiate()
		var stats = inst.find_child("Stats")

		# Ensure "Stats" node exists before calling calculate_cp
		if stats:
			var troop_cp = stats.calculate_cp()
			if troop_cp != null:
				addCp -= troop_cp
				update()
			else:
				print("Error: calculate_cp() returned null")
		else:
			print("Error: 'Stats' node not found for ", troop.name)
	else:
		print("Could not find troop in %troops: ", troop.name)


func _on_info_button_pressed() -> void:
	%infoPanel.show()
	pass # Replace with function body.

func update_civilian_qty(qty: int) -> void:
	addRate = 6 * qty
	%sibilyanQty.text = str(qty)
	update()

func _on_add_pressed() -> void:
	var qty = int(%sibilyanQty.text)
	if Global.get_current_civilian_count() == qty+1:
		var warning_label = get_tree().current_scene.find_child("warningLabel")
		if warning_label:
			warning_label.text = "Max Sibilyan Reach"
			warning_label.visible = true
			
			# Ensure the label is on top by setting its Z-Index to a high value
			warning_label.z_index = 10  # Adjust this value to suit your needs
			
			await get_tree().create_timer(3.0).timeout
			warning_label.visible = false
		return
	qty += 1
	update_civilian_qty(qty)

func _on_reduce_pressed() -> void:
	var qty = int(%sibilyanQty.text)
	qty -= 1
	if qty < 0:
		qty = 0
	update_civilian_qty(qty)
	
	pass # Replace with function body.
func base_data():
	for base in MapManager.conquered_bases:
		if base["name"] == base_name.capitalize():
			return base
	return {}

func _on_deploy_button_pressed() -> void:
	remove_sibilyan(int(%sibilyanQty.text))
	remove_troops()
	var data = base_data()
	if data:
		# Update base data (example: change name and resource type)
		data["civilian"] += int(%sibilyanQty.text)
		data["base_cp"] += addCp
		
		
		rate = data["rate"] + (data["civilian"] * 0.5) * 12
		baseCp = data["base_cp"]
		addRate = 0
		addCp = 0
		%sibilyanQty.text = str(0)

		# Refresh UI
		update()
		update_troop_qty()
		
	pass # Replace with function body.

func remove_sibilyan(count: int):
	var remaining = count
	
	for kubo in Global.all_kubos:
		if not is_instance_valid(kubo):
			continue

		var stored = kubo.stored_sibilyans
		var available = stored.size()

		if available >= remaining:
			# Remove just the number needed and stop
			for i in range(remaining):
				stored.pop_back()  # Or pop_front(), depending on your order
				kubo.current_sibilyan -= 1
			return
		else:
			# Remove all from this kubo and reduce the remaining count
			stored.clear()
			kubo.current_sibilyan = 0
			remaining -= available


func remove_troops():
	for troops_picked in %addedTroops.get_children():
		var qty_to_remove = int(troops_picked.find_child("qty").text)
		if qty_to_remove <= 0:
			continue  # Skip troops with zero quantity
		var qty_removed = 0
		var troop_name = troops_picked.name

		# 1. Remove from kampo.Troops
		for kampo in Global.all_kampo:
			if not kampo:
				continue
			var stored_troops = kampo.get("troops")
			var i = 0
			while i < stored_troops.size():
				if stored_troops[i]["name"] == troop_name:
					stored_troops.remove_at(i)
					qty_removed += 1
					if qty_removed >= qty_to_remove:
						break
				else:
					i += 1
			if qty_removed >= qty_to_remove:
				break

		# 2. Remove from kampo_troops
		var qty_left_to_remove = qty_removed  # Use qty_removed instead
		for kampo_id in Global.kampo_troops.keys():
			var troop_dict = Global.kampo_troops[kampo_id]
			if troop_dict.has(troop_name):
				var current_qty = troop_dict[troop_name]
				var remove_count = min(current_qty, qty_left_to_remove)
				troop_dict[troop_name] -= remove_count
				qty_left_to_remove -= remove_count
				if troop_dict[troop_name] <= 0:
					troop_dict.erase(troop_name)
				if qty_left_to_remove <= 0:
					break

		# 3. Queue NPCs from scene
		var queued_count := 0
		for npc in get_tree().current_scene.find_child("Entities").get_children():
			var stats = npc.find_child("Stats", false)
			if stats and stats.Name == troop_name:
				npc.queue_free()
				queued_count += 1
				if queued_count >= qty_removed:
					break

		# Logging
		if qty_removed < qty_to_remove:
			print("⚠️ Not enough", troop_name, "troops to remove. Removed:", qty_removed, "/", qty_to_remove)
		else:
			print("✅ Removed", qty_removed, troop_name)
