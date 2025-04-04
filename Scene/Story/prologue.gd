extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	# Pause music if it's playing
	if MusicController.is_music_on and MusicController.music_player.playing:
		MusicController.music_player.stop()

	# Connect the video finished signal
	if video_player:
		video_player.finished.connect(_on_video_finished)
		video_player.play()

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scene/HomeBase.tscn")
