class_name Danceoff
extends Node2D

@onready var beeper: Beeper = $Beeper

const base_song = [
	[0],
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
	GBtn.on_a.connect(_on_a)

	beeper.on_beat.connect(_on_beat)

	var song = generate_new_song()
	beeper.configure(song)
	beeper.play()


func _on_a():
	var result = beeper.off_by()
	var beat = result[0]
	var timing = result[1]
	var ms = result[2]
	var pct_off = result[3]

	var timing_str := ""
	match timing:
		Beeper.Timing.EARLY:
			timing_str = "early"
		Beeper.Timing.LATE:
			timing_str = "late"
		_:
			timing_str = "on"
	print("%d: %s, %dms, pct off: %0.0f" % [beat, timing_str, ms, pct_off * 100])


func generate_notes(count: int) -> Array[int]:
	var notes: Array[int] = []
	for i in range(count):
		match int(randf() * 4):
			0:
				notes.append(1)
			1:
				notes.append(2)
			_:
				notes.append(-1)
	return notes


func generate_new_song() -> Array:
	var notes := generate_notes(4)
	var song := base_song.duplicate()
	for i in range(notes.size()):
		var note := notes[i]
		if note != -1:
			# HACK: don't know why we have to assign it this way, but in-place append doesn't work.
			var x = [note]
			x.append_array(song[i])
			song[i] = x
	return song


func _on_beat(_beat: int, end_of_seq: bool):
	if end_of_seq:
		beeper.configure(generate_new_song())
