class_name Danceoff
extends Node2D

enum Note { A, B, REST }

## Track beats per minute
const BPM: float = 240
## Bars in the track
const BARS: int = 4
## Beats per bar
const BEATS_PER_BAR: int = 4
## How much of the song is the generator allowed to use?
const GEN_RATIO: float = 0.5

var song_duration_sec := (60.0 * BARS * BEATS_PER_BAR) / BPM
var beat_duration_sec := 60.0 / BPM
var song_ts := 0.0
var beat_ts := 0.0
var beat := 0
var first := true

var goal_notes: Array[Note] = []

@onready var bgm: AudioStreamPlayer = $BGM
@onready var beep1: AudioStreamPlayer = $Beep1
@onready var beep2: AudioStreamPlayer = $Beep2
@onready var debug_notes: Label = $DebugNotes
@onready var debug_pos: Label = $DebugPos


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(SceneMgr.close)
	GBtn.on_a.connect(_on_a)
	GBtn.on_b.connect(_on_b)
	loop()


func _process(delta):
	if first:
		first = false
	else:
		song_ts += delta
		beat_ts += delta
	if song_ts >= song_duration_sec:
		song_ts = float_mod(song_ts, song_duration_sec)
		loop()
	if beat_ts >= beat_duration_sec:
		beat = (beat + 1) % BEATS_PER_BAR
		beat_ts = float_mod(beat_ts, beat_duration_sec)
		if goal_notes:
			match goal_notes.pop_front():
				Note.A:
					_on_a()
				Note.B:
					_on_b()
				Note.REST:
					pass

	print(beat)
	if beat < goal_notes.size():
		var pos_chars := []
		for i in range(goal_notes.size()):
			pos_chars.push_back(" ")
		pos_chars[beat] = "^"
		debug_pos.text = " ".join(pos_chars)
		print(pos_chars)


func loop():
	goal_notes = generate_beats()
	debug_notes.text = " ".join(goal_notes)
	bgm.stop()
	bgm.play()


func generate_beats() -> Array[Note]:
	var notes: Array[Note] = []
	var count := int(BARS * BEATS_PER_BAR * GEN_RATIO)
	for i in range(count):
		match randi() % 3:
			0:
				notes.append(Note.A)
			1:
				notes.append(Note.B)
			2:
				notes.append(Note.REST)
	return notes


func _on_a():
	beep1.stop()
	beep1.play()


func _on_b():
	beep2.stop()
	beep2.play()


func float_mod(a: float, b: float) -> float:
	return a - b * floor(a / b)
