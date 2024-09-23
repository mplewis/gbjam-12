extends Node

# Compiler can't tell that these signals are used by dynamic dispatch

@warning_ignore("UNUSED_SIGNAL")
signal on_a
@warning_ignore("UNUSED_SIGNAL")
signal on_b
@warning_ignore("UNUSED_SIGNAL")
signal on_select
@warning_ignore("UNUSED_SIGNAL")
signal on_start
@warning_ignore("UNUSED_SIGNAL")
signal on_up
@warning_ignore("UNUSED_SIGNAL")
signal on_down
@warning_ignore("UNUSED_SIGNAL")
signal on_left
@warning_ignore("UNUSED_SIGNAL")
signal on_right

@warning_ignore("UNUSED_SIGNAL")
signal on_a_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_b_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_select_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_start_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_up_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_down_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_left_hold
@warning_ignore("UNUSED_SIGNAL")
signal on_right_hold

@warning_ignore("UNUSED_SIGNAL")
signal on_a_release
@warning_ignore("UNUSED_SIGNAL")
signal on_b_release
@warning_ignore("UNUSED_SIGNAL")
signal on_select_release
@warning_ignore("UNUSED_SIGNAL")
signal on_start_release
@warning_ignore("UNUSED_SIGNAL")
signal on_up_release
@warning_ignore("UNUSED_SIGNAL")
signal on_down_release
@warning_ignore("UNUSED_SIGNAL")
signal on_left_release
@warning_ignore("UNUSED_SIGNAL")
signal on_right_release

const DIALOGUE_ADVANCE_BTN = "ui_gameboy_a"

var lookup = {
	"ui_gameboy_a": "a",
	"ui_gameboy_b": "b",
	"ui_gameboy_select": "select",
	"ui_gameboy_start": "start",
	"ui_up": "up",
	"ui_down": "down",
	"ui_left": "left",
	"ui_right": "right",
}

var state = {
	"ui_gameboy_a": false,
	"ui_gameboy_b": false,
	"ui_gameboy_select": false,
	"ui_gameboy_start": false,
	"ui_up": false,
	"ui_down": false,
	"ui_left": false,
	"ui_right": false,
}

var cheat_code = ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a"]
var last_pressed = []


func _process(_delta):
	if _check_cheat_code():
		_open_cheat_menu()
		return

	if DialogueMgr.current:
		if Input.is_action_just_pressed(DIALOGUE_ADVANCE_BTN):
			DialogueMgr.on_advance.emit()
			state["ui_gameboy_a"] = true
		return

	for x in state.keys():
		var short = lookup[x]

		if Input.is_action_pressed(x):
			emit_signal("on_%s_hold" % short)
			if !state[x]:
				emit_signal("on_%s" % short)
				state[x] = true
				_push_cheat_code(short)
		else:
			if state[x]:
				emit_signal("on_%s_release" % short)
			state[x] = false


func _check_cheat_code():
	if get_tree().get_current_scene().get_name() == "Cheats":
		return false

	if len(last_pressed) < len(cheat_code):
		return false

	for x in len(cheat_code):
		if last_pressed[x] != cheat_code[x]:
			return false

	return true


func _push_cheat_code(short: String):
	last_pressed.push_back(short)
	while len(last_pressed) > len(cheat_code):
		last_pressed.pop_front()


func _open_cheat_menu():
	SceneMgr.open("ui/cheats")
