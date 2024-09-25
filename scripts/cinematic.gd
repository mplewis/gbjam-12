## A Cinematic is a sequence of slides that are shown in order, with optional dialogue and audio.

class_name Cinematic
extends Control

enum CinematicAction {
	SHOW,
	HIDE,
	FADE_IN,
	HOLD,
	WAIT_FOR_ANIM_TO_FINISH,
	FADE_OUT,
	DIALOGUE,
	CALL_METHOD_ON_SLIDE,
	PLAY_AUDIO,
}

## How long the fade in/out transition lasts, in sec
@export var FADE_DURATION = 0.5
## By default, how long to hold on a slide before continuing, in sec
@export var DEFAULT_HOLD_DURATION = 2.0

@onready var bg: TextureRect = %BG
## Global fader - a black `TextureRect` on which we tween opacity to 1 to "fade out" and 0 to "fade in" content
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

	var last_slide: CanvasItem = null
	var last_slide_meta = null
	for slide in children:
		var slide_meta = parse_cine_meta(slide)
		print(slide_meta)

		# Play audio
		if slide is AudioStreamPlayer:
			steps.push_back([CinematicAction.PLAY_AUDIO, slide])
			continue

		# Present Labels as dialogue boxes
		if slide is Label:
			# Use `CINE_HOLD_BEFORE` to allow an animation to play out before popping the dialogue box up
			if 'HOLD_BEFORE' in slide_meta:
				var duration = slide_meta['HOLD_BEFORE']
				steps.push_back([CinematicAction.HOLD, duration])
			steps.push_back([CinematicAction.DIALOGUE, slide.text])

		if last_slide and last_slide.has_signal("animation_finished") and not last_slide.sprite_frames.get_animation_loop("default"):
			# Wait for animations to finish
			steps.push_back([CinematicAction.WAIT_FOR_ANIM_TO_FINISH, last_slide])
			# Use `CINE_HOLD` to freeze on the last frame before continuing
			if last_slide_meta and 'HOLD' in last_slide_meta:
				var duration = last_slide_meta['HOLD']
				steps.push_back([CinematicAction.HOLD, duration])

		# Fade out the previous slide
		if last_slide:
			steps.push_back([CinematicAction.FADE_OUT])
			steps.push_back([CinematicAction.HIDE, last_slide])
			last_slide = null

		# Fade in the next slide
		if slide is not Label:
			steps.push_back([CinematicAction.SHOW, slide])
			steps.push_back([CinematicAction.CALL_METHOD_ON_SLIDE, slide, "on_fade_in"])
			steps.push_back([CinematicAction.FADE_IN])

			var hold_duration = DEFAULT_HOLD_DURATION
			# Use `CINE_HOLD` to freeze before continuing
			if slide_meta and 'HOLD' in slide_meta:
				hold_duration = slide_meta['HOLD']
			steps.push_back([CinematicAction.HOLD, hold_duration])

			last_slide = slide
			last_slide_meta = slide_meta

	if last_slide:
		steps.push_back([CinematicAction.FADE_OUT])

	DialogueMgr.on_close.connect(_next)


func _next():
	busy = false
	step_idx += 1


func _skip_to_end():
	fader.modulate.a = 1.0
	busy = false
	step_idx = len(steps)


## You can add meta tags to a node to control the cinematic sequence.
## Meta tags are Label child nodes with names starting with `CINE_`
## and the text body value which is parsed into a string, int, or float.
## All meta tags are returned in a dictionary.
func parse_cine_meta(node: Node) -> Dictionary:
	var meta = {}
	for child in node.get_children():
		if child.name.begins_with("CINE_"):
			assert('text' in child, "CINE_ meta node must be a Label with a text value.")
			var key = child.name.substr(5)
			var raw = child.text.strip_edges()
			if raw.is_valid_int():
				meta[key] = raw.to_int()
			elif raw.is_valid_float():
				meta[key] = raw.to_float()
			else:
				meta[key] = raw
	return meta


func _process(_delta):
	if busy or done:
		return

	if step_idx >= len(steps):
		done = true
		CampaignMgr.scene_complete.emit()
		return

	var step = steps[step_idx]
	print(step)

	match step:
		[CinematicAction.SHOW, var slide]:
			if slide.has_method("show"):
				slide.show()
			if slide.has_method("play"):
				slide.play()
			_next()

		[CinematicAction.HIDE, var slide]:
			if slide.has_method("hide"):
				slide.hide()
			_next()

		[CinematicAction.FADE_IN]:
			busy = true
			var tween := get_tree().create_tween()
			tween.tween_property(fader, "modulate:a", 0.0, FADE_DURATION)
			tween.finished.connect(_next)

		[CinematicAction.HOLD, var duration]:
			busy = true
			get_tree().create_timer(duration).timeout.connect(_next)

		[CinematicAction.WAIT_FOR_ANIM_TO_FINISH, var slide]:
			busy = true
			if slide.is_playing():
				await slide.animation_finished
			_next()

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
