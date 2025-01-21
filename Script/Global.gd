extends Node

var wood_qty :int = 0:
	set(wood):
		wood_qty = wood
		SignalManager.update_mats.emit()
	get:
		return wood_qty
var grid_size :int = 100

var npc_discovered = {}

const DAY_DURATION = 600
var current_time = 0.0
var time_of_day: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.discovered.connect(npc)
	pass # Replace with function body.


func npc(name):
	npc_discovered[name] = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time += delta
	if current_time >= DAY_DURATION:
		SignalManager.new_day.emit()
		current_time = 0.0
	time_of_day = current_time / DAY_DURATION
	pass
