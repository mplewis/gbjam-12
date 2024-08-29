extends Node

const WINDOW_SCALE = 8

var resized = false
var scene_paths: Array[String] = []


func _ready():
	set_appropriate_window_size()
	scene_paths.push_back(ProjectSettings.get_setting("application/run/main_scene"))


## Singleton callable to resize the window appropriately for desktop development.
## This is safe to call in every scene's `ready` method.
func set_appropriate_window_size() -> void:
	if resized:
		return
	if OS.get_name() == "Web":
		return
	get_window().size *= Vector2i(WINDOW_SCALE, WINDOW_SCALE)
	get_window().move_to_center()
	resized = true


## Open a scene in `scenes/` by its short name (i.e. not by full `res://` path)
func open(scene_name: String) -> void:
	var path := "res://scenes/%s.tscn" % scene_name
	scene_paths.push_back(path)
	get_tree().change_scene_to_file(path)


## Close the current scene and return to the previous one
func close() -> void:
	if scene_paths.size() < 2:
		print_debug("No scenes remaining")
		return

	scene_paths.pop_back()
	get_tree().change_scene_to_file(scene_paths.back())
