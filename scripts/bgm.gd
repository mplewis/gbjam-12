class_name BGM
extends AudioStreamPlayer


# HACK: Looping doesn't work on web
func _process(_delta):
	if not is_playing():
		play()
