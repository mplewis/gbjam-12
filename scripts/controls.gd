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
	btn_a:"ui_gameboy_a" ,
	btn_b:"ui_gameboy_b" ,
	btn_select:"ui_gameboy_select" ,
	btn_start:"ui_gameboy_start" ,
	btn_up:"ui_up",
	btn_down:"ui_down" ,
	btn_left:"ui_left" ,
	btn_right:"ui_right" 
}

func _ready() -> void:
	for btn in get_children():
		
		btn.pressed.connect(set_action_press.bind(btn))
		btn.released.connect(set_action_release.bind(btn))
	pass
func set_action_press(btn):
	
	Input.action_press(input_map[btn])
	
	input_state[btn] = true
	
func set_action_release(btn):
	Input.action_release(input_map[btn])
	input_state[btn] = false
