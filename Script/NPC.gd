extends Node

var TH_level = 1

@onready var Troops_unlocked: Dictionary = {
	"arnisador" : [preload("res://Scene/Characters/arnisador.tscn"), 1],
	"lakanWarrior" : [preload("res://Scene/Characters/lakan_warrior.tscn"), 2],
	"mangagamot" : [preload("res://Scene/Characters/manggagamot.tscn"), 2],
	"tirador" : [preload("res://Scene/Characters/tirador.tscn"), 3],
	"marites" : [preload("res://Scene/Characters/marites.tscn"), 3]
	
}
@onready var enemies: Dictionary = {
	"duwende" : [preload("res://Scene/Characters/duwende.tscn"), 1],
	"sigbin" : [preload("res://Scene/Characters/sigbin.tscn"), 2],
	"kapre" : [preload("res://Scene/Characters/kapre.tscn"), 2],
	"tikbalang" : [preload("res://Scene/Characters/tikbalang.tscn"), 3],
	"mananaggal" : [preload("res://Scene/Characters/manananggal.tscn"), 3]
}

func _ready() -> void:
	SignalManager.TH_upgrade.connect(th_on_upgrade)
	SignalManager.night_time.connect(troop)
	SignalManager.night_time.connect(enemy)
	
	#troop()

func th_on_upgrade():
	TH_level += 1

func troop():
	for i in Troops_unlocked:
		
		if Troops_unlocked[i][1]  <= TH_level:
			var temp_inst = Troops_unlocked[i][0].instantiate()
			var stats = temp_inst.find_child("Stats")
			var Defend_Mechanism = get_tree().current_scene.find_child("Defend Mechanism")
			#print(i, ": ", "cp: ",stats.calculate_cp(), " space: ", stats.space_cost)
			var value = {"name":i,"cp":stats.calculate_cp(), "space": stats.space_cost}
			if not Defend_Mechanism.unlocked_defenders.has(value):
				Defend_Mechanism.unlocked_defenders.append(value)
			temp_inst.queue_free()
			

func enemy():
	for i in enemies:
		if enemies[i][1]  <= TH_level:
			var Defend_Mechanism = get_tree().current_scene.find_child("Defend Mechanism")
			#print(i, ": ", "cp: ",stats.calculate_cp(), " space: ", stats.space_cost)
			var value = enemies[i][0]
			if not Defend_Mechanism.enemies.has(value):
				Defend_Mechanism.enemies.append(value)
			
#func 
