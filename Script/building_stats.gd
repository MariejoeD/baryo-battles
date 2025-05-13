extends Node

# Exported variables to adjust stats in the editor
@export var hp: int = 300  # Average health
@export var damage: int = 25  # Moderate damage
@export var attack_range: float = 2
@export var attack_speed: float = 1.2  # Average attack speed (attacks per second)
@export var target_priority: float = 1
# Exported weights for each stat
@export var weight_hp: float = 0.3  # Weight for HP
@export var weight_damage: float = 0.4  # Weight for damage
@export var weight_attack_speed: float = 0.3  # Weight for attack speed
var current_hp

func get_scaled_hp() -> float:
	return hp * (1 + (get_parent().level-1) *.5)

func get_scaled_damage() -> float:
	return damage * (1 + (get_parent().level-1))

func get_scaled_attack_speed() -> float:
	return attack_speed * (1 + weight_attack_speed)

func calculate_cp() -> float:
	var cp = (
		get_scaled_hp() * weight_hp +
		get_scaled_damage() * weight_damage +
		get_scaled_attack_speed() * weight_attack_speed
	)
	return cp

func calculate_priority_score() -> float:
	var score = target_priority
	
	# Optional: Bonus if building is nearly destroyed (e.g., finishing off an important target)
	if current_hp < get_scaled_hp() * 0.25:
		score += 2.0  # Extra weight for being very low
	
	return score


func _on_attacked(damage):
	current_hp -= damage
	if current_hp <= 0:
		current_hp = 0
		_on_destruction()

func _ready():
	# Test the CP calculation for Arnisador
	var cp = calculate_cp()
	print(get_parent().name," Combat Power: ", cp)
	current_hp = get_scaled_hp() # Optional if you want to start full health

func _on_destruction():
	get_parent().on_destroyed()
	print(get_parent().name,"Died")
	if get_parent().name == "Malacadabra":
		print(get_parent().name,"Died")
		get_tree().current_scene.find_child("Entities").show_result("lose")
	get_parent().queue_free()
	
