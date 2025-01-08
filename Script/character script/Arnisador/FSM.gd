# State Machine Class
class_name StateMachine extends Node

@export var npc_root_node: CharacterBody3D
@export var targeting_component: Node3D
@export var anim_player: AnimationPlayer
@export var pathfinder_component: Node3D
## The initial state of the state machine. If not set, the first child node is used.
@export var initial_state: NpcState = null
## The current state of the state machine.
@onready var current_state: NpcState = (func get_initial_state() -> NpcState:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	# Give every state a reference to the state machine.
	for state_node: NpcState in get_children():
		state_node.finished.connect(_transition_to_next_state)
	
	# State machines usually access data from the root node of the scene they're part of: the owner.
	# We wait for the owner to be ready to guarantee all the data and nodes the states may need are available.
	#await owner.ready
	current_state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := current_state.name
	current_state.exit()
	current_state = get_node(target_state_path)
	current_state.enter(previous_state_path, data)
