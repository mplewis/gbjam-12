class_name Calibrate
extends Node2D

const CALI_SEQ_DURATION_S = 2.0
const ARROW_SPAWN_TO_HIT_SEC = 0.8
const GOAL_BEAT_ON = 1.5
const OFFSET_AVG_COUNT = 5

@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var goal: Goal = $Goal
@onready var arrow: Arrow = $Arrow
@onready var info: Label = $UI/Info


var offsets: Array[float] = []
var in_flight: Array[Arrow] = []

var last_hit := 0.0
var last_loop := 0.0
var sent_arrow = false


var info_tmpl = "
Offset: %0.2f
Press A on the high note
Press B to reset
Use arrows to
manually calibrate
Press START to exit
".strip_edges()


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	GBtn.on_a.connect(_on_a)
	GBtn.on_b.connect(_on_b)
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	GBtn.on_left.connect(_on_left)
	GBtn.on_right.connect(_on_right)

	arrow.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC

	midi_player.midi_event.connect(_on_midi_event)
	midi_player.looped.connect(_on_looped)

	last_loop = Time.get_ticks_msec() / 1000.0
	update_label()


func _process(_delta):
	var now := Time.get_ticks_msec() / 1000.0
	var next_arrow_at = GOAL_BEAT_ON - ARROW_SPAWN_TO_HIT_SEC - AudioCal.audio_offset
	if (now - last_loop) > next_arrow_at and not sent_arrow:
		var a = arrow.duplicate()
		add_child(a)
		in_flight.push_back(a)
		a.active = true
		sent_arrow = true

	for a in in_flight:
		if a.global_position.y >= goal.global_position.y:
			in_flight.erase(a)
			a.queue_free()

func _on_start():
	SceneMgr.close()


func _on_a():
	print_timing("down")

	var offset := Time.get_ticks_msec() / 1000.0 - last_hit

	if offset > CALI_SEQ_DURATION_S / 2.0: # early
		offset -= CALI_SEQ_DURATION_S


	offsets.push_back(offset)
	if offsets.size() > OFFSET_AVG_COUNT:
		offsets.pop_front()
	print(offsets)

	var sum := 0.0
	for o in offsets:
		sum += o
	var avg := sum / offsets.size()
	AudioCal.audio_offset = avg

	update_label()


func _on_b():
	offsets.clear()
	AudioCal.audio_offset = 0.0
	update_label()


func _on_up():
	AudioCal.audio_offset += 0.01
	update_label()


func _on_down():
	AudioCal.audio_offset -= 0.01
	update_label()


func _on_left():
	AudioCal.audio_offset -= 0.1
	update_label()


func _on_right():
	AudioCal.audio_offset += 0.1
	update_label()

func update_label():
	info.text = info_tmpl % AudioCal.audio_offset


func print_timing(s: String):
	var t := Time.get_ticks_msec() / 1000.0
	print("%0.3f: %s" % [t, s])


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 0:
		return

	last_hit = Time.get_ticks_msec() / 1000.0
	print_timing("hit")


func _on_looped():
	last_loop = Time.get_ticks_msec() / 1000.0
	sent_arrow = false
	print_timing("looped")
