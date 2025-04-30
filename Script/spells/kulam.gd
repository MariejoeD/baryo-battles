extends Node3D

@export var effect_duration: float = 5.0
@export var spell_cast_duration: float = 2.0
@onready var area_3d: Area3D = $Area3D
var target = "Enemy"
var affected_enemies := {}  # {body: original_damage}
var pending_removal := {}   # {body: Timer}

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_3d_body_entered)
	area_3d.body_exited.connect(_on_area_3d_body_exited)

	# Spell lasts 2 seconds then queue_free itself
	var spell_timer = get_tree().create_timer(spell_cast_duration)
	spell_timer.timeout.connect(_on_spell_timeout)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group(target):
		return
	
	if not affected_enemies.has(body):
		var stats = body.find_child("Stats")
		if stats:
			affected_enemies[body] = stats.damage
			stats.damage *= 0.75  # Apply debuff

	# Cancel pending removal if re-entered
	if pending_removal.has(body):
		pending_removal[body].queue_free()
		pending_removal.erase(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if affected_enemies.has(body) and not pending_removal.has(body):
		_start_removal_timer(body)

func _on_spell_timeout() -> void:
	# Disable area immediately
	area_3d.monitoring = false
	area_3d.set_deferred("monitorable", false)

	# Start removal timers for all enemies still inside
	for body in affected_enemies.keys():
		if not pending_removal.has(body):
			_start_removal_timer(body)

	# Spell node queue_free() itself (after disabling area and setting timers)
	hide()
	var removal_timer = get_tree().create_timer(effect_duration + 1)
	removal_timer.timeout.connect(_on_removal_timeout)

func _on_removal_timeout() -> void:
	# Now that the effect duration is over, we can safely free the spell
	queue_free()

func _start_removal_timer(body: Node3D) -> void:
	if body and body.is_inside_tree():
		var timer = Timer.new()
		timer.wait_time = effect_duration
		timer.one_shot = true
		body.add_child(timer)  # Attach timer to body so it survives even after spell dies
		timer.timeout.connect(_on_removal_timer_timeout.bind(body))
		timer.start()
		pending_removal[body] = timer

func _on_removal_timer_timeout(body: Node3D) -> void:
	if body and body.is_inside_tree() and affected_enemies.has(body):
		var stats = body.find_child("Stats")
		if stats:
			stats.damage /= .75  # Restore original damage
			body.remove_child(pending_removal[body])
		affected_enemies.erase(body)
	pending_removal.erase(body)
