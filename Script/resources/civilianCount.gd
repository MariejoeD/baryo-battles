extends Label

@onready var global = Global  # Access the Global singleton directly

func _process(delta):
	# Get the current civilian count from the Global script
	var civilian_count = global.get_current_civilian_count()
	
	# Update the label text with the current count
	text = ": %d" % civilian_count
