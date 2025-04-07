#attack_state.gd
extends NpcState
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes
var two_models: bool
@onready var stats = fsm.get_parent().get_node("Stats")

var timer
var target

func _ready():
	timer = Timer.new()
	add_child(timer)
	if !stats.is_healer:
		timer.timeout.connect(_attack)
	else:
		timer.timeout.connect(_heal)
#Called when the node enters the scene tree for the first time.
func enter(_previous_state_path: String, data := {}) -> void:
	fsm.anim_player.play("idle")
	two_models = fsm.two_models
	var attack_speed = stats.get_scaled_attack_speed()
	target = data.get("target",null)
	timer.wait_time = 1.0 / attack_speed
	print("entered attack state")
	if not timer.is_stopped():
		timer.stop()
	timer.start()

	if two_models:
		fsm.npc_root_node.get_child(2).visible = true
		fsm.npc_root_node.get_child(1).visible = false
		
	
# Function to handle the attack logic
func _attack():
	if target and is_instance_valid(target):
		# Deal damage to the target
		fsm.anim_player.play("attack")
		#fsm.anim_player.playback_speed = stats.attack_speed
		target.get_node("Stats")._on_attacked(stats.get_scaled_damage())
		# After attack, check if the target is dead
		if target.get_node("Stats").current_hp <= 0:
			print("Target is dead. Looking for new target.")
			_find_new_target()

func _heal():
	if target and is_instance_valid(target):
		# Deal damage to the target
		fsm.anim_player.play("attack")
		#fsm.anim_player.playback_speed = stats.attack_speed
		target.get_node("Stats")._on_heal(stats.get_scaled_damage())
		# After attack, check if the target is dead
		if target.get_node("Stats").current_hp >= target.get_node("Stats").get_scaled_hp():
			print("Target is full health. Looking for new target.")
			_find_new_target()
	pass
# Function to check if there's a new target and retarget
func _find_new_target():
	fsm.targeting_component._find_nearest_target()
	var new_target = fsm.targeting_component.target
	if is_instance_valid(new_target) and new_target != target:
		target = new_target
		print("New target found: ", target.name)
		fsm._transition_to_next_state("Attack", {"target": target})
	else:
		print("No new target. Transitioning to Idle.")
		fsm._transition_to_next_state("Idle")

func update(_delta: float):
	if not is_instance_valid(target) and not target:
		fsm._transition_to_next_state("Idle")

func exit():
	if timer:
		timer.stop()
