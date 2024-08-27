class_name DemoFaderLayer
extends CanvasLayer

const FADE_DURATION_SEC = 3.0

var fade_in = false

@onready var r: ColorRect = $ColorRect


func _process(_delta):
	r.color.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / (FADE_DURATION_SEC * 1000.0) * PI)
