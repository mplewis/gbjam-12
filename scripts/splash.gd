## Splash (title) screen for the game.

@tool
class_name Splash
extends Control

const BLINK_DURATION = 1.5  # sec; period to blink the PRESS START label

var groove_started := false
var show_press_start_at = null

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var press_start: Label = $House/PressStart
@onready var bgm: AudioStreamPlayer = $BGM
@onready var groove: AudioStreamPlayer = $Groove


func _ready():
	GBtn.on_start.connect(_on_start)
	anim_player.animation_finished.connect(_on_animation_finished)

	anim_player.play("intro")


func _process(_delta):
	if show_press_start_at:
		var now := float(Time.get_ticks_msec() - show_press_start_at) / 1000
		var on := fmod(now, BLINK_DURATION) < BLINK_DURATION / 2
		press_start.modulate.a = 1.0 if on else 0.0

	if groove_started and not groove.playing:
		groove.play()


func _on_start():
	bgm.stop()
	groove_started = false
	groove.stop()
	anim_player.play("fade_away")


func _on_animation_finished(anim_name: String):
	if anim_name == "fade_away":
		SceneMgr.open("ui/menu")


func start_groove():
	groove_started = true


## Called by the animation player to synchronize the PRESS START initial blink
## with the lightning animation.
func show_press_start():
	show_press_start_at = Time.get_ticks_msec()
