class_name Game
extends Node2D

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

var input_names = {
	"ui_gameboy_a": "A",
	"ui_gameboy_b": "B",
	"ui_gameboy_select": "Select",
	"ui_gameboy_start": "Start",
	"ui_up": "Up",
	"ui_down": "Down",
	"ui_left": "Left",
	"ui_right": "Right"
}
var button_states = {
	"jump": false,
	"turbo": false,
}

var player_fwd_vel: float = BASE_SPEED
var player_up_vel := 0.0

@onready var player: CharacterBody2D = $Player
@onready var jump_sfx: AudioStreamPlayer2D = $Player/JumpSFX
@onready var turbo_sfx: AudioStreamPlayer2D = $Player/TurboSFX
@onready var control_debug: Label = $UI/ControlDebug

@onready var floor_y := player.position.y


func _ready():
	SceneMgr.set_appropriate_window_size()


func _process(delta):
	update_control_debug_label()

	if Input.is_action_pressed("ui_gameboy_start"):
		SceneMgr.close()

	if Input.is_action_pressed("ui_gameboy_a"):
		jump()
	else:
		button_states["jump"] = false

	if Input.is_action_pressed("ui_gameboy_b"):
		turbo()
	else:
		button_states["turbo"] = false

	player_up_vel -= GRAVITY_STR * delta
	player.position.y = min(floor_y, player.position.y - player_up_vel * delta)

	player.position.x += player_fwd_vel * delta
	player_fwd_vel = max(BASE_SPEED, player_fwd_vel - DECEL_STR * delta)


func jump():
	if player.position.y != floor_y:
		return

	if button_states["jump"]:
		return
	button_states["jump"] = true

	jump_sfx.play()
	player_up_vel = JUMP_STR


func turbo():
	if player_fwd_vel > BASE_SPEED:
		return

	if button_states["turbo"]:
		return
	button_states["turbo"] = true

	turbo_sfx.play()
	player_fwd_vel *= TURBO_MULT


func update_control_debug_label():
	var s = ""
	for input in input_names.keys():
		var action = input_names[input]
		if Input.is_action_pressed(input):
			s += action + "\n"
	control_debug.text = s
