extends Node

var resized = false
var scene_paths: Array[String] = []


func _ready():
	_set_appropriate_window_size()
	scene_paths.push_back(ProjectSettings.get_setting("application/run/main_scene"))


## Open a scene in `scenes/` by its short name (i.e. not by full `res://` path)
func open(scene_name: String) -> void:
	var path := "res://scenes/%s.tscn" % scene_name
	scene_paths.push_back(path)
	var status := get_tree().change_scene_to_file(path)
	assert(status == OK, "Failed to open scene %s: %s" % [path, status])


## Close the current scene and return to the previous one.
## Don't connect this directly, i.e. `GBtn.on_b.connect(SceneMgr.close)`!
## It will cause all presses to close the scene. Bind to a local method instead.
func close() -> void:
	if scene_paths.size() < 2:
		print_debug("No scenes remaining")
		return

	scene_paths.pop_back()
	get_tree().change_scene_to_file(scene_paths.back())
	UiSounds.cancel()


## Reset to the game's initial state and clear any pushed scenes.
func reset():
	_ready()
	open("ui/splash")


## Singleton callable to resize the window appropriately for desktop development.
func _set_appropriate_window_size() -> void:
	if resized:
		return
	if OS.get_name() == "Web":
		return

	var scale := _select_scale()
	get_window().size *= Vector2i(scale, scale)
	get_window().move_to_center()
	resized = true


func _select_scale() -> int:
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	var scale = min(screen_size.x / window_size.x, screen_size.y / window_size.y)
	return max(scale, 1)
