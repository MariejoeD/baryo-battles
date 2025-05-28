extends VBoxContainer

var notif_text_scene = preload("res://assets/notif_text.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _process(delta: float) -> void:
	if !MapManager.base_invaded and !MapManager.resources_received:
		return
	for i in MapManager.base_invaded:
		var notif_inst = notif_text_scene.instantiate()
		notif_inst.text = i + " has been taken over"
		MapManager.base_invaded.erase(i)
		add_child(notif_inst)
	for i in MapManager.resources_received:
		var notif_inst = notif_text_scene.instantiate()
		notif_inst.text = "+ "+str(MapManager.resources_received[i])+" "+i
		MapManager.resources_received.erase(i)
		add_child(notif_inst)
