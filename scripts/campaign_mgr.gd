extends Node

## Call `CampaignMgr.game_complete.emit()` when your music minigame
## is done and you're ready to move onto the next one -
## ending dialogue is complete, fadeout is done, etc.
@warning_ignore("UNUSED_SIGNAL")
signal game_complete


func _ready():
	game_complete.connect(_on_game_complete)


func _on_game_complete():
	print("Game done!")
