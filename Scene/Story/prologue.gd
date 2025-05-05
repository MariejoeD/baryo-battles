extends Control

@onready var video_player = $VideoStreamPlayer
@onready var label: Label = $Label

func _ready():
	label.show()
	#SaverLoader.save_game()
	# Pause music if it's playing
	if MusicController.is_music_on and MusicController.music_player.playing:
		MusicController.music_player.stop()

	# Connect the video finished signal
	if video_player:
		Global.prologue_played = true
		video_player.finished.connect(_on_video_finished)
		video_player.play()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		video_player.stop()
		label.hide()
		_on_video_finished()
func _on_video_finished():
	SceneManager.go_to_scene("res://Scene/HomeBase.tscn")
