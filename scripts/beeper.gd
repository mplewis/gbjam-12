class_name Beeper
extends Node

signal on_beat(beat: int, end_of_seq: bool)

@export_range(1, 400) var bpm: float = 120
@export var samples: Array[AudioStream] = []

var sample_nodes: Array[AudioStreamPlayer] = []
## Array[Array[int]]
var notes := []
var seq_dur_sec := 0.0
var beat_dur_sec := 0.0

var loop := false
var playing := false
var beat_ts := 0.0
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


func _process(delta):
	if !playing:
		return

	if first:
		first = false
	else:
		beat_ts += delta

	if beat_ts >= beat_dur_sec:
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
	seq_dur_sec = 60.0 / bpm * notes.size()
	beat_dur_sec = seq_dur_sec / notes.size()

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
