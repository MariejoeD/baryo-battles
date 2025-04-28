extends Node3D

@export var heal: float = 50.0
@export var spell_cast_duration: float = 10.0

var bodies: Array = []
var heal_timer: Timer

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Good"):  # Ensure the body is in the "Good" group
		bodies.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	bodies.erase(body)

func _ready() -> void:
	# Set up the timer to destroy the spell after the specified duration
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = spell_cast_duration
	add_child(timer)
	timer.start()
	timer.timeout.connect(remove_spell)

	# Set up the heal timer to heal every second
	heal_timer = Timer.new()
	heal_timer.wait_time = 1.0  # Heal every 1 second
	heal_timer.autostart = true
	heal_timer.one_shot = false
	add_child(heal_timer)
	heal_timer.timeout.connect(_heal_bodies)

func remove_spell():
	# Remove the spell (queue_free when the timer expires)
	queue_free()

func _heal_bodies():
	# Heal all bodies within the area
	for body in bodies:
		if body.is_in_group("Good"):
			var stats = body.find_child("Stats")
			if stats:
				stats._on_heal(heal)
