extends Node

# Exported variables to adjust stats in the editor
@export var hp: int = 150  # Average health
@export var damage: int = 25  # Moderate damage
@export var attack_speed: float = 1.2  # Average attack speed (attacks per second)
@export var movement_speed: float = 3.5  # Average movement speed
@export var level: int = 1  # Starting at level 1
@export var special_ability: bool = false  # No special ability for now

# Exported weights for each stat
@export var weight_hp: float = 0.3  # Weight for HP
@export var weight_damage: float = 0.4  # Weight for damage
@export var weight_attack_speed: float = 0.2  # Weight for attack speed
@export var weight_movement_speed: float = 0.1  # Weight for movement speed

# Multipliers to adjust stats for level scaling or buffs
@export var hp_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0

# Method to calculate combat power (CP)
func calculate_cp() -> float:
	# Normalize stats if needed and apply weights
	var normalized_hp = hp * hp_multiplier
	var normalized_damage = damage * damage_multiplier
	var normalized_attack_speed = attack_speed
	var normalized_movement_speed = movement_speed
	
	# Combat Power formula (simple weighted sum)
	var cp = (normalized_hp * weight_hp) + (normalized_damage * weight_damage) + (normalized_attack_speed * weight_attack_speed) + (normalized_movement_speed * weight_movement_speed)
	
	return cp

func _ready():
	# Test the CP calculation for Arnisador
	var cp = calculate_cp()
	print(get_parent().name," Combat Power: ", cp)
