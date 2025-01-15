extends DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_sun_position(Global.time_of_day)
	pass

func update_sun_position(time_of_day):
	# Rotate the sun (DirectionalLight) based on time of day
	var sun_angle = lerp(-90, 270, time_of_day)  # Map 0.0-1.0 to -90 to 270 degrees
	self.rotation_degrees.x = sun_angle
