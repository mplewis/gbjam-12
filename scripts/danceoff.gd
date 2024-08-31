class_name Danceoff
extends Node2D

@onready var beeper: Beeper = $Beeper

const demo_song = [
	[0, 1],
	[],
	[2],
	[1],
	[],
	[1],
	[2],
	[],
	[],
	[],
	[],
	[],
	[],
	[],
	[],
	[],
]


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(SceneMgr.close)

	beeper.configure(demo_song)
	beeper.play()
	beeper.on_beat.connect(_on_beat)


func _on_beat(beat: int, end_of_seq: bool):
	print("beat: %d, end_of_seq: %s" % [beat, str(end_of_seq)])
