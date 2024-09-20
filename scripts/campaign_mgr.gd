extends Node

## Call `CampaignMgr.scene_complete.emit()` when your music minigame
## is done and you're ready to move onto the next one -
## ending dialogue is complete, fadeout is done, etc.
@warning_ignore("UNUSED_SIGNAL")
signal scene_complete


func start_campaign():
	await _run_transition(true, true, true)


func _ready():
	scene_complete.connect(_on_scene_complete)


func _on_scene_complete():
	print("Scene complete!")


func _run_transition(open: bool, footsteps: bool, close: bool):
	get_tree().change_scene_to_file("res://scenes/cinematics/scene_transition.tscn")
	var transition: SceneTransition = get_tree().current_scene
	transition.door_open = open
	transition.footsteps = footsteps
	transition.door_close = close
	await scene_complete
