class_name DrumKit
extends Node2D

const ARROW_SPAWN_TO_HIT_SEC = 0.8


#CONST INSTRUMENT = MIDI NOTE NUMBER
const KICK_NOTE_LOW = 33
const KICK_NOTE_HIGH = 37
const SNARE_NOTE_LOW = 30
const SNARE_NOTE_HIGH = 39#41
const TOM_NOTE_LOW = 49#41
const TOM_NOTE_HIGH = 55#50#46

const LOW_TOM_NOTE_LOW = 75#41
const LOW_TOM_NOTE_HIGH = 85#50#46
const HAT_NOTE_LOW = 60#40#42
const HAT_NOTE_HIGH = 70#50#52
const CRASH_NOTE_LOW = 60
const CRASH_NOTE_HIGH = 70
const SPLASH_NOTE_LOW = 52
const SPLASH_NOTE_HIGH = 60
const ANIM_FADE_DURATION = 1.5  # sec

# Determined by experimentation.
# There is some constant difference between the offset from the calibration scene
# (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY = 0.16
@onready var Score: Label = $RecolorLayer/UI/Score
#@onready var Health: Label = $UI/Health
@onready var circles_parent: Control = $Circles
@onready var midi_player_spawn: MidiPlayer = $Notes
@onready var midi_player_audio: MidiPlayer = $Music
@onready var fader: Fader = $Fader
@onready var instruments = [$Audio/Snare, $Audio/HiTom, $Audio/Tom, $Audio/LowTom]
@onready var audio_win: AudioStreamPlayer2D = $Audio/Win
@onready var audio_lose: AudioStreamPlayer2D = $Audio/Lose
@onready var Music: AudioStreamPlayer2D = $Audio/Music

@onready var Nice:Array[Sprite2D] = [$Nice, $Nice2]
@onready var Eek:Array[Sprite2D] = [$Eek, $Eek2]



@export var intro_text: String
@export var win_text: String
@export var lose_text: String
@export var spider = AnimatedSprite2D.new()
@export var health_bar = AnimatedSprite2D.new() 
@onready var note2frame = {
	 
	[SNARE_NOTE_LOW, SNARE_NOTE_HIGH]:0,  
	[HAT_NOTE_LOW, HAT_NOTE_HIGH]:1,
	[LOW_TOM_NOTE_LOW, LOW_TOM_NOTE_HIGH]:2,
	[TOM_NOTE_LOW, TOM_NOTE_HIGH]:3}

var start_playing_at_ms: float
var started = false
var circles: Array[RadialProgress] = []
var circle_index = 0
var is_spider_waiting = false

var score = 0
var combo = 0
var spider_animations = ["snare", "hi_tom","tom", "low_tom"]

var animation := {
	[KICK_NOTE_LOW, KICK_NOTE_HIGH]: {
		"call": "kick",
	},[CRASH_NOTE_LOW, CRASH_NOTE_HIGH]: {
		"call": "crash",
	},
	
	[SPLASH_NOTE_LOW, SPLASH_NOTE_HIGH]: {
		"call": "splash",
	}
}
var animation_player := {
	[SNARE_NOTE_LOW, SNARE_NOTE_HIGH]: {
		"call": "snare",
	},[HAT_NOTE_LOW, HAT_NOTE_HIGH]: {
		"call": "high_tom",
	},
	
	[LOW_TOM_NOTE_LOW, LOW_TOM_NOTE_HIGH]: {
		"call": "tom",
	},
	
	[TOM_NOTE_LOW, TOM_NOTE_HIGH]: {
		"call": "low_tom",
	}
}
var wait_timer = 2.0#TIMER TO DELAY GAMEPLAY NOT TO BE CONFUSED W/ NOTE SPAWN DELAY
var start_timer = 0

var difficulty = 100#150 is maestro 100 jazzer 50 noob
var miss_buffer = 30.0/60.0



func _ready():
	_start_intro()
	spider.play(spider_animations[0])
	SceneMgr._set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)
	
	GBtn.on_left.connect(_on_left)
	GBtn.on_down.connect(_on_down)
	GBtn.on_right.connect(_on_right)
	
	GBtn.on_up.connect(_on_up)
	GBtn.on_a.connect(_on_a)
	GBtn.on_b.connect(_on_b)
	
	HealthMgr.on_health_reset.connect(_on_health_reset)
	HealthMgr.on_health_drain.connect(_on_health_drain)
	
	midi_player_spawn.midi_event.connect(_on_midi_event)
	
	Music.finished.connect(music_end)
	midi_player_audio.finished.connect(music_end)


func _start_intro():
	HealthMgr.health= HealthMgr.health_max
	fader.fade_in()
	await get_tree().create_timer(1.0).timeout
	

	DialogueMgr.show(intro_text)
	await DialogueMgr.on_close

	
	
	_start_game()
func _start_game():
	
	midi_player_spawn.volume_db = 0.0
	midi_player_audio.volume_db = 0.0
	
	
	midi_player_audio.play()
	
	
	
	for circle in circles_parent.get_children():
		circles.append(circle)
	start_timer = Time.get_ticks_msec()
	await get_tree().create_timer(2.0/60.0).timeout#NOTE SPAWN DELAY
	midi_player_spawn.play()
