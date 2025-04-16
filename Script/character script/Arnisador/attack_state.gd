
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
	var target_distance = fsm.npc_root_node.global_position.distance_to(target.global_position)
	if target_distance > stats.get_scaled_attack_ranged():
		fsm._transition_to_next_state("Chase", {"target" : target})
	
	if target and is_instance_valid(target):
		var desired_duration = 1.0 / stats.get_scaled_attack_speed()
		var anim_length = fsm.anim_player.get_animation("attack").length
		var speed_scale = anim_length / desired_duration
		fsm.anim_player.play("attack", -1.0, speed_scale)
		var target_stats = target.get_node("Stats")
		if stats.has_ability and stats.ability_name == "Rage Mode":
			var rage_threshold = 0.3  # Rage Mode activates when HP is below 30%
			var rage_multiplier = 1.5  # Increase damage and attack speed by 50%
			if stats.current_hp / stats.get_scaled_hp() <= rage_threshold:
				print("Rage Mode activated!")
				stats.damage_multiplier = rage_multiplier
				timer.wait_time = 1 / stats.get_scaled_attack_speed() * rage_multiplier
			else:
				stats.damage_multiplier = 1
				timer.wait_time = 1 / stats.get_scaled_attack_speed()
		target_stats._on_attacked(stats.get_scaled_damage())

		# If this unit has a taunt ability, force the target to target us
		if stats.has_ability and stats.ability_name == "taunt":
			var target_fsm = target.get_node_or_null("FSM")
			if target_fsm:
				var targeting = target_fsm.targeting_component
				if targeting:
					if targeting.forced_target == null:
						targeting.forced_target = fsm.get_parent()
						print("Taunted ", target.name, " into targeting ", fsm.get_parent().name)
						target_fsm._transition_to_next_state("Chase", {"target": fsm.get_parent()})
		if target_stats.current_hp <= 0:
			print("Target is dead. Looking for new target.")
			_find_new_target()

func _heal():
	if target and is_instance_valid(target):
		# Deal damage to the target
		fsm.anim_player.play("attack", -1, stats.get_scaled_attack_speed())
		#fsm.anim_player.playback_speed = stats.attack_speed
		target.get_node("Stats")._on_heal(stats.get_scaled_damage())
		# After attack, check if the target is dead
		if target.get_node("Stats").current_hp >= target.get_node("Stats").get_scaled_hp():
			print("Target is full health. Looking for new target.")
			_find_new_target()
	pass
# Function to handle the wolf transform and the return cycle


# Function to toggle between wolf and human form
func wolf_transform():
	var human_model = fsm.npc_root_node.get_node("HumanModel")  # change as needed
	var wolf_model = fsm.npc_root_node.get_node("WolfModel")    # change as needed

	var is_currently_wolf = wolf_model.visible
	var is_transforming_to_wolf = !is_currently_wolf

	human_model.visible = is_currently_wolf
	wolf_model.visible = is_transforming_to_wolf

	# Play smoke particles only when transforming to wolf
	if is_transforming_to_wolf:
		var smoke = wolf_model.get_node("GPUParticles3D")  # update path if needed
		if smoke:
			smoke.one_shot = true
			smoke.emitting = false  # reset in case it was already emitting
			smoke.emitting = true

	# Update evasion stat
	stats.evasion_chance = 0.3 if is_transforming_to_wolf else 0.0


	
# Function to check if there's a new target and retarget
func _find_new_target():
	fsm.targeting_component._find_nearest_target()
	var new_target = fsm.targeting_component.target
	if is_instance_valid(new_target) and new_target != target:
		target = new_target
		print("New target found: ", target.name)
		fsm._transition_to_next_state("Chase", {"target": target})
	else:
		print("No new target. Transitioning to Idle.")
		fsm._transition_to_next_state("Idle")
var transform : bool = false
func update(_delta: float):
	if not is_instance_valid(target) and not target:
		fsm._transition_to_next_state("Idle")
	if stats.has_ability and stats.ability_name == "Wolf Transform":
		if stats.current_hp <= stats.get_scaled_hp() * .3 and !transform:
			transform = true
			# show smoke
			wolf_transform()
		pass

func exit():
	if timer:
		timer.stop()
