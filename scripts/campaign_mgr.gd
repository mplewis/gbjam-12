extends Node

## Call `CampaignMgr.scene_complete.emit()` when your music minigame
## is done and you're ready to move onto the next one -
## ending dialogue is complete, fadeout is done, etc.
@warning_ignore("UNUSED_SIGNAL")
signal scene_complete


func _ready():
	scene_complete.connect(_on_scene_complete)


func _on_scene_complete():
	print("Scene complete!")
