extends Node

var choice = null
@onready var cm = $"../SubViewportContainer/SubViewport/Camera3D"
@onready var arnis = preload("res://Scene/Characters/arnisador.tscn")
var current_view
var fl =true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_view = cm.transform
	print(current_view)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if fl:
			cm.transform = Transform3D(Basis(Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,1,0)),Vector3(0,30,-2.5))
			$"../UI".visible = false
			fl = false
		else:
			cm.transform = current_view
			$"../UI".visible = true
			fl = true
			
	var value = int($"../UI/Troops/troops/Button/TroopQty".text)
	var inst
	if choice and int(value) > 0:
		inst = arnis.instantiate()
		if Input.is_action_just_pressed("lmb"):
			print("press")
			var mouse_position = get_viewport().get_mouse_position()
			var from = cm.project_ray_origin(mouse_position)
			var to = from + cm.project_ray_normal(mouse_position) * 100000
			var space_state = cm.get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			
			var result = space_state.intersect_ray(query)
			print(result)
			var pos = result["position"]
			
			add_child(inst)
			inst.global_transform.origin = Vector3(
				pos.x,
				0,
				pos.z
			)
			value -= 1
			$"../UI/Troops/troops/Button/TroopQty".text = str(value)
			
	pass


func _on_button_pressed() -> void:
	print("pressed btn")
	choice = 1
	pass # Replace with function body.
