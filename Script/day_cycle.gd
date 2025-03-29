extends Node3D  # Attach this to a parent node of both SunLight and MoonLight

@onready var sun = $SunLight  # Your sun's DirectionalLight3D
@onready var moon = $MoonLight  # Your moon's DirectionalLight3D

func _process(delta: float) -> void:
	update_light_positions(Global.time_of_day)

func update_light_positions(time_of_day):
	# Adjust to correctly start at 6 AM
	var shifted_time = fmod(time_of_day - 0.25 + 1.0, 1.0)  # Shift time to align 0.0 with 6 AM
	
	# Sun moves from -90° (sunrise) to 270° (full cycle)
	var sun_angle = lerp(-90.0, 270.0, shifted_time)  
	var moon_angle = sun_angle + 180.0  # Moon is always opposite the sun

	# Apply angles
	sun.rotation_degrees.x = sun_angle
	moon.rotation_degrees.x = moon_angle


	# Set sun and moon colors
	sun.light_color = Color(1.0, 0.95, 0.8)  # Warm yellowish-white
	moon.light_color = Color(0.5, 0.6, 1.0)  # Soft blue moonlight
