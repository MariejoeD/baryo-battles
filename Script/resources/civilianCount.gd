extends Label


func _process(delta):
	# Get the current civilian count from the Global script
	var civilian_count = Global.get_current_civilian_count()
	var max = Global.get_max_civilians()
	# Update the label text with the current count
	text = str(civilian_count) + " / " + str(max)
	%civBar.max_value = max
	%civBar.value = civilian_count
