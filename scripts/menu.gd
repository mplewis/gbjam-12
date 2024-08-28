class_name Menu
extends Node2D

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

const WINDOW_SCALE = 8

var input_states = {
	"ui_gameboy_a": false,
	"ui_gameboy_b": false,
	"ui_gameboy_select": false,
	"ui_gameboy_start": false,
	"ui_up": false,
	"ui_down": false,
	"ui_left": false,
	"ui_right": false,
}

var menu_items := {
	"new_game": "New Game",
	"options": "Options",
	"credits": "Credits",
}
var selected := 0

@onready var menu_items_label: Label = %MenuItems
@onready var sfx_up: AudioStreamPlayer = $SFX/Up
@onready var sfx_down: AudioStreamPlayer = $SFX/Down
@onready var sfx_select: AudioStreamPlayer = $SFX/Select
@onready var sfx_back: AudioStreamPlayer = $SFX/Back


func _ready():
	if OS.get_name() != "Web":
		get_window().size *= Vector2i(WINDOW_SCALE, WINDOW_SCALE)


func _process(_delta):
	check_inputs()
	update_menu()


func check_inputs():
	for action in input_states.keys():
		if Input.is_action_pressed(action):
			if !input_states[action]:
				call("_on_btn_%s" % action)
				input_states[action] = true
		else:
			if input_states[action]:
				input_states[action] = false


func update_menu():
	var items = menu_items.values()
	items[selected] = "> %s <" % items[selected]
	menu_items_label.text = "\n".join(items)


func _on_btn_ui_up():
	sfx_up.play()
	selected = (selected - 1) % menu_items.size()


func _on_btn_ui_down():
	sfx_down.play()
	selected = (selected + 1) % menu_items.size()


func _on_btn_ui_gameboy_a():
	sfx_select.play()
	var item = menu_items.keys()[selected]
	call("_on_menu_%s" % item)


func _on_btn_ui_gameboy_b():
	sfx_back.play()
	print("Back")


func _on_btn_ui_gameboy_select():
	pass


func _on_btn_ui_gameboy_start():
	pass


func _on_btn_ui_left():
	pass


func _on_btn_ui_right():
	pass


func _on_menu_new_game():
	print("New Game")


func _on_menu_options():
	print("Options")


func _on_menu_credits():
	print("Credits")
