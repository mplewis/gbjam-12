extends Node

var scene_names: Array[String] = []

const WINDOW_SCALE = 8
var resized = false


func _ready():
	set_appropriate_window_size()


## Singleton callable to set the window size for
func set_appropriate_window_size() -> void:
	if resized:
		return
	if OS.get_name() == "Web":
		return
	get_window().size *= Vector2i(WINDOW_SCALE, WINDOW_SCALE)
	get_window().move_to_center()
	resized = true


func open(scene_name: String) -> void:
	scene_names.push_back(scene_name)
	var path := _path_for(scene_name)
	print("Changing to %s" % path)
	get_tree().change_scene_to_file(path)


func close() -> void:
	if scene_names.size() < 2:
		print_debug("No scene_names remaining")
		return

	scene_names.pop_back()
	var prev_scene_name = scene_names.back()
	get_tree().change_scene_to_file(_path_for(prev_scene_name))


func _path_for(scene_name: String) -> String:
	return "res://scenes/%s.tscn" % scene_name
