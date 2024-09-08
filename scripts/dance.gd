class_name Dance
extends Node2D

const ARROW_SPAWN_TO_HIT_SEC = 1.0

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
var arrows: Array[Arrow] = []


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_right.connect(_on_right)

	ArrowL.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC
	ArrowC.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC
	ArrowR.duration_to_goal_sec = ARROW_SPAWN_TO_HIT_SEC

	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0

	midi_player_spawn.midi_event.connect(_on_midi_event)

	midi_player_spawn.play()
	start_playing_at_ms = (
		Time.get_ticks_msec() + (ARROW_SPAWN_TO_HIT_SEC - AudioCal.audio_offset) * 1000.0
	)


func _process(_delta):
	Score.text = "Score: %d" % score
	start_audio()

	# for a in arrows:
	# 	if a.global_position.y >= GoalC.global_position.y:
	# 		a.queue_free()
	# 		arrows.erase(a)


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
			Judgment.frame = 2
		Goal.SCORE.GOOD:
			score += 50
			Judgment.frame = 3
		Goal.SCORE.OK:
			score += 25
			Judgment.frame = 4
		Goal.SCORE.MISS:
			Judgment.frame = 5


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	var tmpl = spawners[event.note % len(spawners)]
	var arrow = tmpl.duplicate()
	add_child(arrow)
	arrows.push_back(arrow)
	arrow.active = true
