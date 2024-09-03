class_name Dance
extends Node2D

const START_FRAME = 2000.0
const ARROW_SPAWN_TO_HIT_SEC = 0.8

@onready var midi_player_spawn: MidiPlayer = $MidiPlayerSpawn
@onready var midi_player_audio: MidiPlayer = $MidiPlayerAudio
@onready var GoalL: Goal = $GoalL
@onready var GoalC: Goal = $GoalC
@onready var GoalR: Goal = $GoalR
@onready var ArrowL: Arrow = $ArrowL
@onready var ArrowC: Arrow = $ArrowC
@onready var ArrowR: Arrow = $ArrowR

@onready var arrows = [ArrowL, ArrowC, ArrowR]

var start_playing_at_ms: float


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_right.connect(_on_right)

	ArrowL.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC
	ArrowC.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC
	ArrowR.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC

	midi_player_audio.seek(START_FRAME)

	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0

	midi_player_spawn.midi_event.connect(_on_midi_event)

	midi_player_spawn.play()
	midi_player_spawn.seek(START_FRAME)
	start_playing_at_ms = Time.get_ticks_msec() + (ARROW_SPAWN_TO_HIT_SEC - AudioServer.get_output_latency()) * 1000.0


func _process(_delta):
	if Time.get_ticks_msec() < start_playing_at_ms:
		return
	if midi_player_audio.playing:
		return

	print("Playing audio now")
	midi_player_audio.play()
	midi_player_audio.seek(START_FRAME)


func _on_start():
	SceneMgr.close()


func _on_left():
	print(GoalL.score())


func _on_down():
	print(GoalC.score())


func _on_right():
	print(GoalR.score())


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	var tmpl = arrows[event.note % len(arrows)]
	var arrow = tmpl.duplicate()
	add_child(arrow)
	arrow.active = true
