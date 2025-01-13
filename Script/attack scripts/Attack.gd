extends Node

var map_level = {
	"Button": "res://Scene/Attack/attack_scene.tscn",
	"Button2": ""

}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for btn in $"../AttackPanel/ScrollContainer/VBoxContainer/TextureRect".get_children():
		btn.connect("pressed", Callable(self, "_on_btn_pressed").bind(btn))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_btn_pressed(btn):
	get_tree().change_scene_to_file(map_level[btn.name])
	pass
