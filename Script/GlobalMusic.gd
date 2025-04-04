extends Node

@onready var music_player := AudioStreamPlayer2D.new()
var is_music_on := true

func _ready():
	# Add the music player node to this global node
	add_child(music_player)
	music_player.stream = preload("res://assets/BackgroundMusic/(No Copyright Music) Epic Battle [Epic Music] by MokkaMusic  Rome Battle.mp3") # 🟡 Replace with your actual music path

	# Autoplay if music is on
	if is_music_on:
		music_player.play()

func toggle_music():
	is_music_on = !is_music_on
	update_music_state()

func update_music_state():
	if is_music_on:
		if !music_player.playing:
			music_player.play()
	else:
		music_player.stop()
