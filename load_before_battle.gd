extends Control

@onready var loading_bar = $LoadingBar
@onready var random_message = $RandomFacts
@onready var province_label = $provinceName

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

	if province_facts.has(file_name):
		random_texts = province_facts[file_name]
	else:
		random_texts = ["Loading facts...", "Prepare for battle!", "Good luck, commander!"]

func perform_loading() -> void:
	var total_steps := 100
	var change_message_interval := 0.30
	var last_message_change := 0.0

	for step in range(total_steps):
		loading_percentage = step
		loading_bar.value = loading_percentage
		
		if last_message_change >= change_message_interval:
			random_message.text = random_texts[randi() % random_texts.size()]
			last_message_change = 0.0
		else:
			last_message_change += 0.02
		
		await get_tree().create_timer(0.02).timeout
	
	get_tree().change_scene_to_file(target_scene_path)
