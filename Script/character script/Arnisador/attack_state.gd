#attack_state.gd
extends NpcState
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes
var two_models: bool
var attack_speed: float
var timer
var target

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_attack)
#Called when the node enters the scene tree for the first time.
func enter(_previous_state_path: String, data := {}) -> void:
	two_models = fsm.two_models
	attack_speed = fsm.speed
	target = data.get("target",null)
	timer.wait_time = 1.0 / attack_speed
	print("entered attack state")
	timer.start()
	if two_models:
		fsm.npc_root_node.get_child(2).visible = true
		fsm.npc_root_node.get_child(1).visible = false
		
	fsm.anim_player.play("attack")
	
func _attack():
	if target and is_instance_valid(target):
		target.get_node("Health Component")._on_attacked(10)
	pass
func update(_delta: float):
	if not is_instance_valid(target) and not target:
		fsm._transition_to_next_state("Idle")
