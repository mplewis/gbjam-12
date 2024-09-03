class_name Dance
extends Control


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)


func _on_start():
	SceneMgr.close()
