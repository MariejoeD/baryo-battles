extends Node

@onready var music_player := AudioStreamPlayer2D.new()
@onready var sfx_player := AudioStreamPlayer.new()  # Sound effects player

var is_music_on := false
var is_sound_on := true  # Toggle for sound effects

# Class names of buttons with 'pressed' signal
var PRESSABLE_TYPES = ["Button", "TextureButton", "CheckBox", "OptionButton", "MenuButton", "ToolButton"]

func _ready():
	# Add audio players to the global node
	add_child(music_player)
	add_child(sfx_player)

	# Set music stream
	music_player.stream = preload("res://assets/BackgroundMusic/(No Copyright Music) Epic Battle [Epic Music] by MokkaMusic  Rome Battle.mp3")
	sfx_player.stream = preload("res://assets/BackgroundMusic/ButtonPlate Click (Minecraft Sound) - Sound Effect for editing.mp3")  # 🔊 Replace with your actual sound
	# Autoplay background music if enabled
	if is_music_on:
		music_player.play()

	# Connect all buttons in the current scene
	connect_all_buttons(get_tree().current_scene)

func _on_scene_changed(new_scene):
	if new_scene:
		connect_all_buttons(new_scene)

func connect_all_buttons(node: Node):
	print("test")
	for child in node.get_children():
		if child.get_class() in PRESSABLE_TYPES:
			child.pressed.connect(play_click_sound)
		connect_all_buttons(child)  # Recursively check children

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
	print("test")
	if is_sound_on:
		sfx_player.play()
