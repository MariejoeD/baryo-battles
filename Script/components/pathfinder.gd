extends Node3D

@onready var pathfinding : Node3D = null  # Declare pathfinding variable
@onready var timer : Timer = null  # Declare Timer variable

func _ready():
	# Set up the timer to delay the execution of the code
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1  # Delay for 0.1 seconds
	timer.one_shot = true  # One-time timer
	timer.start()

	# Connect the timeout signal of the timer to a method
	timer.timeout.connect(_on_timer_timeout)

# This method is triggered when the timer finishes
func _on_timer_timeout():
	# After the timer is done, we can safely access the AStar node
	pathfinding = get_tree().current_scene.find_child("AStar")
	if pathfinding:
		#print("Updated AStar:", pathfinding.get_parent().name)
		pass
	else:
		#print("AStar not found.")
		pass

func findpaths(start: Vector3, end: Vector3) -> Array:
	if pathfinding:
		var path = pathfinding.find_path(start, end)
		#print(name, "Path:", path)
		return path
	else:
		#print("No valid pathfinding node.")
		return []
