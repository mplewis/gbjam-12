class_name SceneTransition
extends Control

@export var door_open := false
@export var footsteps := false
@export var door_close := false

@onready var audio_door_open: AudioStreamPlayer = $DoorOpen
@onready var audio_four_steps: AudioStreamPlayer = $FourSteps
@onready var audio_door_close: AudioStreamPlayer = $DoorClose
@onready var audio_open_steps_close: AudioStreamPlayer = $DoorOpenFourStepsDoorClose


func _ready():
	if door_open and footsteps and door_close:
		audio_open_steps_close.play()
		await audio_open_steps_close.finished
		return

	if door_open:
		audio_door_open.play()
		await audio_door_open.finished

	if footsteps:
		audio_four_steps.play()
		await audio_four_steps.finished

	if door_close:
		audio_door_close.play()
		await audio_door_close.finished

	CampaignMgr.scene_complete.emit()
