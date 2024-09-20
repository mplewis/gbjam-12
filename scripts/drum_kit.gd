class_name DrumKit
extends Node2D

const ARROW_SPAWN_TO_HIT_SEC = 0.8

const KICK_NOTE_LOW = 33
const KICK_NOTE_HIGH = 37
const SNARE_NOTE_LOW = 37
const SNARE_NOTE_HIGH = 41
const TOM_NOTE_LOW = 41
const TOM_NOTE_HIGH = 46
const HAT_NOTE_LOW = 42
const HAT_NOTE_HIGH = 52
const CRASH_NOTE_LOW = 49
const CRASH_NOTE_HIGH = 55
const SPLASH_NOTE_LOW = 52
const SPLASH_NOTE_HIGH = 60
# Determined by experimentation.
# There is some constant difference between the offset from the calibration scene
# (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY = 0.16
@onready var Score: Label = $UI/Score
@onready var circles_parent: Control = $Circles
var circles: Array[RadialProgress] = []
var circle_index = 0
var is_spider_waiting = false

var score = 0
var combo = 0


@export var spider = AnimatedSprite2D.new()
@onready var note2frame = {
	[KICK_NOTE_LOW, KICK_NOTE_HIGH]:6, 
	[SNARE_NOTE_LOW, SNARE_NOTE_HIGH]:1,  
	[HAT_NOTE_LOW, HAT_NOTE_HIGH]:5,
	[CRASH_NOTE_LOW, CRASH_NOTE_HIGH]:2,
	[SPLASH_NOTE_LOW, SPLASH_NOTE_HIGH]:3,
	[TOM_NOTE_LOW, TOM_NOTE_HIGH]:4}
@onready var midi_player_spawn: MidiPlayer = $MidiPlayerSpawn
@onready var midi_player_audio: MidiPlayer = $MidiPlayerAudio
var start_playing_at_ms: float
var started = false


var animation := {
	[KICK_NOTE_LOW, KICK_NOTE_HIGH]: {
		"call": "kick",
	},[CRASH_NOTE_LOW, CRASH_NOTE_HIGH]: {
		"call": "crash",
	},
	[SNARE_NOTE_LOW, SNARE_NOTE_HIGH]: {
		"call": "snare",
	},[TOM_NOTE_LOW, TOM_NOTE_HIGH]: {
		"call": "tom",
	},
	[HAT_NOTE_LOW, HAT_NOTE_HIGH]: {
		"call": "hat_closed",
	},
	[SPLASH_NOTE_LOW, SPLASH_NOTE_HIGH]: {
		"call": "splash",
	}
}


func _ready():
	GBtn.on_start.connect(_on_start)
	
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_right.connect(_on_right)
	
	GBtn.on_up.connect(_on_up)
	GBtn.on_a.connect(_on_a)
	GBtn.on_b.connect(_on_b)
	
	midi_player_spawn.midi_event.connect(_on_midi_event)

	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0

	midi_player_spawn.play()
	start_playing_at_ms = (
		Time.get_ticks_msec()
		+ (ARROW_SPAWN_TO_HIT_SEC - (AudioCal.audio_offset + MAGIC_NUMBER_MIDI_DELAY)) * 1000.0
	)
	for circle in circles_parent.get_children():
		circles.append(circle)


func _process(delta: float) -> void:
	Score.text = "Score: %d\nCombo: %d" % [score, combo]
	if is_spider_waiting:
		var new_progress = circles[circle_index].progress + delta * 200# 200 maestro 175 jazzer 125 mid 50 Noob difficulty
		print(new_progress)
		while new_progress > 100:
			new_progress =0.0
			is_spider_waiting = false
			spider.frame = 0
			_on_miss()
			
		circles[circle_index].progress = new_progress
		circle_index = 0 if !is_spider_waiting else circle_index
		
func _on_start():
	SceneMgr.close()
	
func _on_left():
	
	get_tally(2)


func _on_down():
	get_tally(0)


func _on_right():
	get_tally(3)

func _on_up():
	
	get_tally(1)


func _on_a():
	get_tally(4)


func _on_b():
	get_tally(5)
func get_tally(index = 0):
	if index == circle_index && is_spider_waiting:
		tally(circles[circle_index].progress)
	elif is_spider_waiting:
		_on_miss()
func tally(progress):
	
	if progress < 50:
		score += 100
		combo += 1
		
		pass
	elif progress < 75:
		score += 50
		combo += 1
		pass
	elif progress < 98:
		score += 25
		combo += 1
	is_spider_waiting = false
	spider.frame = 0
	circles[circle_index].progress = 0.0
	circle_index = 0
func _on_miss():
	combo = 0	
	is_spider_waiting = false
	spider.frame = 0
	circles[circle_index].progress = 0.0
	circle_index = 0
func _on_midi_event(channel, event):
	
	if event.type != SMF.MIDIEventType.note_on:
		return
	else:
		if circle_index >= 6:
				circle_index == 0
		
		for i in animation.keys():
			
			if _find_note_range(i, event.note):
				if !is_spider_waiting:
					spider.frame = note2frame[i]
					is_spider_waiting = true
				$drum.call(animation[i].call)
			circle_index += 1 if !is_spider_waiting else 0
		circle_index = 0 if !is_spider_waiting else circle_index	

	if channel.number != 2:
		return
func _find_note_range(note_range, note_value):
	
	return note_range[0]<=note_value && note_range[1] > note_value
	
