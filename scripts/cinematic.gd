class_name Cinematic
extends Control

enum CinematicAction {
	SHOW,
	HIDE,
	FADE_IN,
	HOLD,
	FADE_OUT,
	DIALOGUE,
	CALL_METHOD_ON_SLIDE,
	PLAY_AUDIO,
}

signal on_finish

@export var FADE_DURATION = 0.5
@export var HOLD_DURATION = 2.0

@onready var bg: TextureRect = %BG
@onready var fader: TextureRect = %Fader
var children: Array[Node] = []

var step_idx := 0
var steps := []
var busy := false
var done := false


func _ready():
	GBtn.on_start.connect(_skip_to_end)

	# Put fader in front of other slides
	remove_child(fader)
	add_child(fader)

	for child in get_children():
		if child in [bg, fader]:
			continue
		children.append(child)
		if child.has_method("hide"):
			child.hide()
	assert(len(children) > 0, "Cinematic must have at least one child.")

	var lastSlide: CanvasItem = null
	for child in children:
		if child is AudioStreamPlayer:
			steps.push_back([CinematicAction.PLAY_AUDIO, child])
			continue

		if child is Label:
			steps.push_back([CinematicAction.DIALOGUE, child.text])

		if lastSlide:
			steps.push_back([CinematicAction.FADE_OUT])
			steps.push_back([CinematicAction.HIDE, lastSlide])
			lastSlide = null

		if child is not Label:
			steps.push_back([CinematicAction.SHOW, child])
			steps.push_back([CinematicAction.CALL_METHOD_ON_SLIDE, child, "on_fade_in"])
			steps.push_back([CinematicAction.FADE_IN])
			steps.push_back([CinematicAction.HOLD])
			lastSlide = child

	if lastSlide:
		steps.push_back([CinematicAction.FADE_OUT])

	DialogueMgr.on_close.connect(_next)


func _next():
	busy = false
	step_idx += 1


func _skip_to_end():
	pass


func _process(_delta):
	if busy or done:
		return

	if step_idx >= len(steps):
		done = true
		on_finish.emit()
		CampaignMgr.scene_complete.emit()
		return

	var step = steps[step_idx]

	match step:
		[CinematicAction.SHOW, var child]:
			if child.has_method("show"):
				child.show()
			_next()

		[CinematicAction.HIDE, var child]:
			if child.has_method("hide"):
				child.hide()
			_next()

		[CinematicAction.FADE_IN]:
			busy = true
			var tween := get_tree().create_tween()
			tween.tween_property(fader, "modulate:a", 0.0, FADE_DURATION)
			tween.finished.connect(_next)

		[CinematicAction.HOLD]:
			busy = true
			get_tree().create_timer(HOLD_DURATION).timeout.connect(_next)

		[CinematicAction.FADE_OUT]:
			busy = true
			var tween := get_tree().create_tween()
			tween.tween_property(fader, "modulate:a", 1.0, FADE_DURATION)
			tween.finished.connect(_next)

		[CinematicAction.DIALOGUE, var text]:
			busy = true
			DialogueMgr.show(text)

		[CinematicAction.CALL_METHOD_ON_SLIDE, var slide, var method]:
			if slide.has_method(method):
				slide.call_deferred(method)
			_next()

		[CinematicAction.PLAY_AUDIO, var audio]:
			audio.play()
			_next()
