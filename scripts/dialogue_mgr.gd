extends Node


func show(msg: String):
	var dialogue_box: DialogueBox = load("res://scenes/dialogue_box.tscn").instantiate()
	dialogue_box.text = msg
	get_tree().current_scene.add_child(dialogue_box)
