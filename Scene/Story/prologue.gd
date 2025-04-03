extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	# Connect the 'finished' signal of the VideoPlayer to a function
	if video_player:
		video_player.finished.connect(_on_video_finished)
		video_player.play()  # Start playing the video

# Called when the video is finished
func _on_video_finished():
	get_tree().change_scene_to_file("res://Scene/HomeBase.tscn")  # Update with the correct path
