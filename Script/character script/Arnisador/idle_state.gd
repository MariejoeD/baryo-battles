extends NpcState

var target : Node3D = null
@onready var fsm = get_parent() as StateMachine  # Reference to the FSM for state changes


func update(_delta: float) -> void:
	target = fsm.targeting_component.target
	if target:
		# If target is found, change state to 'Running' or another relevant state
		# Assuming 'RunningState' is a state where the NPC moves towards the target
		fsm._transition_to_next_state("Chase", {"target": target})
		print("Transitioning to RunningState")
		
	else:
		fsm.anim_player.play("idle")
