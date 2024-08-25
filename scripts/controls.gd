class_name Controls
extends TextureRect

var input_state = {
	"ui_gameboy_a": false,
	"ui_gameboy_b": false,
}

@onready var btn_a: TouchScreenButton = $A
@onready var btn_b: TouchScreenButton = $B

@onready var input_map = {
	"ui_gameboy_a": btn_a,
	"ui_gameboy_b": btn_b,
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
