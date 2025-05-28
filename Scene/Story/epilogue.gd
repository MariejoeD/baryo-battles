extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VideoStreamPlayer.finished.connect(_on_video_finished)
	# Pause music if it's playing
	if MusicController.is_music_on and MusicController.music_player.playing:
		MusicController.music_player.stop()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_video_finished():
	MusicController.music_player.play()
	get_tree().change_scene_to_file("res://Scene/Story/congrats.tscn")
