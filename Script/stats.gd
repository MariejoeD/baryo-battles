extends Node

@onready var Name: String = get_filename_base()

func get_filename_base() -> String:
	var scene = get_parent().scene_file_path
	if scene == "":
		return get_parent().name  # fallback if instanced directly in editor
	return scene.get_file().get_basename()

# Exported variables to adjust stats in the editor
@export var hp: int = 150  # Average health
@export var damage: int = 25  # Moderate damage
@export var attack_range: float = 2
@export var attack_speed: float = 1.2  # Average attack speed (attacks per second)
@export var movement_speed: float = 3.5  # Average movement speed
@export var evasion_chance: float = 0.0 # Average dodge chance
@export var level: int = 1  # Starting at level 1
@export_group("Special Ability")
@export var has_ability: bool = false
@export var ability_name: String = ""
@export_group("")  # Ends the group
  # No special ability for now

# Exported weights for each stat
@export var weight_hp: float = 0.3  # Weight for HP
@export var weight_damage: float = 0.4  # Weight for damage
@export var weight_attack_speed: float = 0.2  # Weight for attack speed
@export var weight_movement_speed: float = 0.1  # Weight for movement speed

# Multipliers to adjust stats for level scaling or buffs
@export var hp_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var space_cost: int = 1
@export var spawn_scale: Vector3 = Vector3(1, 1, 1)
@export var is_healer: bool = false
var current_hp


func get_scaled_hp() -> float:
	return hp * (1 + weight_hp * (level - 1)) * hp_multiplier

func get_scaled_damage() -> float:
	return damage * (1 + weight_damage * (level - 1)) * damage_multiplier

func get_scaled_attack_speed() -> float:
	return attack_speed * (1 + weight_attack_speed * (level - 1))

func get_scaled_movement_speed() -> float:
	return movement_speed * (1 + weight_movement_speed * (level - 1))

func get_scaled_attack_ranged() -> float:
	return attack_range * (1 + .2 * (level - 1))


func calculate_cp() -> float:
	var cp = (
		get_scaled_hp() * weight_hp +
		get_scaled_damage() * weight_damage +
		get_scaled_attack_speed() * weight_attack_speed +
		get_scaled_movement_speed() * weight_movement_speed
	)
	return cp


func _on_attacked(damage):
	if randf() < evasion_chance:
		print(get_parent().name, " dodged the attack!")
		return
	current_hp -= damage
	if current_hp < 0:
		current_hp = 0
		_on_death()
func _on_heal(heal):
	#print("before: ",current_hp)
	current_hp += heal
	#print("after: ",current_hp)
	
	if current_hp >= get_scaled_hp():
		current_hp = get_scaled_hp()
func _ready():
	# Test the CP calculation for Arnisador
	var cp = calculate_cp()
	print(get_parent().name," Combat Power: ", cp)
	current_hp = get_scaled_hp() # Optional if you want to start full health

func apply_spawn_scaling():
	get_parent().scale = spawn_scale
	if $"../Smoke/GPUParticles3D":
		var particle = $"../Smoke/GPUParticles3D"
		if particle is GPUParticles3D:
			var mat : ParticleProcessMaterial = particle.process_material
			if mat is ParticleProcessMaterial:
				print(mat.scale_min)
				mat.scale_min *= spawn_scale.x
				print(mat.scale_max)

func _on_death():
	print(get_parent().name,"Died")
	get_parent().queue_free()
	find_parent("Entities").win_lose_check()
	
