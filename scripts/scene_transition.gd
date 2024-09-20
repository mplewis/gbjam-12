class_name SceneTransition
extends Control

## Play the "door open" sound effect.
@export var door_open := false
## Play the "footsteps" sound effect.
@export var footsteps := false
## Play the "door close" sound effect.
@export var door_close := false

@onready var audio_door_open: AudioStreamPlayer = $DoorOpen
@onready var audio_four_steps: AudioStreamPlayer = $FourSteps
@onready var audio_door_close: AudioStreamPlayer = $DoorClose
@onready var audio_open_steps_close: AudioStreamPlayer = $DoorOpenFourStepsDoorClose


func _ready():
	GBtn.on_start.connect(_skip_to_end)

	if door_open and footsteps and door_close:
		audio_open_steps_close.play()
		await audio_open_steps_close.finished

	else:
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


func _skip_to_end():
	audio_door_open.stop()
	audio_four_steps.stop()
	audio_door_close.stop()
	audio_open_steps_close.stop()
	CampaignMgr.scene_complete.emit()
