@tool
class_name Fader
extends Sprite2D

@export var duration_sec: float = 1.0
@export var start_dark: bool = true


func _ready():
	show()
	if start_dark:
		modulate.a = 1.0
	else:
		modulate.a = 0.0


func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration_sec)


func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration_sec)
