class_name Controls
extends TextureRect

var input_state = {
	"ui_gameboy_a": false,
	"ui_gameboy_b": false,
	"ui_gameboy_select": false,
	"ui_gameboy_start": false,
	"ui_up": false,
	"ui_down": false,
	"ui_left": false,
	"ui_right": false,
}

@onready var btn_a: TouchScreenButton = $A
@onready var btn_b: TouchScreenButton = $B
@onready var btn_select: TouchScreenButton = $Select
@onready var btn_start: TouchScreenButton = $Start
@onready var btn_up: TouchScreenButton = $Up
@onready var btn_down: TouchScreenButton = $Down
@onready var btn_left: TouchScreenButton = $Left
@onready var btn_right: TouchScreenButton = $Right

@onready var input_map = {
	"ui_gameboy_a": btn_a,
	"ui_gameboy_b": btn_b,
	"ui_gameboy_select": btn_select,
	"ui_gameboy_start": btn_start,
	"ui_up": btn_up,
	"ui_down": btn_down,
	"ui_left": btn_left,
	"ui_right": btn_right,
}


func _process(_delta):
	for action in input_map.keys():
		var button = input_map[action]
		var is_p = button.is_pressed()
		var was_p = input_state[action]

		if is_p and !was_p:
			Input.action_press(action)
			input_state[action] = true
		elif was_p and !is_p:
			Input.action_release(action)
			input_state[action] = false