func _process(delta: float) -> void:
	
	
	var fade_amt := delta / ANIM_FADE_DURATION
	Nice[0].modulate.a -= fade_amt
	Nice[1].modulate.a -= fade_amt
	Eek[0].modulate.a -= fade_amt
	Eek[1].modulate.a -= fade_amt
	Score.text = "SCoR: %d\nCoMb: %d" % [score, combo]
	
	
	
	health_bar.frame = 10-int(float(HealthMgr.health/ HealthMgr.health_max)*10 )
	
	
	if is_spider_waiting || !spider.is_playing():
		
		spider.play(spider_animations[circle_index])
	
	if HealthMgr.health <=0:
		HealthMgr.on_health_reset.emit()
	await get_tree().create_timer(miss_buffer).timeout && floor(circles[circle_index].progress )== 100 && (start_timer+wait_timer*1000<Time.get_ticks_msec() ) && midi_player_spawn.playing
	if is_spider_waiting:
		
		
	
		var new_progress = circles[circle_index].progress - delta * difficulty	
		#print(new_progress)
	
		while new_progress < 0:
			new_progress =100.0
			is_spider_waiting = false
			_on_miss()
			
			
		circles[circle_index].progress = new_progress
		circle_index = 0 if !is_spider_waiting else circle_index
	if player_miss || !is_spider_waiting:
		$drum.call("shake_object", miss_index)
func _on_start():
	SceneMgr.scene_paths.pop_back()
	SceneMgr.close()
	
func _on_left():
	
	get_tally(0)
	miss_index = 1


func _on_down():
	miss_index = 0
	pass
	#get_tally(0)


func _on_right():
	get_tally(1)
	miss_index = 2

func _on_up():
	miss_index = 0
	pass
	#get_tally(1)


func _on_a():
	get_tally(3)
	miss_index = 4


func _on_b():
	get_tally(2)
	miss_index = 3 
func get_tally(index = 0):
	if index == circle_index && is_spider_waiting:
		tally(circles[circle_index].progress)
	elif index != circle_index  && is_spider_waiting:
		_on_miss()
func tally(progress):
	
	if progress >15 : 
		
		_on_hit(progress)
	else:
		_on_miss()
		
var player_miss = false		
var miss_index = 0

func music_end():
	midi_player_spawn.stop()
	if HealthMgr.health > 0:
		on_win()
	else:
		HealthMgr.on_health_reset.emit()

func on_win():
	
	DialogueMgr.show(win_text)
	audio_win.play()
	await audio_win.finished
	
	fader.fade_out()
	await fader.fade_complete
	CampaignMgr.scene_complete.emit()
func _on_miss():
	$Audio/Miss.play()
	combo = 0	
	is_spider_waiting = false
	spider.play("%s_idle" % spider_animations[circle_index] )
	#spider.frame = 0
	Eek[0 if circle_index < 2 else 1].modulate.a = 1.0
	circles[circle_index].progress = 100.0
	
	circle_index = 0
	HealthMgr.on_health_drain.emit()
	player_miss = true
	$drum.shake_length = 1.7
	
	
	
func _on_hit(progress):
		instruments[circle_index].play()
		
		$drum.call(animation_player[note2frame.keys()[circle_index]].call)
		
		score += 100 if progress >85 else 75 if progress > 70 else 50 if progress > 55 else 25 #perfect / great / good/ ok 
		
		if progress > 55:
		
			Nice[0 if circle_index < 2 else 1].modulate.a = 1.0
			
		
		combo += 1
		is_spider_waiting = false
		spider.frame = 0
		circles[circle_index].progress = 100.0
		
		circle_index = 0
	
func _on_health_drain():
	HealthMgr.health-= HealthMgr.health_drain

func _on_health_reset():
	Music.stop()
	midi_player_audio.stop()
	HealthMgr.health= HealthMgr.health_max
	health_bar.visible = false
	DialogueMgr.show(lose_text)
	audio_lose.play()
	await audio_lose.finished
	
	#await DialogueMgr.on_close
	
	
	get_tree().reload_current_scene()

			
func _on_midi_event(channel, event):
	
	if event.type != SMF.MIDIEventType.note_on:
		return
	else:
		if player_miss:
			#$Notes.stop()
			await get_tree().create_timer(miss_buffer).timeout
			#$Notes.play()
			player_miss = false
			
	
		for i in note2frame.keys():
			
			#SETS SPIDER TO NOTE GIVEN MIDI NOTE NUMBER
			if _find_note_range(i, event.note) && start_timer+wait_timer*1000<Time.get_ticks_msec() && !player_miss:
				if !is_spider_waiting :
					spider.play(spider_animations[note2frame[i]])
					circle_index = note2frame.keys().find(i,0)
					is_spider_waiting =true
					$drum.shake_length = 1.0
					player_miss  = false
					miss_index = 0
		#SETS ANIMATION FOR NON PLAYABLE INSTRUMENTS
		for i in animation.keys():
			
			
			if _find_note_range(i, event.note) :
				
				$drum.call(animation[i].call)
		#RESETS CIRCLE PROGRESS00
		circle_index = 0 if !is_spider_waiting else circle_index	

	if channel.number != 2:
		return
func _find_note_range(note_range, note_value):
	
	return note_range[0]<=note_value && note_range[1] > note_value
