extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	# Pause music if it's playing
	if MusicController.is_music_on and MusicController.music_player.playing:
		MusicController.music_player.stop()

	# Connect the video finished signal
	if video_player:
		Global.prologue_played = true
		video_player.finished.connect(_on_video_finished)
		video_player.play()

func _on_video_finished():
	SaverLoader.saved_game = SavedGame.new()
	SceneManager.go_to_scene("res://Scene/HomeBase.tscn")
