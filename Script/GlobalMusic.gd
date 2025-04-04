extends Node

@onready var music_player := AudioStreamPlayer2D.new()
@onready var sfx_player := AudioStreamPlayer2D.new()  # Sound effects player

var is_music_on := true
var is_sound_on := true  # New: toggle for sound effects

func _ready():
	# Add music and sfx players to the global node
	add_child(music_player)
	add_child(sfx_player)

	# Set music stream
	music_player.stream = preload("res://assets/BackgroundMusic/(No Copyright Music) Epic Battle [Epic Music] by MokkaMusic  Rome Battle.mp3")

	# Autoplay background music
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

func toggle_sound():
	is_sound_on = !is_sound_on

func play_click_sound():
	if is_sound_on:
		sfx_player.stream = preload("res://assets/BackgroundMusic/ButtonPlate Click (Minecraft Sound) - Sound Effect for editing.mp3")  # 🟡 Replace with your actual sound file
		sfx_player.play()
