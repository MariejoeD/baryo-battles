extends Label

var time: float = 120.0  # in seconds
var countdown_on: bool = false
signal times_up

func _ready() -> void:
	update_time_text()

func _process(delta: float) -> void:
	if countdown_on:
		time -= delta
		if time <= 0.0:
			time = 0.0
			countdown_on = false
			times_up.emit()
		update_time_text()

func update_time_text():
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	text = "%02d:%02d" % [minutes, seconds]
