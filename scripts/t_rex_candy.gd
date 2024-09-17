class_name TRexCandy
extends Node2D

@export var spawn_to_hit_sec = 2.0

# Determined by experimentation.
# There is some constant difference between the offset from the calibration scene
# (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY = 0.16

@onready var midi_player_spawn: MidiPlayer = $MidiPlayerSpawn
@onready var midi_player_audio: MidiPlayer = $MidiPlayerAudio
@onready var spawner: CandyArrowFollower = %CandyArrowSpawner
@onready var goal_great: Area2D = $Goals/Great
@onready var goal_good: Area2D = $Goals/Good
@onready var goal_ok: Area2D = $Goals/OK
@onready var goal_miss: Area2D = $Goals/Miss

var start_playing_at_ms: float
var started = false
var score = 0
var combo = 0


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_up.connect(_on_up)
	GBtn.on_right.connect(_on_right)

	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0

	midi_player_spawn.midi_event.connect(_on_midi_event)

	midi_player_spawn.play()
	start_playing_at_ms = (
		Time.get_ticks_msec()
		+ (spawn_to_hit_sec - (AudioCal.audio_offset + MAGIC_NUMBER_MIDI_DELAY)) * 1000.0
	)


func _process(_delta):
	start_audio()


func start_audio():
	if Time.get_ticks_msec() < start_playing_at_ms:
		return
	if started:
		return
	if midi_player_audio.playing:
		return
	midi_player_audio.play()
	started = true


# TODO: Handle completion of audio


func _on_start():
	SceneMgr.close()


func _on_left():
	tally("L")


func _on_down():
	tally("D")


func _on_up():
	tally("U")


func _on_right():
	tally("R")


func tally(dir: String):
	for x in range(score_and_remove(goal_great, dir)):
		score += 100
		combo += 1
		# TODO: Re-add "show splash" effect
	for x in range(score_and_remove(goal_good, dir)):
		score += 50
		combo += 1
	for x in range(score_and_remove(goal_ok, dir)):
		score += 25
		combo += 1

	for x in range(score_and_remove(goal_miss, dir)):
		combo = 0

	print(score)


func score_and_remove(goal: Area2D, dir: String) -> int:
	assert(dir in ["L", "D", "U", "R"], "Invalid direction: %s" % dir)

	var count := 0
	var candies = goal.get_overlapping_bodies()
	for candy in candies:
		if candy.label != dir:
			continue
		count += 1
		candy.punt()

	return count


func _on_miss(_body: Node2D):
	combo = 0


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	spawner.spawn(event.note % 4, spawn_to_hit_sec)
