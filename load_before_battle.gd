extends Control

@onready var loading_bar = $Panel/LoadingBar
@onready var random_message = $Panel/Randomfacts
@onready var province_label = $Panel/provinceName

var target_scene_path := ""
var random_texts = []
var loading_percentage := 0

func _ready() -> void:
	randomize()
	Input.set_custom_mouse_cursor(
		load("res://assets/game/cursor.png"),
		Input.CURSOR_ARROW
	)
	loading_bar.value = 0
	
	set_province_data()
	perform_loading()

func set_province_data() -> void:
	var file_name = target_scene_path.get_file().get_basename()  # e.g., "bohol"

	var province_facts = {
		"bohol": [
			"Did you know? The Chocolate Hills turn brown during dry season!",
			"Tip: Watch out for the Tarsier's stare.",
			"Fun Fact: Bohol is home to the Loboc River cruise."
		],
		"cebu": [
			"Fact: Cebu was the first Spanish settlement in the Philippines.",
			"Tip: The Sinulog Festival boosts morale.",
			"Did you know? Lapu-Lapu defeated Magellan in Mactan."
		],
		"siquijor": [
			"Fun Fact: Iloilo is known as the 'Heart of the Philippines'.",
			"Did you know? The Dinagyang Festival honors the Santo Niño.",
			"Tip: Iloilo warriors move faster during festivals."
		],
		"biliran": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Eastern Samar": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"leyte": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Northern Samar": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Samar": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Southern Leyte": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Negros Occidental": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Negros Oriental": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Aklan": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Antique": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Guimaras": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		],
		"Ilo-ilo": [
			"Did you know? General MacArthur landed in Leyte!",
			"Tip: Strengthen your defenses against sea attacks.",
			"Fact: Leyte has one of the longest bridges—San Juanico Bridge."
		]
		
	}
	province_label.text = file_name.capitalize().replace("_", " ").replace("-", " ")

	if province_facts.has(file_name.capitalize()):
		random_texts = province_facts[file_name.capitalize()]
	else:
		random_texts = ["Loading facts...", "Prepare for battle!", "Good luck, commander!"]

func perform_loading() -> void:
	ResourceLoader.load_threaded_request(target_scene_path)
	var last_message_change := 0.0
	var change_message_interval := 0.30
	var loading_speed := 1.0

	var scene_ready := false
	var resource_loaded: Resource = null
	var reached_99 := false
	var hold_timer := 0.0
	var hold_duration := 0.7  # How long to pause at 99% before finishing

	while true:
		# Update loading status
		if not scene_ready:
			var status = ResourceLoader.load_threaded_get_status(target_scene_path)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				print("Before Scene Target: ",target_scene_path)
				
				resource_loaded = ResourceLoader.load_threaded_get(target_scene_path)
				
				print("After: ",resource_loaded.resource_path.get_file().get_basename(), "Scene Target: ",target_scene_path)
				scene_ready = true
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load scene: " + target_scene_path)
				break

		# Simulate progress
		if loading_bar.value < 99:
			loading_bar.value = clamp(loading_bar.value + randf_range(0.5, loading_speed), 0, 99)
		elif scene_ready and not reached_99:
			# Stay at 99 while holding
			reached_99 = true
			loading_bar.value = 99
		elif reached_99 and hold_timer < hold_duration:
			hold_timer += 0.02  # Same as timer wait
		elif reached_99 and hold_timer >= hold_duration:
			loading_bar.value = 100

		# Update loading text
		if last_message_change >= change_message_interval:
			random_message.text = random_texts[randi() % random_texts.size()]
			last_message_change = 0.0
		else:
			last_message_change += 0.02

		# Change scene only when bar hits 100 and resource is ready
		if scene_ready and loading_bar.value >= 100:
			var new_scene: Node = resource_loaded.instantiate()
			get_tree().root.add_child(new_scene)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = new_scene
			queue_free()
			break

		await get_tree().create_timer(0.08).timeout
