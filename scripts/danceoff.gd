class_name Danceoff
extends Node2D


func _ready():
	SceneMgr.set_appropriate_window_size()


func _process(delta):
	if Input.is_action_pressed("ui_gameboy_start"):
		SceneMgr.close()
