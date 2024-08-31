class_name Beeper
extends Node

enum Timing { EARLY, ON, LATE }

signal on_beat(beat: int, end_of_seq: bool)
signal on_progress(pct: float)

@export_range(1, 400) var bpm: float = 120
@export var samples: Array[AudioStream] = []

var sample_nodes: Array[AudioStreamPlayer] = []
## Array[Array[int]]
var notes := []
var beat_dur_sec := 0.0

var loop := false
var playing := false
var beat_ts := 0.0
var beat_anchor_ms := 0
var beat := 0

# HACK: time gets wonky on the first play
var first = false


func configure(newNotes: Array, looping = true):
	notes = newNotes
	loop = looping
	_update_local_song()


func play():
	playing = true


func stop():
	playing = false
	beat_ts = 0
	beat = 0
	for i in range(sample_nodes.size()):
		sample_nodes[i].stop()


func pluck(i: int):
	if i < 0 or i >= notes.size():
		return
	sample_nodes[i].play()


func off_by() -> Array:
	var now := Time.get_ticks_msec()
	var ms_from_curr_beat = abs(now - beat_anchor_ms)
	var ms_from_next_beat = abs(ms_from_curr_beat - beat_dur_sec * 1000)
	print("ms_from_curr_beat: %d" % ms_from_curr_beat)
	print("ms_from_next_beat: %d" % ms_from_next_beat)

	var ms_from_closest_beat = min(ms_from_curr_beat, ms_from_next_beat)
	var pct_off = ms_from_closest_beat / (beat_dur_sec * 1000 * 2)

	var timing := Timing.ON
	if ms_from_curr_beat < ms_from_next_beat:
		timing = Timing.LATE
	elif ms_from_curr_beat > ms_from_next_beat:
		timing = Timing.EARLY

	return [beat, timing, ms_from_closest_beat, pct_off]


func _process(delta):
	if !playing:
		return
	if notes.size() == 0:
		return

	if first:
		first = false
	else:
		beat_ts += delta

	# % of the way through the current seq
	var seq_dur_sec := beat_dur_sec * notes.size()
	var seq_pos_sec := beat_ts + beat * beat_dur_sec
	var pct := seq_pos_sec / seq_dur_sec
	on_progress.emit(pct)

	if beat_ts >= beat_dur_sec:
		beat_anchor_ms = Time.get_ticks_msec()
		beat_ts = _fmod(beat_ts, beat_dur_sec)
		var to_play = notes[beat]
		for i in range(to_play.size()):
			sample_nodes[to_play[i]].play()
		beat += 1

		var end_of_seq = beat >= notes.size()
		if end_of_seq:
			beat = 0
			if loop:
				beat = 0
			else:
				playing = false

		on_beat.emit(beat, end_of_seq)


func _update_local_song():
	if notes.size() == 0:
		return
	beat_dur_sec = 60.0 / bpm

	for i in range(sample_nodes.size()):
		var existing_node := sample_nodes[i]
		if existing_node:
			existing_node.stop()
			existing_node.queue_free()

	sample_nodes = []

	for i in range(samples.size()):
		var new_node := AudioStreamPlayer.new()
		new_node.stream = samples[i]
		sample_nodes.append(new_node)
		add_child(new_node)


func _fmod(a: float, b: float) -> float:
	return a - b * floor(a / b)
