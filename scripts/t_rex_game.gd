class_name TRexGame
extends Node2D

## Determined by experimentation.
## There is some constant difference between the offset from the calibration scene
## (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY := 0.16
## How fast the hit animation fades out
const HIT_ANIM_FADE_RATE := 2.0

@export var intro_text: String
@export var win_text: String
@export var lose_text: String
@export var spawn_to_hit_sec: float = 3.0
@export var fullness_threshold: int = 20
@export var skip_to_song_end: bool = false

var start_playing_music_at_ms = null
var fullness := 0

@onready var notes: MidiPlayer = $Notes
@onready var audio_music: AudioStreamPlayer = $Audio/Music
@onready var audio_win: AudioStreamPlayer = $Audio/Win
@onready var audio_lose: AudioStreamPlayer = $Audio/Lose

@onready var spawner: CandyArrowFollower = %CandyArrowSpawner
@onready var goal: Area2D = $Goal
@onready var chomp_trigger: Area2D = %ChompTrigger

@onready var hit_anim: AnimatedSprite2D = $HitAnim
@onready var trex_anim_tree: AnimationTree = %TRexAnimTree
@onready
var trex_anim_sm: AnimationNodeStateMachinePlayback = trex_anim_tree.get("parameters/playback")
@onready var pc_anim_tree: AnimationTree = %PCAnimTree
@onready var pc_anim_sm: AnimationNodeStateMachinePlayback = pc_anim_tree.get("parameters/playback")
@onready var splash_ring: AnimatedSprite2D = $SplashRing

@onready var fader: Fader = $Fader


func _ready():
	# TODO: Add button masher cooldown
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_up.connect(_on_up)
	GBtn.on_right.connect(_on_right)

	audio_music.finished.connect(_on_music_end)
	notes.midi_event.connect(_on_midi_event)

	chomp_trigger.body_entered.connect(_on_candy_chompable)

	spawner.hide()
	hit_anim.modulate.a = 0.0
	hit_anim.play()

	_start_intro()


func _start_intro():
	fader.fade_in()
	await get_tree().create_timer(1.0).timeout

	DialogueMgr.show(intro_text)
	await DialogueMgr.on_close

	# TODO: Install audio intro when we get the assets
	# HACK: Gappy transition into game music
	# audio_intro["parameters/looping"] = false
	# while audio_intro.playing:
	# 	await get_tree().create_timer(0.1).timeout

	_start_game()


func _start_game():
	notes.play()
	start_playing_music_at_ms = (
		Time.get_ticks_msec() + int((spawn_to_hit_sec - AudioCal.total_audio_offset()) * 1000)
	)


func _process(delta: float):
	hit_anim.modulate.a -= delta * HIT_ANIM_FADE_RATE
	_ensure_start_music()


func _ensure_start_music():
	if (
		start_playing_music_at_ms
		and Time.get_ticks_msec() >= start_playing_music_at_ms
		and not audio_music.playing
	):
		audio_music.play()

		if skip_to_song_end:
			audio_music.seek(audio_music.stream.get_length() - 10.0)

		start_playing_music_at_ms = null


# TODO: Handle completion of audio


func _on_left():
	tally("L")


func _on_down():
	tally("D")


func _on_up():
	tally("U")


func _on_right():
	tally("R")


func tally(dir: String):
	pc_anim_sm.travel("punch")
	score_and_remove(goal, dir)


func score_and_remove(area: Area2D, dir: String) -> int:
	assert(dir in ["L", "D", "U", "R"], "Invalid direction: %s" % dir)

	var count := 0
	var candies = area.get_overlapping_bodies()
	for body: PhysicsBody2D in candies:
		var candy: CandyArrowFollower = body.get_parent()
		if candy.dir_str != dir:
			continue
		count += 1

		_punt(candy)
		candy.queue_free()

	return count


func _on_midi_event(_channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	var dir_i = -1
	match event.note:
		49:
			dir_i = 0
		56:
			dir_i = 1
		61:
			dir_i = 2
		68:
			dir_i = 3
		_:
			return

	spawner.spawn(dir_i, spawn_to_hit_sec)


func _punt(candy: CandyArrowFollower):
	var puntable := candy.spawn_puntable()
	add_child(puntable)


func _on_candy_chompable(candy: CandyArrowPuntable):
	fullness += 1
	# print(fullness)

	trex_anim_sm.travel("chomp")
	hit_anim.modulate.a = 1.0

	var sr: AnimatedSprite2D = splash_ring.duplicate()
	sr.global_position = candy.global_position
	sr.play()
	sr.animation_finished.connect(func(): sr.queue_free())
	add_child(sr)

	candy.queue_free()


func _on_music_end():
	notes.stop()

	if fullness > fullness_threshold:
		DialogueMgr.show(win_text)
		audio_win.play()
		await audio_win.finished
	else:
		DialogueMgr.show(lose_text)
		audio_lose.play()
		await audio_lose.finished

	if DialogueMgr.current:
		await DialogueMgr.on_close

	fader.fade_out()
	await fader.fade_complete
	CampaignMgr.game_complete.emit()
