class_name Danceoff
extends Node2D

@onready var beeper: Beeper = $Beeper
@onready var marker: Label = $Marker
@onready var coach_follow: PathFollow2D = $CoachTL/Follow
@onready var coach_marker_anchor: Label = $CoachTL/Follow/MarkerAnchor
@onready var player_follow: PathFollow2D = $PlayerTL/Follow
@onready var player_marker_anchor: Label = $PlayerTL/Follow/MarkerAnchor
@onready var debug: Label = $Debug

var markers: Array[Label] = []
var pct := 0.0
var beat := 0
var notes: Array[int] = []

const base_song = [
	[0],
	[],
	[],
	[],
	[],
	[],
	[],
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
	GBtn.on_a.connect(_on_a)
	GBtn.on_b.connect(_on_b)

	beeper.on_beat.connect(_on_beat)
	beeper.on_progress.connect(_on_progress)

	var song = generate_new_song()
	beeper.configure(song)
	beeper.play()


func _on_a():
	if _player_phase():
		beeper.pluck(1)
		_mark_active_tl("A")


func _on_b():
	if _player_phase():
		beeper.pluck(2)
		_mark_active_tl("B")


func generate_notes(count: int):
	notes = []
	for i in range(count):
		if i == 0:
			notes.append(1)
		else:
			match int(randf() * 4):
				0:
					notes.append(1)
				1:
					notes.append(2)
				_:
					notes.append(-1)


func generate_new_song() -> Array:
	generate_notes(8)
	var song := base_song.duplicate()
	for i in range(notes.size()):
		var note := notes[i]
		if note != -1:
			# HACK: don't know why we have to assign it this way, but in-place append doesn't work.
			var x = [note]
			x.append_array(song[i])
			song[i] = x
	return song


func _coach_phase():
	return pct < 0.5


func _player_phase():
	return !_coach_phase()


func _on_beat(_beat: int, end_of_seq: bool):
	beat = _beat
	debug.text = "Beat: %d" % beat

	if end_of_seq:
		beeper.configure(generate_new_song())

	if beat == 0:
		for m in markers:
			m.queue_free()
		markers = []

	if _coach_phase():
		_mark_coach_beat()


func _on_progress(_pct: float):
	pct = _pct
	if _coach_phase():
		coach_follow.progress_ratio = pct * 2
		player_follow.progress_ratio = 0
	else:
		player_follow.progress_ratio = (pct - 0.5) * 2
		coach_follow.progress_ratio = 1


func _mark_coach_beat():
	print("pct: %f, beat: %d" % [pct, beat])
	if beat >= notes.size():
		return
	var note = notes[beat]
	if note == 1:
		_mark_active_tl("A")
	elif note == 2:
		_mark_active_tl("B")


func _mark_active_tl(s: String):
	if beat == 0:
		breakpoint

	var m: Label = marker.duplicate()
	m.text = s

	var anchor := coach_marker_anchor
	if _player_phase():
		anchor = player_marker_anchor
	m.global_position = anchor.global_position

	m.show()
	add_child(m)
	markers.append(m)
