@tool
class_name Splash
extends Control

const BLINK_DURATION = 1.5  # sec; period to blink the PRESS START label

var groove_started := false

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var press_start: Label = $PressStart
@onready var groove: AudioStreamPlayer = $Groove


func _ready():
	GBtn.on_start.connect(_on_start)
	GBtn.on_a.connect(_on_start)

	anim_player.play("intro")


func _process(_delta):
	var now := float(Time.get_ticks_msec()) / 1000
	var on := fmod(now, BLINK_DURATION) < BLINK_DURATION / 2
	press_start.modulate.a = 1.0 if on else 0.0

	if groove_started and not groove.playing:
		groove.play()


func _on_start():
	SceneMgr.open("ui/menu")


func _start_groove():
	groove_started = true
