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
	var dialogue_box: DialogueBox = load("res://scenes/components/dialogue_box.tscn").instantiate()
	dialogue_box.text = msg
	current = dialogue_box
	_add_under_recolor_layer(dialogue_box)
	return dialogue_box


func _add_under_recolor_layer(dialogue_box: DialogueBox):
	var scene := get_tree().current_scene
	scene.add_child(dialogue_box)

	var recolor_layer := scene.get_node("RecolorLayer")
	if not recolor_layer:
		return

	var index = recolor_layer.get_index()
	scene.move_child(dialogue_box, index - 1)
