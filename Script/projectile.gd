extends Area3D
class_name Projectile

var starting_position: Vector3
var target: Node3D

@export var speed: float = 2.0
@export var damage: int = 20
@export var use_arc: bool = true
@export var max_arc_height: float = 2.0 # baseline height for arcs

var arc_height: float = 0.0
var lerp_pos: float = 0.0

func _ready():
	global_position = starting_position
	
	if target == null:
		queue_free()
		return

	# Precompute arc height based on distance if arc is enabled
	if use_arc:
		var distance = starting_position.distance_to(target.global_position)
		arc_height = clamp(distance * 0.25, 1.0, max_arc_height)

func _process(delta):
	if target == null:
		queue_free()
		return

	var target_pos = target.global_position
	if target.has_node("CollisionShape3D"):
		var sca = target.scale
		var y = target.get_node("CollisionShape3D").shape.height 
		target_pos.y = (y * 0.9) * sca.y

	if lerp_pos < 1.0:
		var pos = starting_position.lerp(target_pos, lerp_pos)

		if use_arc:
			var arc = sin(lerp_pos * PI) * arc_height
			pos.y += arc

		


		global_position = pos
		
		# 🔄 Rotate so the TOP (+Y) faces the target
		var to_target = (target_pos - global_position).normalized()
		if to_target.length() > 0.01:
			var fallback = Vector3.FORWARD
			if abs(to_target.dot(fallback)) > 0.99:
				fallback = Vector3.RIGHT

			var right = fallback.cross(to_target).normalized()
			var forward = to_target.cross(right).normalized()
			global_transform.basis = Basis(right, to_target, forward)
		
		lerp_pos += delta * speed
	else:
		queue_free()
