## HACK: Looping audio doesn't always loop on the Godot Web platform.
## Find all AudioStreamPlayer nodes set to loop in the entire tree
## and force them to loop.

extends Node

const CHECK_EVERY_MS = 100

var last_check_ticks_ms := 0


func _ready():
	if OS.get_name() != "Web":
		return

	print("WebAudioLoopFixer is ready")


func _process(_delta):
	if OS.get_name() != "Web":
		return

	# Find all AudioStreamPlayer nodes in the entire tree
	var scene := get_tree().current_scene
	if not scene:
		return
	var nodes := _get_all_children(scene)

	var audio_nodes := []
	for node in nodes:
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
			audio_nodes.push_back(node)

	var wants_loop := []
	for node in audio_nodes:
		if "parameters/looping" not in node:
			continue
		if node["parameters/looping"]:
			wants_loop.push_back(node)

	for node in wants_loop:
		if not node.playing:
			node.play()


func _get_all_children(in_node: Node, arr := []) -> Array:
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = _get_all_children(child, arr)
	return arr
