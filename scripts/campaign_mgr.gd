extends Node

## Call `CampaignMgr.scene_complete.emit()` when your music minigame
## is done and you're ready to move onto the next one -
## ending dialogue is complete, fadeout is done, etc.
@warning_ignore("UNUSED_SIGNAL")
signal scene_complete

const SCENE_TXN = "cinematics/scene_transition"

const SCENES = ["cinematics/intro"]


func start_campaign():
	_run_transition(false, false, true)
	await scene_complete

	for scene in SCENES:
		_inst_and_replace_scene(scene)
		await scene_complete

		_run_transition(true, true, true)
		await scene_complete


func _ready():
	scene_complete.connect(_on_scene_complete)


func _on_scene_complete():
	print("Scene complete")


func _inst_scene(scene_name: String) -> Node:
	return load("res://scenes/%s.tscn" % scene_name).instantiate()


func _replace_scene(scene: Node):
	var s = get_tree().current_scene
	if s:
		s.queue_free()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene  # HACK, maybe?


func _inst_and_replace_scene(scene_name: String):
	var scene := _inst_scene(scene_name)
	_replace_scene(scene)


func _run_transition(open: bool, footsteps: bool, close: bool):
	var transition: SceneTransition = _inst_scene(SCENE_TXN)
	transition.door_open = open
	transition.footsteps = footsteps
	transition.door_close = close
	_replace_scene(transition)
