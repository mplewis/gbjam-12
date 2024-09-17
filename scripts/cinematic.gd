class_name Cinematic
extends Control

enum Action {
	SHOW,
	HIDE,
	FADE_IN,
	HOLD,
	FADE_OUT,
	DIALOGUE,
}

signal on_finish

@export var FADE_DURATION = 0.5
@export var HOLD_DURATION = 2.0

@onready var bg: TextureRect = %BG
@onready var fader: TextureRect = %Fader
var children: Array[Control] = []

var step_idx := 0
var steps := []
var busy := false
var done := false


func _ready():
	# Put fader in front of other slides
	remove_child(fader)
	add_child(fader)

	for child in get_children():
		assert(child is Control, "All children of Cinematic must be Control nodes.")
		if child in [bg, fader]:
			continue
		children.append(child)
		child.hide()
	assert(len(children) > 0, "Cinematic must have at least one child.")

	var lastSlide: CanvasItem = null
	for child in children:
		if child is Label:
			steps.push_back([Action.DIALOGUE, child.text])

		if lastSlide:
			steps.push_back([Action.FADE_OUT])
			steps.push_back([Action.HIDE, lastSlide])
			lastSlide = null

		if child is not Label:
			steps.push_back([Action.SHOW, child])
			steps.push_back([Action.FADE_IN])
			steps.push_back([Action.HOLD])
			lastSlide = child

	if lastSlide:
		steps.push_back([Action.FADE_OUT])

	DialogueMgr.on_close.connect(_next)


func _next():
	busy = false
	step_idx += 1


func _process(_delta):
	if busy or done:
		return

	if step_idx >= len(steps):
		done = true
		on_finish.emit()
		return

	var step = steps[step_idx]

	match step:
		[Action.SHOW, var child]:
			child.show()
			_next()

		[Action.HIDE, var child]:
			child.hide()
			_next()

		[Action.FADE_IN]:
			busy = true
			var tween := get_tree().create_tween()
			tween.tween_property(fader, "modulate:a", 0.0, FADE_DURATION)
			tween.finished.connect(_next)

		[Action.HOLD]:
			busy = true
			get_tree().create_timer(HOLD_DURATION).timeout.connect(_next)

		[Action.FADE_OUT]:
			busy = true
			var tween := get_tree().create_tween()
			tween.tween_property(fader, "modulate:a", 1.0, FADE_DURATION)
			tween.finished.connect(_next)

		[Action.DIALOGUE, var text]:
			busy = true
			DialogueMgr.show(text)
