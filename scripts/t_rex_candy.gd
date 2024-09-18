class_name TRexCandy
extends Node2D

@export var spawn_to_hit_sec = 2.0

## Determined by experimentation.
## There is some constant difference between the offset from the calibration scene
## (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY := 0.16
## How fast the hit animation fades out
const HIT_ANIM_FADE_RATE := 2.0

@onready var midi_player_spawn: MidiPlayer = $MidiPlayerSpawn
@onready var midi_player_audio: MidiPlayer = $MidiPlayerAudio
@onready var spawner: CandyArrowFollower = %CandyArrowSpawner
@onready var goal_great: Area2D = $Goals/Great
@onready var goal_good: Area2D = $Goals/Good
@onready var goal_ok: Area2D = $Goals/OK
@onready var goal_miss: Area2D = $Goals/Miss
@onready var hit_anim: AnimatedSprite2D = $HitAnim
@onready var trex_anim_tree: AnimationTree = %TRexAnimTree
@onready
var trex_anim_sm: AnimationNodeStateMachinePlayback = trex_anim_tree.get("parameters/playback")

var start_playing_at_ms: float
var started = false


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_up.connect(_on_up)
	GBtn.on_right.connect(_on_right)

	spawner.hide()
	hit_anim.play()
	hit_anim.modulate.a = 0.0
	goal_miss.body_entered.connect(_on_miss)

	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0

	midi_player_spawn.midi_event.connect(_on_midi_event)

	midi_player_spawn.play()
	start_playing_at_ms = (
		Time.get_ticks_msec()
		+ (spawn_to_hit_sec - (AudioCal.audio_offset + MAGIC_NUMBER_MIDI_DELAY)) * 1000.0
	)


func _process(delta: float):
	start_audio()
	hit_anim.modulate.a -= delta * HIT_ANIM_FADE_RATE


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
	# TODO: Re-add "show splash" effect
	for x in range(score_and_remove(goal_great, dir)):
		pass
	for x in range(score_and_remove(goal_good, dir)):
		pass
	for x in range(score_and_remove(goal_ok, dir)):
		pass


func score_and_remove(goal: Area2D, dir: String) -> int:
	assert(dir in ["L", "D", "U", "R"], "Invalid direction: %s" % dir)

	var count := 0
	var candies = goal.get_overlapping_bodies()
	print(dir, candies)
	for body: PhysicsBody2D in candies:
		var candy: CandyArrowFollower = body.get_parent()
		if candy.dir_str != dir:
			continue
		count += 1
		hit_anim.modulate.a = 1.0
		candy.punt()
		trex_anim_sm.travel("chomp")

	return count


func _on_miss(body: Node2D):
	print("miss: %s" % body)


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	spawner.spawn(event.note % 4, spawn_to_hit_sec)
