extends Node

@export var health : float

func _on_attacked(damage):
	health -= damage
	if health < 0:
		health = 0
		get_parent().queue_free()
