class_name Dance
extends Node2D

const ARROW_SPAWN_TO_HIT_SEC = 0.8

# Determined by experimentation.
# There is some constant difference between the offset from the calibration scene
# (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY = 0.16

@onready var midi_player_spawn: MidiPlayer = $MidiPlayerSpawn
@onready var midi_player_audio: MidiPlayer = $MidiPlayerAudio
@onready var GoalL: Goal = $GoalL
@onready var GoalC: Goal = $GoalC
@onready var GoalR: Goal = $GoalR
@onready var ArrowL: Arrow = $ArrowL
@onready var ArrowC: Arrow = $ArrowC
@onready var ArrowR: Arrow = $ArrowR
@onready var Score: Label = $UI/Score
@onready var Judgment: Sprite2D = $Judgment

@onready var spawners = [ArrowL, ArrowC, ArrowR]

var start_playing_at_ms: float
var score = 0
var combo = 0


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_right.connect(_on_right)

	GoalL.on_miss.connect(_on_miss)
	GoalC.on_miss.connect(_on_miss)
	GoalR.on_miss.connect(_on_miss)

	ArrowL.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC
	ArrowC.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC
	ArrowR.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC

	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0

	midi_player_spawn.midi_event.connect(_on_midi_event)

	midi_player_spawn.play()
	start_playing_at_ms = (
		Time.get_ticks_msec()
		+ (ARROW_SPAWN_TO_HIT_SEC - (AudioCal.audio_offset + MAGIC_NUMBER_MIDI_DELAY)) * 1000.0
	)


func _process(_delta):
	Score.text = "Score: %d\nCombo: %d" % [score, combo]
	start_audio()


func start_audio():
	if Time.get_ticks_msec() < start_playing_at_ms:
		return
	if midi_player_audio.playing:
		return
	midi_player_audio.play()


func _on_start():
	SceneMgr.close()


func _on_left():
	tally(GoalL.score())


func _on_down():
	tally(GoalC.score())


func _on_right():
	tally(GoalR.score())


func tally(s: Goal.SCORE):
	match s:
		Goal.SCORE.GREAT:
			score += 100
			combo += 1
			Judgment.frame = 1
		Goal.SCORE.GOOD:
			score += 50
			combo += 1
			Judgment.frame = 2
		Goal.SCORE.OK:
			score += 25
			combo += 1
			Judgment.frame = 3


func _on_miss(_body: Node2D):
	combo = 0
	Judgment.frame = 5


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	var tmpl = spawners[event.note % len(spawners)]
	var arrow = tmpl.duplicate()
	add_child(arrow)
	arrow.active = true
