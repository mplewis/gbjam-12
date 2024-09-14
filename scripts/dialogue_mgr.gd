extends Node

@warning_ignore("UNUSED_SIGNAL")
signal on_advance
signal on_close

var current: Node = null


func _ready():
	on_close.connect(_on_close)


func _on_close():
	current = null


func show(msg: String) -> DialogueBox:
	var dialogue_box: DialogueBox = load("res://scenes/dialogue_box.tscn").instantiate()
	dialogue_box.text = msg
	current = dialogue_box
	get_tree().current_scene.add_child(dialogue_box)
	return dialogue_box
