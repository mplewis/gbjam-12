class_name Danceoff
extends Node2D

const BPM: float = 120
const BARS: int = 4
const BEATS_PER_BAR: int = 2

var duration_sec := (60.0 * BARS * BEATS_PER_BAR) / BPM
var now := 0.0
var first := true

@onready var bgm: AudioStreamPlayer = $BGM


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(SceneMgr.close)
	print(duration_sec)


func _process(delta):
	if first:
		first = false
	else:
		now += delta
	if now >= duration_sec:
		print("loop")
		now = float_mod(now, duration_sec)
		bgm.stop()
		bgm.play()


func float_mod(a: float, b: float) -> float:
	return a - b * floor(a / b)
