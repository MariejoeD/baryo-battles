extends Node3D

@onready var area_3d: Area3D = $Area3D
@export var damage: float = 5.0



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Body2")
	if body.is_in_group("Enemy"):  # Apply damage only to enemies
			body.find_child("Stats")._on_attacked(damage)
	pass # Replace with function body.
